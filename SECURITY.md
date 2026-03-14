# Security Notes

## Credentials

BugNarrator uses a bring-your-own-credentials model.

- the app does not ship with a shared OpenAI API key
- the app does not ship with bundled GitHub or Jira credentials
- users provide their own OpenAI, GitHub, and Jira secrets in Settings
- secrets are stored in macOS Keychain when available
- if Keychain storage is unavailable, secrets are kept only in memory for the current run

Do not commit real keys, tokens, or local override files.

## What Is Sent To OpenAI

BugNarrator sends data to OpenAI only when you trigger an OpenAI-backed action.

That includes:

- recorded session audio after you stop a session and request transcription
- transcript, markers, and screenshot references when you run issue extraction

The app does not stream live dictation into other apps and does not upload audio continuously while you are still recording.

## What Is Sent To GitHub Or Jira

GitHub or Jira data is sent only when you explicitly export selected extracted issues.

That may include:

- issue title
- issue summary
- transcript evidence excerpt
- timestamps
- screenshot filenames and attachment guidance

The app does not silently create remote issues.

## Local Data

BugNarrator stores these items locally on your Mac:

- transcript history
- markers and screenshot metadata inside saved sessions
- captured screenshot files
- exported transcript bundles
- temporary audio files until cleanup

Temporary audio files are removed after success, failure, or cancellation unless `Debug Mode` is enabled.

## Logging Expectations

BugNarrator should never log:

- OpenAI API keys
- GitHub tokens
- Jira API tokens
- raw Authorization headers

When changing networking code, keep request logging disabled or carefully redacted.

## Reporting Security Concerns

If you find a security issue, avoid posting secrets or exploit details in a public issue. Report the concern privately to the maintainer first.
