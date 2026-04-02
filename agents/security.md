# Security Overlay

This file is the repo-local security overlay for security-sensitive work and release checks.

Security expectations:

1. Verify `./bootstrap.sh` has been run for repo-context work.
2. Review `state/risks.json`, `state/artifacts.json`, and `state/handoff.json` before security-sensitive work or release claims.
3. Check secrets handling, auth or access-control changes, dependency or runtime risk, and unsafe local-only assumptions.
4. Record open security blockers or missing evidence in tracked state instead of leaving them only in chat history.
5. Treat `runs/` and `logs/` as supporting local context, not the durable system of record.
