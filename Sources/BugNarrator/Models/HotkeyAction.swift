import Carbon.HIToolbox
import Foundation

enum HotkeyAction: UInt32, Codable, CaseIterable, Identifiable {
    case toggleRecording = 1
    case insertMarker = 2
    case captureScreenshot = 3

    var id: UInt32 { rawValue }

    var title: String {
        switch self {
        case .toggleRecording:
            return "Start / Stop Feedback Session"
        case .insertMarker:
            return "Insert Marker"
        case .captureScreenshot:
            return "Capture Screenshot"
        }
    }

    var defaultShortcut: HotkeyShortcut {
        switch self {
        case .toggleRecording:
            return .default
        case .insertMarker:
            return HotkeyShortcut(
                keyCode: UInt32(kVK_ANSI_M),
                modifiers: HotkeyShortcut.default.eventModifiers.union(.shift).rawValue
            )
        case .captureScreenshot:
            return HotkeyShortcut(
                keyCode: UInt32(kVK_ANSI_S),
                modifiers: HotkeyShortcut.default.eventModifiers.union(.shift).rawValue
            )
        }
    }
}
