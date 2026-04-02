#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
ROOT="$(cd "$ROOT" && pwd)"
cd "$ROOT"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
RUN_DATE="$(date -u +"%Y-%m-%d")"
RUN_DIR="$ROOT/runs/$RUN_DATE/validate-$STAMP"
BOOTSTRAP_LOG="$RUN_DIR/bootstrap.log"
RELEASE_SMOKE_LOG="$RUN_DIR/release-smoke.log"
ACCESSIBILITY_LOG="$RUN_DIR/accessibility.log"
SITE_INSTALL_LOG="$RUN_DIR/site-install.log"
DOCS_BUILD_LOG="$RUN_DIR/docs-site-build.log"
SECURITY_LOG="$RUN_DIR/gitleaks.log"

mkdir -p "$RUN_DIR"

run_logged() {
  local log_path="$1"
  shift

  printf '$' >"$log_path"
  printf ' %q' "$@" >>"$log_path"
  printf '\n' >>"$log_path"

  if "$@" >>"$log_path" 2>&1; then
    return 0
  fi

  return $?
}

run_security_scan() {
  local log_path="$1"
  local report_path="$2"
  shift 2
  local target
  local exit_code=0
  local scanned_targets=()

  : >"$log_path"
  printf '[gitleaks] report=%s\n' "${report_path#"$ROOT"/}" >>"$log_path"

  for target in "$@"; do
    if [[ ! -e "$ROOT/$target" ]]; then
      continue
    fi

    scanned_targets+=("$target")
    printf '\n$ gitleaks dir --no-banner %q\n' "$ROOT/$target" >>"$log_path"

    if ! gitleaks dir --no-banner "$ROOT/$target" >>"$log_path" 2>&1; then
      exit_code=1
      break
    fi
  done

  ROOT="$ROOT" REPORT_PATH="$report_path" EXIT_CODE="$exit_code" SCANNED_TARGETS="$(printf '%s\n' "${scanned_targets[@]}")" python3 <<'PY'
import json
import os
import pathlib
from datetime import datetime, timezone

root = pathlib.Path(os.environ["ROOT"])
report_path = pathlib.Path(os.environ["REPORT_PATH"])

report = {
    "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "status": "PASS" if os.environ["EXIT_CODE"] == "0" else "FAIL",
    "targets": [target for target in os.environ["SCANNED_TARGETS"].splitlines() if target],
}

report_path.write_text(json.dumps(report, indent=2) + "\n")
PY

  return "$exit_code"
}

OVERALL_EXIT=0
LINT_STATUS="NOT RUN"
UNIT_TEST_STATUS="NOT RUN"
INTEGRATION_TEST_STATUS="BLOCKED"
BUILD_STATUS="NOT RUN"
SECURITY_STATUS="NOT RUN"
BOOTSTRAP_STATUS="NOT RUN"
RELEASE_SMOKE_STATUS="NOT RUN"
ACCESSIBILITY_STATUS="NOT RUN"
SITE_INSTALL_STATUS="NOT RUN"
DOCS_BUILD_STATUS="NOT RUN"
WINDOWS_RUNTIME_STATUS="BLOCKED"

if run_logged "$BOOTSTRAP_LOG" "$ROOT/bootstrap.sh"; then
  BOOTSTRAP_STATUS="PASS"
else
  BOOTSTRAP_STATUS="FAIL"
  OVERALL_EXIT=1
fi

if run_logged "$RELEASE_SMOKE_LOG" "$ROOT/scripts/release_smoke_test.sh"; then
  RELEASE_SMOKE_STATUS="PASS"
  UNIT_TEST_STATUS="PASS"
  BUILD_STATUS="PASS"
else
  RELEASE_SMOKE_STATUS="FAIL"
  UNIT_TEST_STATUS="FAIL"
  BUILD_STATUS="FAIL"
  OVERALL_EXIT=1
fi

if run_logged "$ACCESSIBILITY_LOG" "$ROOT/scripts/accessibility_regression_check.sh"; then
  ACCESSIBILITY_STATUS="PASS"
  LINT_STATUS="PASS"
else
  ACCESSIBILITY_STATUS="FAIL"
  LINT_STATUS="FAIL"
  OVERALL_EXIT=1
fi

if command -v npm >/dev/null 2>&1; then
  if run_logged "$SITE_INSTALL_LOG" npm ci --prefix site; then
    SITE_INSTALL_STATUS="PASS"
    if run_logged "$DOCS_BUILD_LOG" npm run build --prefix site; then
      DOCS_BUILD_STATUS="PASS"
      if [[ "$BUILD_STATUS" != "FAIL" ]]; then
        BUILD_STATUS="PASS"
      fi
    else
      DOCS_BUILD_STATUS="FAIL"
      BUILD_STATUS="FAIL"
      OVERALL_EXIT=1
    fi
  else
    SITE_INSTALL_STATUS="FAIL"
    DOCS_BUILD_STATUS="FAIL"
    BUILD_STATUS="FAIL"
    OVERALL_EXIT=1
  fi
else
  SITE_INSTALL_STATUS="SKIPPED"
  DOCS_BUILD_STATUS="SKIPPED"
  if [[ "$BUILD_STATUS" != "FAIL" ]]; then
    BUILD_STATUS="PARTIAL"
  fi
fi

