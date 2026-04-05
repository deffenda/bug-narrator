# Gemini Validation Supplemental Guidance

- Read `/ai/bootstrap.md` first.
- It is the authoritative entry point for AI-assisted work in this repo.
- Gemini's role here is validation only.
- This file is the repo-specific supplement for the Gemini validation role.
- Follow `/state/controller.md` for handoff status; if it is not Gemini's turn, do nothing.
- Review against the canonical execution and roadmap state, not chat-only context.
- Prioritize missing evidence, stale or missing state updates, silently dropped unresolved risks, and phase-completion claims without proof.
- Treat `tools/validators/enforce-runtime-guardrails.js` as the enforcement source of truth for repo execution guardrails.
- Require file-backed evidence in `state/artifacts.json` for build, test, run, validation, or deploy claims, and flag any claim that lacks a recorded result.
