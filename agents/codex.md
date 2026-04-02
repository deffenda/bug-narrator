# Codex Overlay

This file is the repo-local Codex overlay for the adopted `enterprise-ai-standards` baseline.

Use this repo-specific flow:

1. Run `./bootstrap.sh` when repo context is required.
2. Read `docs/roadmap/state.json` plus `state/session.json`, `state/tasks.json`, `state/risks.json`, `state/decisions.json`, `state/artifacts.json`, and `state/handoff.json` before material work.
3. Treat `state/env.json` and `state/repo.json` as generated local snapshots.
4. Keep transient artifacts in `runs/` and `logs/`, not in tracked markdown dumps.
5. Update tracked state and roadmap files when the work changes the repo's actual status.