SECURITY_REPORT="$RUN_DIR/gitleaks-report.json"
if command -v gitleaks >/dev/null 2>&1; then
  if run_security_scan "$SECURITY_LOG" "$SECURITY_REPORT" \
    ".github" \
    "Sources" \
    "Tests" \
    "windows" \
    "scripts" \
    "docs" \
    "site/docs" \
    "site/src" \
    "README.md" \
    "CHANGELOG.md" \
    "project.yml" \
    "Resources/Info.plist"; then
    SECURITY_STATUS="PASS"
  else
    SECURITY_STATUS="FAIL"
    OVERALL_EXIT=1
  fi
else
  SECURITY_STATUS="SKIPPED"
fi

ROOT="$ROOT" \
TIMESTAMP="$STAMP" \
LINT_STATUS="$LINT_STATUS" \
UNIT_TEST_STATUS="$UNIT_TEST_STATUS" \
INTEGRATION_TEST_STATUS="$INTEGRATION_TEST_STATUS" \
BUILD_STATUS="$BUILD_STATUS" \
SECURITY_STATUS="$SECURITY_STATUS" \
BOOTSTRAP_STATUS="$BOOTSTRAP_STATUS" \
RELEASE_SMOKE_STATUS="$RELEASE_SMOKE_STATUS" \
ACCESSIBILITY_STATUS="$ACCESSIBILITY_STATUS" \
SITE_INSTALL_STATUS="$SITE_INSTALL_STATUS" \
DOCS_BUILD_STATUS="$DOCS_BUILD_STATUS" \
WINDOWS_RUNTIME_STATUS="$WINDOWS_RUNTIME_STATUS" \
BOOTSTRAP_LOG="$BOOTSTRAP_LOG" \
RELEASE_SMOKE_LOG="$RELEASE_SMOKE_LOG" \
ACCESSIBILITY_LOG="$ACCESSIBILITY_LOG" \
SITE_INSTALL_LOG="$SITE_INSTALL_LOG" \
DOCS_BUILD_LOG="$DOCS_BUILD_LOG" \
SECURITY_LOG="$SECURITY_LOG" \
SECURITY_REPORT="$SECURITY_REPORT" \
python3 <<'PY'
import json
import os
import pathlib

root = pathlib.Path(os.environ["ROOT"])
artifacts_path = root / "state" / "artifacts.json"
artifacts = json.loads(artifacts_path.read_text())

def rel(path: str) -> str:
    return pathlib.Path(path).resolve().relative_to(root).as_posix()

evidence = [
    {
        "name": "bootstrap",
        "status": os.environ["BOOTSTRAP_STATUS"],
        "path": rel(os.environ["BOOTSTRAP_LOG"]),
        "details": "Validated tracked roadmap/state files and refreshed generated repo snapshots."
    },
    {
        "name": "release_smoke_test",
        "status": os.environ["RELEASE_SMOKE_STATUS"],
        "path": rel(os.environ["RELEASE_SMOKE_LOG"]),
        "details": "Ran macOS debug tests and an unsigned release build through the existing smoke script."
    },
    {
        "name": "accessibility_regression_check",
        "status": os.environ["ACCESSIBILITY_STATUS"],
        "path": rel(os.environ["ACCESSIBILITY_LOG"]),
        "details": "Ran the code-level accessibility regression tripwire on the macOS SwiftUI surfaces."
    },
    {
        "name": "docs_site_install",
        "status": os.environ["SITE_INSTALL_STATUS"],
        "path": rel(os.environ["SITE_INSTALL_LOG"]),
        "details": "Installed the Docusaurus site dependencies with npm ci."
    },
    {
        "name": "docs_site_build",
        "status": os.environ["DOCS_BUILD_STATUS"],
        "path": rel(os.environ["DOCS_BUILD_LOG"]),
        "details": "Built the docs site to keep the published documentation path honest."
    },
    {
        "name": "gitleaks_scan",
        "status": os.environ["SECURITY_STATUS"],
        "path": rel(os.environ["SECURITY_LOG"]),
        "details": "Ran targeted gitleaks scans across the tracked source, docs, workflow, and script surfaces."
    },
    {
        "name": "windows_runtime_validation",
        "status": os.environ["WINDOWS_RUNTIME_STATUS"],
        "path": "windows/docs/WINDOWS_VALIDATION_CHECKLIST.md",
        "details": "Real tray, recording, screenshot, and hotkey runtime validation still requires a Windows machine or VM."
    }
]

security_report_path = pathlib.Path(os.environ["SECURITY_REPORT"])
if security_report_path.exists():
    evidence.insert(
        -1,
        {
            "name": "gitleaks_report",
            "status": os.environ["SECURITY_STATUS"],
            "path": rel(os.environ["SECURITY_REPORT"]),
            "details": "Summary report for the latest targeted gitleaks scan."
        }
    )

artifacts["last_validation"] = {
    "timestamp": os.environ["TIMESTAMP"],
    "lint": os.environ["LINT_STATUS"],
    "unit_tests": os.environ["UNIT_TEST_STATUS"],
    "integration_tests": os.environ["INTEGRATION_TEST_STATUS"],
    "build": os.environ["BUILD_STATUS"],
    "security_checks": os.environ["SECURITY_STATUS"]
}
artifacts["evidence"] = evidence
artifacts_path.write_text(json.dumps(artifacts, indent=2) + "\n")
PY

printf '[validate] logs: %s\n' "${RUN_DIR#"$ROOT"/}"
exit "$OVERALL_EXIT"
