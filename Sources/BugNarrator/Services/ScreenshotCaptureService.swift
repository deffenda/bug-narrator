import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

struct ScreenshotCaptureService: ScreenshotCapturing {
    func captureScreenshot(to url: URL) throws {
        if !CGPreflightScreenCaptureAccess() && !CGRequestScreenCaptureAccess() {
            throw AppError.screenshotCaptureFailure(
                "Screen Recording permission is required to capture review screenshots. Enable it in System Settings and try again."
            )
        }

        guard let image = CGWindowListCreateImage(
            .infinite,
            .optionOnScreenOnly,
            kCGNullWindowID,
            [.bestResolution]
        ) else {
            throw AppError.screenshotCaptureFailure(
                "Screen capture failed. If the problem persists, check Screen Recording permission in System Settings."
            )
        }

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            throw AppError.screenshotCaptureFailure("The screenshot file could not be created.")
        }

        CGImageDestinationAddImage(destination, image, nil)

        guard CGImageDestinationFinalize(destination) else {
            throw AppError.screenshotCaptureFailure("The screenshot file could not be written to disk.")
        }
    }
}
