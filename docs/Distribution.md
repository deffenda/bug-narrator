# BugNarrator Distribution

This document explains how to build the BugNarrator release app and package it as a distributable macOS DMG.

## What This Produces

The packaging workflow creates:

- a Release build of `BugNarrator.app`
- a DMG containing `BugNarrator.app`
- an `Applications` shortcut inside the DMG
- two output filenames in `dist/`

By default you will get:

- `BugNarrator-vX.Y-macOS.dmg`
- `BugNarrator-macOS.dmg`

The non-versioned filename is useful for a stable GitHub Releases download link.

## Prerequisites

- Xcode installed
- the generated project file `BugNarrator.xcodeproj`
- `hdiutil`, which is included with macOS

If you changed `project.yml`, regenerate the Xcode project first:

```bash
xcodegen generate
```

## Quick Command

From the repository root:

```bash
./scripts/build_dmg.sh
```

## What The Script Does

The script:

1. builds the app in `Release`
2. stages `BugNarrator.app`
3. adds an `Applications` symlink
4. creates a compressed DMG
5. writes the finished artifacts to `dist/`

## Output Location

By default the script writes:

- the DMG files to `dist/`
- intermediate build data to `build/DerivedData`

## Release Signing Notes

The script defaults to:

```bash
CODE_SIGNING_ALLOWED=NO
```

This makes the packaging workflow reproducible on machines that do not have Apple signing configured.

For a public release, you should normally:

1. configure your Apple signing team in Xcode
2. build with signing enabled
3. notarize the final release artifact if you plan to distribute it broadly

You can override the script behavior if needed. For a locally signed build using the configured Apple team:

```bash
CODE_SIGNING_ALLOWED=YES \
CODE_SIGN_STYLE=Automatic \
DEVELOPMENT_TEAM=YOURTEAMID \
ALLOW_PROVISIONING_UPDATES=YES \
./scripts/build_dmg.sh
```

That produces a signed app inside the DMG if your local machine has a valid signing identity for that team.

For broad public distribution outside your own Mac, prefer a `Developer ID Application` certificate and notarization. An `Apple Development` signature is better than unsigned for local validation, but it is not the final distribution-quality setup.

## Releasing On GitHub

Recommended flow:

1. run `./scripts/build_dmg.sh`
2. create a GitHub Release
3. upload `dist/BugNarrator-macOS.dmg`
4. optionally upload the versioned `dist/BugNarrator-vX.Y-macOS.dmg`
5. update release notes and changelog if needed

## Verify The DMG

After building:

1. open the DMG in Finder
2. confirm `BugNarrator.app` is present
3. confirm the `Applications` shortcut is present
4. drag the app into `Applications`
5. launch the installed app and verify first-run behavior

## Related Docs

- [README.md](../README.md)
- [Quickstart](../QUICKSTART.md)
- [Release Checklist](RELEASE_CHECKLIST.md)
