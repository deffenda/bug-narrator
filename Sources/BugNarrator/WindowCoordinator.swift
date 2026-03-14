import AppKit
import SwiftUI

@MainActor
final class WindowCoordinator {
    private let appState: AppState
    private let transcriptStore: TranscriptStore
    private let settingsStore: SettingsStore

    private var transcriptWindowController: NSWindowController?
    private var settingsWindowController: NSWindowController?
    private var aboutWindowController: NSWindowController?
    private var changelogWindowController: NSWindowController?
    private var supportWindowController: NSWindowController?

    init(appState: AppState, transcriptStore: TranscriptStore, settingsStore: SettingsStore) {
        self.appState = appState
        self.transcriptStore = transcriptStore
        self.settingsStore = settingsStore
    }

    func showTranscriptWindow() {
        if let transcriptWindowController {
            present(transcriptWindowController)
            return
        }

        let rootView = TranscriptView(appState: appState, transcriptStore: transcriptStore)
        let windowController = NSWindowController(
            window: makeWindow(
                title: "BugNarrator Sessions",
                size: NSSize(width: 1120, height: 720),
                rootView: rootView
            )
        )

        transcriptWindowController = windowController
        present(windowController)
    }

    func showSettingsWindow() {
        if let settingsWindowController {
            present(settingsWindowController)
            return
        }

        let rootView = SettingsView(appState: appState, settingsStore: settingsStore)
        let windowController = NSWindowController(
            window: makeWindow(
                title: "BugNarrator Settings",
                size: NSSize(width: 760, height: 900),
                rootView: rootView
            )
        )

        settingsWindowController = windowController
        present(windowController)
    }

    func showAboutWindow() {
        if let aboutWindowController {
            present(aboutWindowController)
            return
        }

        let rootView = AboutBugNarratorView(appState: appState)
        let windowController = NSWindowController(
            window: makeWindow(
                title: "About BugNarrator",
                size: NSSize(width: 620, height: 720),
                rootView: rootView
            )
        )

        aboutWindowController = windowController
        present(windowController)
    }

    func showChangelogWindow() {
        if let changelogWindowController {
            present(changelogWindowController)
            return
        }

        let rootView = ChangelogView(appState: appState)
        let windowController = NSWindowController(
            window: makeWindow(
                title: "What’s New",
                size: NSSize(width: 760, height: 760),
                rootView: rootView
            )
        )

        changelogWindowController = windowController
        present(windowController)
    }

    func showSupportWindow() {
        if let supportWindowController {
            present(supportWindowController)
            return
        }

        let rootView = SupportView(appState: appState)
        let windowController = NSWindowController(
            window: makeWindow(
                title: "Support BugNarrator",
                size: NSSize(width: 520, height: 460),
                rootView: rootView
            )
        )

        supportWindowController = windowController
        present(windowController)
    }

    private func present(_ windowController: NSWindowController) {
        windowController.showWindow(nil)
        windowController.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func makeWindow<Content: View>(title: String, size: NSSize, rootView: Content) -> NSWindow {
        let hostingController = NSHostingController(rootView: rootView)
        let window = NSWindow(contentViewController: hostingController)

        window.title = title
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(size)
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.fullScreenAuxiliary]
        window.center()

        return window
    }
}
