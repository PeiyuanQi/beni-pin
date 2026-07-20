import SwiftUI

struct WalletInfoView: View {
    @Environment(\.dismiss) private var dismiss
    private let capability = WalletCapability.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 46, weight: .medium))
                        .foregroundStyle(Color(hex: "197466"))
                        .accessibilityHidden(true)

                    Text("wallet.info.title")
                        .font(.title2.bold())

                    Text("wallet.info.message")
                        .font(.body)

                    Label {
                        Text(capability.isWalletAvailable ? "wallet.available" : "wallet.unavailable")
                    } icon: {
                        Image(systemName: capability.isWalletAvailable ? "checkmark.circle" : "xmark.circle")
                    }
                    .foregroundStyle(.secondary)

                    Divider()

                    Text("wallet.info.privacy")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            .navigationTitle("wallet.import.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("action.done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
