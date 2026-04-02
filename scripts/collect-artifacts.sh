#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
ROOT="$(cd "$ROOT" && pwd)"
cd "$ROOT"

ROOT="$ROOT" python3 <<'PY'
import hashlib
import json
import pathlib

root = pathlib.Path(__import__("os").environ["ROOT"])
artifacts_path = root / "state" / "artifacts.json"
artifacts = json.loads(artifacts_path.read_text())

existing = [item for item in artifacts.get("evidence", []) if not str(item.get("name", "")).startswith("artifact:")]

def record(path: pathlib.Path) -> dict[str, str]:
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    size_bytes = path.stat().st_size
    return {
        "name": f"artifact: {path.name}",
        "status": "GENERATED",
        "path": path.relative_to(root).as_posix(),
        "details": f"size_bytes={size_bytes} sha256={digest}"
    }

artifact_entries: list[dict[str, str]] = []
for candidate in sorted((root / "dist").glob("BugNarrator*-macOS.dmg")):
    if candidate.is_file():
        artifact_entries.append(record(candidate))

release_summary = root / "build" / "release-summary.md"
if release_summary.is_file():
    artifact_entries.append(record(release_summary))

artifacts["evidence"] = existing + artifact_entries
artifacts_path.write_text(json.dumps(artifacts, indent=2) + "\n")

if artifact_entries:
    for item in artifact_entries:
        print(f"[collect-artifacts] recorded {item['path']}")
else:
    print("[collect-artifacts] no local build artifacts found to record")
PY
