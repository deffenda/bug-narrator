import SwiftUI

struct MenuBarView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var transcriptStore: TranscriptStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            statusCard
            if appState.needsAPIKeySetup {
                apiKeyRequirementCard
            }
            controlsSection

            if let latestSession = transcriptStore.sessions.first {
                latestTranscriptCard(session: latestSession)
            }

            productInfoSection
            footerSection
        }
        .padding(16)
        .frame(width: 340)
        .alert("Discard this recording?", isPresented: $appState.showDiscardConfirmation) {
            Button("Discard", role: .destructive) {
                Task {
                    await appState.cancelSession()
                }
            }

            Button("Keep Recording", role: .cancel) {
                appState.showDiscardConfirmation = false
            }
        } message: {
            Text("The current audio file will be deleted and the session will not be transcribed.")
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("BugNarrator")
                    .font(.headline)

                Spacer()

                Text(appState.status.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(statusTint)
            }

            if appState.status.phase == .recording {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)

                        Text("Recording in progress")
                            .font(.subheadline.weight(.medium))

                        Spacer()

                        Text(appState.elapsedTimeString)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                    }

                    if let detail = appState.status.detail {
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else if appState.status.phase == .transcribing {
                HStack(spacing: 10) {
                    ProgressView()
                        .controlSize(.small)
                    Text(appState.status.detail ?? "Uploading audio and waiting for transcription...")
                        .font(.subheadline)
                }
            } else if let detail = appState.status.detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(statusTint)
            } else {
                Text("Ready for a spoken software review session.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

        }
        .padding(14)
        .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var apiKeyRequirementCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Bring Your Own OpenAI API Key", systemImage: "key.horizontal.fill")
                .font(.subheadline.weight(.semibold))

            Text("BugNarrator sends transcription requests to the OpenAI API. Add your own API key in Settings before your first session. OpenAI usage may incur charges on your account.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Open Settings") {
                appState.openSettings()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(14)
        .background(.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch appState.status.phase {
            case .idle, .success, .error:
                if appState.needsAPIKeySetup {
                    Button("Add OpenAI API Key") {
                        appState.openSettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Text("Recording is disabled until you add your own OpenAI API key in Settings.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Button("Start Feedback Session") {
                        Task {
                            await appState.startSession()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

            case .recording:
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Button("Stop Feedback Session") {
                            Task {
                                await appState.stopSession()
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Cancel Session") {
                            appState.requestSessionCancel()
                        }
                        .buttonStyle(.bordered)
                    }

                    HStack {
                        Button("Insert Marker") {
                            Task {
                                await appState.insertMarker()
                            }
                        }
                        .buttonStyle(.bordered)

                        Button("Capture Screenshot") {
                            Task {
                                await appState.captureScreenshot()
                            }
                        }
                        .buttonStyle(.bordered)
                    }

                    Text("\(appState.activeMarkerCount) markers  •  \(appState.activeScreenshotCount) screenshots")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

            case .transcribing:
                Text("Audio is being uploaded to OpenAI for transcription.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Session hotkey: \(appState.settingsStore.recordingHotkeyShortcut.displayString)")
                Text("Marker hotkey: \(appState.settingsStore.markerHotkeyShortcut.displayString)")
                Text("Screenshot hotkey: \(appState.settingsStore.screenshotHotkeyShortcut.displayString)")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    private func latestTranscriptCard(session: TranscriptSession) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Latest Saved Transcript")
                .font(.subheadline.weight(.semibold))

            Text(session.metadataSummary)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(session.preview)
                .font(.subheadline)
                .lineLimit(3)

            if let issueExtraction = session.issueExtraction {
                Text("\(issueExtraction.issues.count) extracted issues ready")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button("Open Transcript Window") {
                appState.openTranscriptHistory()
            }
            .buttonStyle(.link)
        }
        .padding(14)
        .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var footerSection: some View {
        HStack(spacing: 10) {
            Button("Settings") {
                appState.openSettings()
            }

            Button("About") {
                appState.openAbout()
            }

            Spacer()

            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
    }

    private var productInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Project Info")
                .font(.subheadline.weight(.semibold))

            infoButton(
                title: "About BugNarrator",
                systemImage: "info.circle",
                accessibilityLabel: "Open the BugNarrator about window",
                action: appState.openAbout
            )

            infoButton(
                title: "What’s New",
                systemImage: "sparkles.rectangle.stack",
                accessibilityLabel: "Open the BugNarrator changelog",
                action: appState.openChangelog
            )

            Divider()

            infoButton(
                title: "View Documentation",
                systemImage: "book.closed",
                accessibilityLabel: "Open the BugNarrator documentation",
                action: appState.openDocumentation
            )

            infoButton(
                title: "Report an Issue",
                systemImage: "ladybug",
                accessibilityLabel: "Open the BugNarrator issue tracker",
                action: appState.openIssueReporter
            )

            infoButton(
                title: "Support Development",
                systemImage: "heart",
                accessibilityLabel: "Open the BugNarrator support development window",
                action: appState.openSupportDevelopment
            )

            infoButton(
                title: "Check for Updates",
                systemImage: "arrow.clockwise",
                accessibilityLabel: "Open the BugNarrator releases page",
                action: appState.checkForUpdates
            )
        }
        .padding(14)
        .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func infoButton(
        title: String,
        systemImage: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Label(title, systemImage: systemImage)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "arrow.up.forward")
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var statusTint: Color {
        switch appState.status.phase {
        case .idle:
            return .secondary
        case .recording:
            return .red
        case .transcribing:
            return .orange
        case .success:
            return .green
        case .error:
            return .red
        }
    }
}
