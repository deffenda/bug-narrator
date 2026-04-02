#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
ROOT="$(cd "$ROOT" && pwd)"
cd "$ROOT"

NOW="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
OS_NAME="$(uname -s || true)"
SHELL_NAME="${SHELL:-}"
NODE_VER="$(command -v node >/dev/null 2>&1 && node --version || echo '')"
NPM_VER="$(command -v npm >/dev/null 2>&1 && npm --version || echo '')"
PYTHON_VER="$(command -v python3 >/dev/null 2>&1 && python3 --version || echo '')"
GIT_VER="$(command -v git >/dev/null 2>&1 && git --version || echo '')"
WORKDIR="$ROOT"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || printf '%s' "$ROOT")"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
COMMIT="$(git rev-parse HEAD 2>/dev/null || echo '')"
PACKAGE_NAME=""
PACKAGE_VERSION=""

if [[ -f "$ROOT/package.json" ]]; then
  PACKAGE_NAME="$(python3 -c 'import json, sys; data = json.load(open(sys.argv[1])); print(data.get("name", ""))' "$ROOT/package.json" 2>/dev/null || echo '')"
  PACKAGE_VERSION="$(python3 -c 'import json, sys; data = json.load(open(sys.argv[1])); print(data.get("version", ""))' "$ROOT/package.json" 2>/dev/null || echo '')"
fi

if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
  DIRTY=false
else
  DIRTY=true
fi

ROOT="$ROOT" NOW="$NOW" OS_NAME="$OS_NAME" SHELL_NAME="$SHELL_NAME" NODE_VER="$NODE_VER" NPM_VER="$NPM_VER" PYTHON_VER="$PYTHON_VER" GIT_VER="$GIT_VER" WORKDIR="$WORKDIR" REPO_ROOT="$REPO_ROOT" BRANCH="$BRANCH" COMMIT="$COMMIT" DIRTY="$DIRTY" PACKAGE_NAME="$PACKAGE_NAME" PACKAGE_VERSION="$PACKAGE_VERSION" NODE_ENV="${NODE_ENV:-}" CI="${CI:-}" python3 <<'PY'
import json
import os
import pathlib

root = pathlib.Path(os.environ["ROOT"])

env_state = {
    "generated_at": os.environ["NOW"],
    "node_env": os.environ["NODE_ENV"] or None,
    "ci": os.environ["CI"] or None,
    "tool_versions": {
        "node": os.environ["NODE_VER"] or None,
        "npm": os.environ["NPM_VER"] or None,
        "python3": os.environ["PYTHON_VER"] or None,
        "git": os.environ["GIT_VER"] or None,
    },
    "system": {
        "os": os.environ["OS_NAME"] or None,
        "shell": os.environ["SHELL_NAME"] or None,
        "working_directory": os.environ["WORKDIR"],
    },
}

repo_state = {
    "generated_at": os.environ["NOW"],
    "repo_root": os.environ["REPO_ROOT"],
    "branch": os.environ["BRANCH"] or None,
    "commit": os.environ["COMMIT"] or None,
    "dirty": os.environ["DIRTY"].lower() == "true",
    "name": os.environ["PACKAGE_NAME"] or root.name,
    "version": os.environ["PACKAGE_VERSION"] or None,
}

(root / "state" / "env.json").write_text(json.dumps(env_state, indent=2) + "\n")
(root / "state" / "repo.json").write_text(json.dumps(repo_state, indent=2) + "\n")
PY

printf 'WROTE: %s\n' "$ROOT/state/env.json"
printf 'WROTE: %s\n' "$ROOT/state/repo.json"
