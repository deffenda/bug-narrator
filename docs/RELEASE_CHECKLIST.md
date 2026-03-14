# BugNarrator Release Checklist

Use this checklist before cutting a public test build or release candidate.

## Build And Signing

- Regenerate the project with `xcodegen generate` if `project.yml` changed.
- Build the app in the intended configuration and confirm the build succeeds.
- If shipping a signed build, verify the Apple signing team, bundle identifier, and entitlements are correct.
- Launch the built app and confirm the menu bar item appears.

## Core Product Workflow

- Add or validate an OpenAI API key in Settings.
- Start a recording session and confirm the app enters `Recording`.
- Insert at least one marker and capture at least one screenshot during the session.
- Stop the session and confirm transcription succeeds.
- Confirm the transcript, review summary, screenshots, and extracted issues appear in the session library.
- Export a session bundle and verify the expected files are created.

## Export Integrations

- Verify GitHub export stays disabled until configuration is complete.
- Export at least one issue to GitHub with a working repository/token pair.
- Verify Jira export stays disabled until configuration is complete.
- Export at least one issue to Jira Cloud with a working project/token pair.
- Exercise at least one invalid-config or invalid-auth path for each provider and confirm the error message is clear.

## Heavy-Use Library Checks

- Confirm `Today`, `Yesterday`, `Last 7 Days`, `Last 30 Days`, and `All Sessions` all behave correctly.
- Use a custom date range and confirm the session list updates immediately.
- Search by transcript text or summary text and confirm results narrow correctly.
- Delete a session and confirm the list, counts, and detail pane update immediately.

## Artifact And Persistence Safety

- Quit and relaunch the app and confirm existing sessions reload correctly.
- Delete a session with screenshots and verify the local managed screenshot folder is removed.
- Confirm exported bundles outside the app remain untouched after deletion.
- In non-debug mode, verify temporary audio files are cleaned up after success, failure, and cancellation.
- In debug mode, verify temporary audio files are retained intentionally.

## Product Surfaces

- Open `About BugNarrator` and verify version/build info is correct.
- Open `View Documentation`, `Report an Issue`, `Support Development`, `What's New`, and `Check for Updates`.
- Confirm every link opens the expected external destination.
- Review the README, user guide, changelog, and support links for stale wording or placeholder text.

## Before Publishing

- Confirm no secrets, tokens, personal paths, or local-only files are tracked in git.
- Review `.gitignore` for generated Xcode data and result bundles.
- Run the automated test suite and confirm it passes.
- Note any known limitations in the release notes or changelog before publishing.
