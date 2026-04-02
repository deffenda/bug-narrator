# Claude Overlay

This file is the repo-local Claude overlay for the adopted `enterprise-ai-standards` baseline.

Use this repo-specific flow:

1. Run `./bootstrap.sh` when repo context is required.
2. Load the tracked roadmap and state files before execution.
3. Use `state/artifacts.json` for validation status and evidence paths and `state/handoff.json` for current phase, resume point, blockers, and next actions.
4. Keep local traces in `runs/` and `logs/` only.
5. Treat these local overlays as additions to the adopted standards, not replacements.
