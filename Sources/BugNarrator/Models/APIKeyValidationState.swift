import Foundation

enum APIKeyValidationState: Equatable {
    case idle
    case validating
    case success(String)
    case failure(String)

    var message: String? {
        switch self {
        case .idle, .validating:
            return nil
        case .success(let message), .failure(let message):
            return message
        }
    }

    var isFailure: Bool {
        switch self {
        case .failure:
            return true
        default:
            return false
        }
    }
}
