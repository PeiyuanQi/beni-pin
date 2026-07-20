import SwiftUI

struct SettingsView: View {
    let language: AppLanguage
    @Binding var languageRawValue: String

    @EnvironmentObject private var catalogStore: CatalogStore
    @EnvironmentObject private var cardCollection: UserCardCollection
    @EnvironmentObject private var usageStore: BenefitUsageStore
    @State private var showsWalletInfo = false
    @State private var confirmsDataReset = false

    var body: some View {
        Form {
            Section("settings.language.title") {
                Picker("settings.language.title", selection: $languageRawValue) {
                    Text("settings.language.system").tag(AppLanguage.system.rawValue)
                    Text("settings.language.english").tag(AppLanguage.english.rawValue)
                    Text("settings.language.chinese").tag(AppLanguage.simplifiedChinese.rawValue)
                }
            }

            Section("settings.catalog.title") {
                LabeledContent("settings.catalog.updated") {
                    Text(
                        catalogStore.catalog.generatedAt,
                        format: .dateTime.year().month().day().hour().minute()
                    )
                }
                LabeledContent("settings.catalog.source") {
                    Text(LocalizedStringKey(catalogStore.origin.localizationKey))
                }
                LabeledContent("settings.catalog.cards", value: "\(catalogStore.catalog.cards.count)")
                LabeledContent("settings.catalog.benefits", value: "\(catalogStore.catalog.benefits.count)")

                Button {
                    Task { await catalogStore.refresh() }
                } label: {
                    Label {
                        Text(catalogStore.isRefreshing ? "settings.catalog.refreshing" : "settings.catalog.refresh")
                    } icon: {
                        if catalogStore.isRefreshing {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
                .disabled(catalogStore.isRefreshing)
            }

            Section("settings.wallet.title") {
                Button {
                    showsWalletInfo = true
                } label: {
                    Label("settings.wallet.explanation", systemImage: "wallet.pass")
                }
            }

            Section("settings.privacy.title") {
                Label("settings.privacy.local", systemImage: "iphone")
                Label("settings.privacy.noSensitiveData", systemImage: "hand.raised")
                Text("settings.privacy.catalogRequest")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("settings.data.reset", role: .destructive) {
                    confirmsDataReset = true
                }
            }

            Section("settings.sources.title") {
                Text("settings.sources.message")
                    .font(.subheadline)
                Link(destination: URL(string: "https://github.com/PeiyuanQi/beni-pin")!) {
                    Label("settings.sources.repository", systemImage: "arrow.up.right.square")
                }
            }

            Section("settings.disclaimer.title") {
                Text("settings.disclaimer.message")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("settings.title")
        .sheet(isPresented: $showsWalletInfo) {
            WalletInfoView()
        }
        .confirmationDialog("settings.data.reset.confirm", isPresented: $confirmsDataReset, titleVisibility: .visible) {
            Button("settings.data.reset", role: .destructive) {
                cardCollection.removeAll()
                usageStore.removeAll()
            }
            Button("action.cancel", role: .cancel) {}
        }
    }
}
