# BugNarrator User Guide

BugNarrator is a macOS menu bar app for narrated software testing sessions. It lets you speak through a workflow while you click around a product, then turns that session into a transcript, supporting evidence, and draft issues you can review or export.

## Getting Help

- Report a Bug: [GitHub Issue Form](https://github.com/abdenterprises/bugnarrator/issues/new)
- Request a Feature: [GitHub Issue Form](https://github.com/abdenterprises/bugnarrator/issues/new)
- Documentation: [User Guide](https://github.com/abdenterprises/bugnarrator/blob/main/docs/UserGuide.md)
- Support Development: [Support BugNarrator](https://www.paypal.com/donate/?hosted_button_id=FWFQ6KCZBWWH8)

## Introduction

BugNarrator helps developers, testers, and product owners narrate software walkthroughs, preserve evidence from what they saw on screen, and turn spoken testing notes into actionable review output.

Use it when you want to:

- record a narrated test pass without typing live notes
- capture timestamps for moments that matter
- save screenshots while you keep talking
- review a complete transcript after the session ends
- extract draft bugs, UX issues, enhancements, and follow-up questions
- export issues to GitHub Issues or Jira Cloud

## Installation

Run BugNarrator by opening the app from Xcode or from a signed build you trust.

Requirements:

- macOS 14 or later
- microphone access
- Screen Recording permission if you want screenshot capture
- your own OpenAI API key for transcription and issue extraction

When you start your first session, macOS may ask for microphone permission. BugNarrator cannot record narrated sessions without it.

If you use screenshots during sessions, macOS may also ask for Screen Recording permission. BugNarrator uses that permission only to capture screenshots you explicitly request.

## Getting Started

1. Launch BugNarrator and confirm the menu bar icon appears.
2. Open `Settings`.
3. Paste your own `OpenAI API Key`.
4. Start a session with `Start Feedback Session`.
5. Speak naturally while using the product you are reviewing.
6. Stop the session with `Stop Feedback Session`.
7. Wait for transcription to finish.
8. Review the completed session in the session library.

BugNarrator does not ship with a built-in OpenAI API key. Transcription and issue extraction use your own OpenAI account and may incur charges based on OpenAI pricing.

## Core Features

### Recording Narrated Testing Sessions

Start a session from the menu bar or with the configured recording hotkey. Recording continues while you switch apps, click, type, and navigate normally.

### Transcript Generation

When you stop a session, BugNarrator uploads the recorded audio to the OpenAI transcription API and generates a transcript after the session ends. The transcript is then shown in the session library and can be copied or exported.

### Markers

Insert markers during a live session to mark important moments. Markers save the elapsed session time and appear in the transcript review window and exports.

### Screenshot Capture

Capture screenshots during recording without interrupting the session. Screenshots are stored with the session and shown in the review UI.

### Review Summary

Each session can include a summary view so you can quickly understand what happened before reading the full transcript.

### Issue Extraction

Run issue extraction after transcription to generate reviewable draft issues. BugNarrator groups these into categories such as:

- Bug
- UX Issue
- Enhancement
- Question / Follow-up

These are draft issues. Review them before export.

### Export Session Bundle

Export a local session bundle when you want a portable copy of the session output. This can include:

- `transcript.txt`
- `transcript.md`
- `summary.md`
- `screenshots/`

### Export To GitHub

Select extracted issues and export them to GitHub Issues after configuring your repository owner, repository name, and personal access token in Settings.

### Export To Jira

Select extracted issues and export them to Jira Cloud after configuring your Jira base URL, email, API token, project key, and issue type in Settings.

## Session Library

BugNarrator keeps your sessions in a library designed for repeated daily use.

You can:

- browse `Today`, `Yesterday`, `Last 7 Days`, `Last 30 Days`, or `All Sessions`
- set a custom date range
- search transcript content, titles, and summaries
- sort newest first or oldest first
- open a session detail pane for transcript, markers, screenshots, extracted issues, and export actions
- delete sessions you no longer need

Deleting a session removes it from the library immediately and removes local screenshot files associated with that session. Exported files outside BugNarrator are not removed.

## Exporting Results

### Export Session Bundle

Use this when you want a local package of the session transcript and screenshots for review, sharing, or archival.

### GitHub Issue Export

Use GitHub export when you want selected extracted issues turned into GitHub Issues with transcript evidence and timestamps included in the body.

### Jira Issue Export

Use Jira export when you want selected extracted issues turned into Jira issues with transcript evidence and timestamps included in the description.

## Support Development

BugNarrator includes an optional support screen for users who want to fund ongoing development. Donations are optional and are separate from any OpenAI usage charges.

- [Donate $5](https://www.paypal.com/donate/?hosted_button_id=FWFQ6KCZBWWH8&amount=5&currency_code=USD)
- [Donate $10](https://www.paypal.com/donate/?hosted_button_id=FWFQ6KCZBWWH8&amount=10&currency_code=USD)
- [Donate $20](https://www.paypal.com/donate/?hosted_button_id=FWFQ6KCZBWWH8&amount=20&currency_code=USD)

## Troubleshooting

### No Transcript Generated

- confirm your OpenAI API key is set in Settings
- confirm the key is valid
- confirm the Mac has network access
- try again with a short test recording to rule out an empty or corrupt audio file

### Microphone Permission Problems

- open macOS System Settings and verify microphone permission is granted to BugNarrator
- restart the app after changing permission settings if needed

### API Key Missing

- open `Settings`
- paste your own OpenAI API key
- use `Validate Key` if available

### Screenshots Not Appearing

- confirm a session was actively recording when the screenshot was requested
- confirm Screen Recording permission is granted if macOS asked for it
- try another screenshot to rule out a temporary permission or storage failure

### Export Errors

- for GitHub, verify the token, repository owner, and repository name
- for Jira, verify the base URL, email, API token, project key, and issue type
- confirm your network connection is available

## Privacy

BugNarrator keeps most session data local on your Mac, including:

- session history
- markers
- screenshots
- extracted issue drafts
- export configuration fields

Sensitive credentials such as API keys and tokens are stored in Keychain when available.

What is sent to OpenAI:

- recorded audio for transcription
- transcript context used for issue extraction

BugNarrator does not bundle a shared API key. Your own API key is required, and OpenAI API usage is billed to your account under OpenAI’s pricing and policies.
