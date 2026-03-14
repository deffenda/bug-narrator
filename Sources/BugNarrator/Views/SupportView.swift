import SwiftUI

struct SupportView: View {
    @ObservedObject var appState: AppState

    private let donationAmounts = [5, 10, 20]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            donationSection
            footerCard
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Support BugNarrator Development")
                .font(.largeTitle.weight(.bold))

            Text("If BugNarrator helps your development workflow, consider supporting its continued development. Small donations help maintain and improve the project.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var donationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose a donation amount")
                .font(.headline)

            ForEach(donationAmounts, id: \.self) { amount in
                Button {
                    appState.openSupportDonation(amount: amount)
                } label: {
                    HStack {
                        Label("Donate $\(amount)", systemImage: "heart.fill")
                            .font(.body.weight(.semibold))

                        Spacer()

                        Image(systemName: "arrow.up.forward")
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityLabel("Donate \(amount) dollars with PayPal")
                .accessibilityHint("Opens PayPal in your default browser")
            }
        }
        .padding(18)
        .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var footerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Thank you for supporting open-source developer tools.")
                .font(.headline)

            Text("BugNarrator never processes payments inside the app and does not store any financial data. Each button opens the PayPal donation page in your default browser.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
