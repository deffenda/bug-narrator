import AppKit

enum ClipboardService {
    static func copy(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }
}

struct SystemClipboardService: ClipboardWriting {
    func copy(_ string: String) {
        ClipboardService.copy(string)
    }
}
