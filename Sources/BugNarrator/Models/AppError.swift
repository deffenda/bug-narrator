import Foundation

enum AppError: LocalizedError {
    case missingAPIKey
    case invalidAPIKey
    case revokedAPIKey
    case microphonePermissionDenied
    case noActiveSession(String)
    case recordingFailure(String)
    case transcriptionFailure(String)
    case openAIRequestRejected(String)
    case screenshotCaptureFailure(String)
    case issueExtractionFailure(String)
    case emptyTranscript
    case networkTimeout
    case networkFailure
    case exportConfigurationMissing(String)
    case exportFailure(String)
    case storageFailure(String)

    var userMessage: String {
        switch self {
        case .missingAPIKey:
            return "BugNarrator requires your own OpenAI API key. Add it in Settings before starting a session."
        case .invalidAPIKey:
            return "The OpenAI API key was rejected. Open Settings, replace it, and try again."
        case .revokedAPIKey:
            return "The OpenAI API key is no longer valid. Open Settings, remove it, and add a new key."
        case .microphonePermissionDenied:
            return "Microphone permission was denied. Enable it in System Settings and try again."
        case .noActiveSession(let message):
            return message
        case .recordingFailure(let message):
            return "Recording failed: \(message)"
        case .transcriptionFailure(let message):
            return "Transcription failed: \(message)"
        case .openAIRequestRejected(let message):
            return "OpenAI rejected the request: \(message)"
        case .screenshotCaptureFailure(let message):
            return "Screenshot capture failed: \(message)"
        case .issueExtractionFailure(let message):
            return "Issue extraction failed: \(message)"
        case .emptyTranscript:
            return "The transcription finished but returned empty text."
        case .networkTimeout:
            return "The request to OpenAI timed out. Check your connection and try again."
        case .networkFailure:
            return "BugNarrator could not reach OpenAI. Check your internet connection and try again."
        case .exportConfigurationMissing(let message):
            return "Export setup is incomplete: \(message)"
        case .exportFailure(let message):
            return "Export failed: \(message)"
        case .storageFailure(let message):
            return "Could not save local session history: \(message)"
        }
    }

    var errorDescription: String? {
        userMessage
    }
}
