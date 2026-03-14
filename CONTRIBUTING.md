# Contributing

Thanks for contributing to BugNarrator.

## Local Setup

1. Open `BugNarrator.xcodeproj` in Xcode.
2. Select your own Apple signing team for local runs.
3. Use your own OpenAI API key for live transcription or issue extraction tests.
4. Use your own GitHub or Jira credentials if you want to test exports against real services.

## Expectations

- keep changes focused and easy to review
- preserve the menu bar review workflow
- prefer testable changes over broad rewrites
- keep `.xcodeproj` changes minimal unless they are required
- update docs when product behavior changes

## Secrets

- do not commit API keys or tokens
- do not add bundled OpenAI, GitHub, or Jira credentials
- do not commit personal signing identifiers unless they are intentionally generic
- do not add machine-specific paths to user-facing docs

## Testing

Before submitting changes:

- run `xcodebuild -project BugNarrator.xcodeproj -scheme BugNarrator -configuration Debug CODE_SIGNING_ALLOWED=NO test`
- run the relevant checks from `docs/QA_CHECKLIST.md`
- verify setup and failure paths when your changes touch recording, extraction, or export

## Project Generation

The project is defined in `project.yml`. If you change project structure settings, regenerate the Xcode project with:

```bash
xcodegen generate
```

## Review Workflow Features

When you touch marker, screenshot, extraction, or export code:

- keep raw transcript data separate from extracted issue drafts
- avoid silent exports or background network actions
- prefer explicit user-facing errors over silent retries
- preserve traceability from exported issues back to transcript evidence
