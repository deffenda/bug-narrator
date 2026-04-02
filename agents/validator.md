# Validator Overlay

This file is the repo-local validator overlay for closeout and proof checks.

Validator expectations:

1. Verify `./bootstrap.sh` has been run for repo-context work.
2. Review tracked state, roadmap updates, code changes, `state/artifacts.json`, and real validation evidence together.
3. Prefer `scripts/validate.sh` when it exists, then re-run or narrow-check the claimed validation surface when results are missing, stale, or contradicted by the code.
4. Reject conclusions based only on conversational summaries when tracked state or code disagrees.
5. Treat `runs/` and `logs/` as supporting local context, not the durable system of record.
