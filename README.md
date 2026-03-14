# BugNarrator

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

BugNarrator is a macOS menu bar tool for narrated software testing sessions that automatically captures transcripts, markers, screenshots, and extracted issues.

## Status

BugNarrator is an early but functional macOS utility. The current app supports:

- background microphone recording from the menu bar
- OpenAI transcription after the session ends
- timeline markers during a live review
- screenshot capture during a live review
- a session library with date filters, search, sort, and deletion
- draft issue extraction from the transcript
- export of selected issues to GitHub Issues and Jira Cloud

## What It Does

BugNarrator is designed for software-review workflows where you are actively clicking around another product while speaking aloud.

Core workflow:

1. Launch BugNarrator from Xcode.
2. Add your own OpenAI API key in Settings.
3. Start a feedback session from the menu bar or session hotkey.
4. Keep reviewing the target app normally with your keyboard and mouse.
5. Insert markers and screenshots whenever you hit an important moment.
6. Stop the session.
7. BugNarrator uploads the finished audio to OpenAI for transcription.
8. Review the transcript, markers, screenshots, and extracted issues in the session library window.
9. Export the session bundle or selected issues when needed.

## Bring Your Own OpenAI API Key

BugNarrator does not include a built-in OpenAI API key.

Every user must provide their own key in Settings before transcription or issue extraction will work.

Important:

- transcription uses the OpenAI API, not a local Whisper model
- issue extraction also uses the OpenAI API
- OpenAI usage may cost money on your account
- the app stores your key in macOS Keychain when available
- the app does not embed your key in source control or the compiled app

## Screenshots

Add screenshots here before publishing the repo:

- menu bar idle state
- menu bar recording state with live marker and screenshot controls
- settings window with OpenAI, GitHub, and Jira configuration
- session library showing sidebar filters, session list, and detail pane tabs

## About And Support

BugNarrator includes a dedicated About window from the menu bar so users can quickly find product info, version details, release notes, and support links.

