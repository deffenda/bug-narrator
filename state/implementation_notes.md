# Implementation Notes

task_id: T2
status: completed

CHANGED:
- `Sources/BugNarrator/Services/SettingsStore.swift`
- `Tests/BugNarratorTests/DebugBundleExporterTests.swift`
- `Tests/BugNarratorTests/SettingsStoreTests.swift`
- `Tests/BugNarratorTests/TestSupport.swift`

DID:
- Removed the implicit `SystemLaunchAtLoginService()` default from `SettingsStore` so launch-at-login wiring is chosen explicitly by the composition root.
- Kept production wiring in `AppBootstrap` and updated test-only call sites to inject `TestingLaunchAtLoginService()` or a targeted mock.
- Addressed the PR #5 review feedback about environment-specific service selection living outside the settings store.

VALIDATED:
- `git diff --check`
- `./scripts/validate.sh 9a0048fc6397f1be3086b3753b2afa4a912399d2`
- `xcodebuild -project BugNarrator.xcodeproj -scheme BugNarrator -configuration Debug CODE_SIGNING_ALLOWED=NO -derivedDataPath /tmp/bugnarrator-settings-tests test -only-testing:BugNarratorTests/SettingsStoreTests`

NEXT:
- Push `codex/t2-follow-up-pr-5-failures`, open the follow-up PR, and collect the next GitHub review pass.
