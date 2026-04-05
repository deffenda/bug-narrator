# Acceptance Criteria

## Global acceptance rules

- Build passes
- Relevant tests pass
- No unrelated file churn
- No docs-only or state-only commit
- Changes stay within current task scope unless required for the fix

## Per-task acceptance

### T1

- the Windows baseline command completes on a real Windows machine or VM
- the live validation result is captured as PASS or FAIL in `/state/validation_report.md`

Validation commands:

- `powershell -ExecutionPolicy Bypass -File windows/scripts/invoke-windows-codex-handoff.ps1 -RunBaseline`
- `dotnet run --project windows/src/BugNarrator.Windows/BugNarrator.Windows.csproj -c Debug`

### T2

- the reported defect is no longer reproducible
- the related Windows regression coverage or manual validation has been rerun

Validation commands:

- `powershell -ExecutionPolicy Bypass -File windows/scripts/test-windows.ps1 -Configuration Debug`
- `powershell -ExecutionPolicy Bypass -File windows/scripts/validate-windows-package.ps1 -Runtime win-x64`