- GitHub repository: [github.com/abdenterprises/bugnarrator](https://github.com/abdenterprises/bugnarrator)
- User documentation: [Open the user guide](docs/UserGuide.md)
- Documentation link in the app: [Read the hosted user guide](https://github.com/abdenterprises/bugnarrator/blob/main/docs/UserGuide.md)
- Report an issue: [Open a new GitHub issue](https://github.com/abdenterprises/bugnarrator/issues/new)
- Releases / manual update checks: [GitHub Releases](https://github.com/abdenterprises/bugnarrator/releases)
- Changelog: [`CHANGELOG.md`](CHANGELOG.md)
- Support development: the About window and menu bar include a dedicated donation screen with PayPal donation buttons

## Requirements

- macOS 14.0 or later
- Xcode 26.3 or later recommended
- an OpenAI API key with access to audio transcription
- microphone permission
- Screen Recording permission if you want screenshot capture
- optional GitHub personal access token for GitHub export
- optional Jira Cloud credentials for Jira export

## Repo Layout

- `BugNarrator.xcodeproj`: generated Xcode project
- `project.yml`: XcodeGen project definition
- `Sources/BugNarrator`: app source
- `Resources`: app resources including `Info.plist`
- `docs/UserGuide.md`: user-facing product guide
- `docs/QA_CHECKLIST.md`: manual QA checklist
- `docs/TESTING_NOTES.md`: testing notes
- `docs/RELEASE_CHECKLIST.md`: release-readiness checklist
- `Tests/BugNarratorTests`: automated tests

## User Documentation

Full end-user documentation lives in [docs/UserGuide.md](docs/UserGuide.md).

That guide is written for normal BugNarrator users and covers installation, permissions, narrated sessions, markers, screenshots, issue extraction, exports, troubleshooting, privacy, and support links.

## Release Readiness

BugNarrator includes a focused release-readiness checklist in [docs/RELEASE_CHECKLIST.md](docs/RELEASE_CHECKLIST.md).

Use it before publishing a build to verify:

- app signing and launch behavior
- OpenAI key setup and transcription flow
- session-library behavior under repeated daily usage
- marker, screenshot, export, and deletion workflows
- documentation, support links, and changelog accuracy

## Setup

1. Clone the repo.
2. Open `BugNarrator.xcodeproj` in Xcode.
3. Select your own Apple signing team for local runs if needed.
4. Build and run the app.
5. Open `Settings` from the menu bar.
6. Paste your own OpenAI API key into `OpenAI API Key`.
7. Optionally click `Validate Key`.

If you change the project definition, regenerate the Xcode project with:

```bash
xcodegen generate
```

## Run Locally

Build:

```bash
xcodebuild -project BugNarrator.xcodeproj -scheme BugNarrator -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

Test:

```bash
xcodebuild -project BugNarrator.xcodeproj -scheme BugNarrator -configuration Debug CODE_SIGNING_ALLOWED=NO test
```

## Configure BugNarrator

### OpenAI

Open `Settings` from the menu bar and configure:

- `OpenAI API Key`
- transcription model, default `whisper-1`
- optional language hint
- optional transcription prompt
- issue extraction model
- optional automatic issue extraction after transcription

### Hotkeys

BugNarrator supports separate global hotkeys for:

- starting or stopping a feedback session
- inserting a marker
- capturing a screenshot

These use Carbon hotkeys and do not require Accessibility access.

### GitHub Export

To export selected extracted issues to GitHub Issues, configure:

- GitHub personal access token
- repository owner
- repository name
- optional default labels

The token is stored in Keychain when available.

### Jira Export

To export selected extracted issues to Jira Cloud, configure:

- Jira Cloud base URL
- Jira email
- Jira API token
- Jira project key
- Jira issue type

The Jira token is stored in Keychain when available.

## Using BugNarrator

### Start And Stop A Session

1. Open the menu bar item.
2. Click `Start Feedback Session`.
3. Speak while using your Mac normally.
4. Click `Stop Feedback Session` when you are done.

### Product Info And Help

From the menu bar, you can open:

- `About BugNarrator`
- `What’s New`
- `View Documentation`
- `Report an Issue`
- `Support Development`
- `Check for Updates`

`View Documentation` opens the hosted user guide, and `Report an Issue` opens the GitHub new-issue form in your default browser. The About window shows the current app version and build from bundle metadata, project links, and a short product summary.

### Browse The Session Library

After each completed session, BugNarrator opens a three-column session library:

- a sidebar with `Today`, `Yesterday`, `Last 7 Days`, `Last 30 Days`, `All Sessions`, and `Custom Date Range`
- a searchable session list with newest-first or oldest-first sorting
- a detail pane with raw transcript, markers, screenshots, extracted issues, and export actions

The session list is intended for heavy daily use. Each row shows the recorded time, duration, transcript preview, and counts for markers, screenshots, and extracted issues.

You can also permanently delete a session from the toolbar or the session row context menu. Deleting a session removes it from the library immediately and also removes locally stored screenshots for that session. Files you previously exported outside BugNarrator are not removed.

### Insert Markers

Use the menu bar action, session library live-review control, or marker hotkey while recording.

Each marker stores:

- elapsed session time
- created timestamp
- title
- optional note

Markers appear in the review window, session history, and transcript exports.

### Capture Screenshots

Use the menu bar action, session library live-review control, or screenshot hotkey while recording.

Each screenshot stores:

- file path
- elapsed session time
- created timestamp
- optional nearest-marker association

Screenshots appear in the review window and session bundle export.

### Review Extracted Issues

After transcription, you can run issue extraction manually or automatically.

BugNarrator creates reviewable draft issues in these categories:

- Bug
- UX Issue
- Enhancement
- Question / Follow-up

Each draft issue includes:

- title
- category
- summary
- transcript evidence excerpt
- timestamp when available
- related screenshots when available
- confidence when available
- review-needed flag

You can edit issues and choose which ones to export.

### Export

BugNarrator supports:

- `transcript.txt`
- `transcript.md`
- session bundle export with `summary.md` and `screenshots/`
- selected issue export to GitHub Issues
- selected issue export to Jira Cloud

Exports are always explicit user actions. The app does not silently create remote issues.

## Permissions

### Microphone

BugNarrator requests microphone access the first time you record. If access is denied, recording does not start and the app explains how to re-enable permission in System Settings.

### Screen Recording

Screenshot capture may prompt for Screen Recording permission on first use. If macOS blocks capture, BugNarrator keeps recording and surfaces a clear screenshot-specific error.

### Accessibility

BugNarrator does not simulate typing into other apps and does not require Accessibility permission for its core workflow.

## Local Storage

BugNarrator stores data locally in `~/Library/Application Support/BugNarrator/`.

That includes:

- transcript history
- session asset folders for screenshots
- exported bundles you explicitly create

Temporary audio files are removed after success, failure, or cancellation unless `Debug Mode` is enabled.
Deleting a saved session also removes its locally managed screenshot folder when one exists.

## Troubleshooting

### No OpenAI API key configured

Open Settings and add your own key. Recording is blocked until the key is present.

### Invalid or revoked OpenAI API key

Use `Validate Key` in Settings, then replace the key if OpenAI rejects it.

### Microphone permission denied

Re-enable microphone access for BugNarrator in macOS System Settings and try again.

### Screenshot capture failed

Check Screen Recording permission in System Settings. Recording should still continue even if a screenshot fails.

### Issue extraction failed

The raw transcript is still preserved. Retry extraction after checking your OpenAI key, model configuration, and network connection.

### GitHub export failed

Check the GitHub token, repository owner, repository name, and repository access.

### Jira export failed

Check the Jira Cloud URL, email, API token, project key, and issue type.

### Empty transcript

Verify microphone input is working and that the recording actually contains speech.

### A session is missing from the library

Check the active date filter, custom date range, and search text first. The library defaults to `Today` when possible, so older sessions may be hidden until you switch to `All Sessions` or widen the date range.

### A project-info link did not open

Try the same link from the About window. If the browser still does not open, verify your default browser configuration and confirm the URL constants in `Sources/BugNarrator/Utilities/BugNarratorLinks.swift` if you are running a local build.

## Security And Privacy

- BugNarrator requires each user to bring their own OpenAI API key
- the app does not bundle OpenAI, GitHub, or Jira credentials
- secrets are stored in Keychain when available
- audio is recorded locally first and uploaded only after you stop the session
- transcripts, markers, screenshots, and extracted issues stay local unless you explicitly export or send them to an external API

See [SECURITY.md](SECURITY.md) for more detail.

## Known Limitations

- transcription and issue extraction require network access
- there is no offline Whisper mode yet
- screenshot capture still uses a deprecated CoreGraphics capture API and should move to ScreenCaptureKit
- screenshot export references filenames in GitHub and Jira bodies rather than uploading attachments automatically
- extracted issues are drafts and must be reviewed before export
- session deletion is currently permanent; there is no recently deleted or restore flow yet

## Supporting The Project

BugNarrator is free to use. If it helps your review workflow, you can optionally support ongoing development from the in-app `Support Development` screen.

- [Donate $5](https://www.paypal.com/donate/?hosted_button_id=FWFQ6KCZBWWH8&amount=5&currency_code=USD)
- [Donate $10](https://www.paypal.com/donate/?hosted_button_id=FWFQ6KCZBWWH8&amount=10&currency_code=USD)
- [Donate $20](https://www.paypal.com/donate/?hosted_button_id=FWFQ6KCZBWWH8&amount=20&currency_code=USD)

All donations open externally in PayPal. BugNarrator does not process payments or store financial data.

## Roadmap

- improve release packaging for public distribution
- migrate screenshot capture to newer macOS APIs
- add bulk delete and recently deleted recovery for the session library
- improve issue extraction quality and evidence linking
- support attachment upload for export providers where practical

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## License

BugNarrator is licensed under the Apache License 2.0.

This license allows users to freely use, modify, and distribute the software, including for commercial purposes, as long as attribution and license terms are preserved.

See the [LICENSE](LICENSE) file for details.

Useful docs:

- [QUICKSTART.md](QUICKSTART.md)
- [SECURITY.md](SECURITY.md)
- [CHANGELOG.md](CHANGELOG.md)
- [docs/UserGuide.md](docs/UserGuide.md)
- [docs/QA_CHECKLIST.md](docs/QA_CHECKLIST.md)
- [docs/TESTING_NOTES.md](docs/TESTING_NOTES.md)
- [docs/RELEASE_CHECKLIST.md](docs/RELEASE_CHECKLIST.md)
