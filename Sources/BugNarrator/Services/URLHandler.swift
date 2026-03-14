import AppKit
import Foundation

struct WorkspaceURLHandler: URLOpening {
    @discardableResult
    func open(_ url: URL) -> Bool {
        NSWorkspace.shared.open(url)
    }
}
