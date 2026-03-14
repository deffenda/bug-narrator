import SwiftUI

struct MenuBarLabelView: View {
    let status: AppStatus
    let elapsedTime: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symbolName)
                .foregroundStyle(tintColor)

            if status.phase == .recording {
                Text(elapsedTime)
                    .monospacedDigit()
            }
        }
    }

    private var symbolName: String {
        switch status.phase {
        case .idle:
            return "mic"
        case .recording:
            return "record.circle.fill"
        case .transcribing:
            return "arrow.trianglehead.2.clockwise.rotate.90"
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }

    private var tintColor: Color {
        switch status.phase {
        case .idle:
            return .primary
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
