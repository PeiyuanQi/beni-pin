import SwiftUI

struct SettingsView: View {
    let language: AppLanguage
    @Binding var languageRawValue: String

    @EnvironmentObject private var catalogStore: CatalogStore
    @EnvironmentObject private var cardCollection: UserCardCollection
    @EnvironmentObject private var usageStore: BenefitUsageStore
    @EnvironmentObject private var pointValuationStore: PointValuationStore
    @State private var showsWalletInfo = false
    @State private var showsPointValues = false
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

            Section("settings.pointValues.title") {
                NavigationLink {
                    PointValuationSettingsView(language: language)
                } label: {
                    Label("settings.pointValues.open", systemImage: "chart.line.uptrend.xyaxis")
                }

                Text("settings.pointValues.summary")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
        .navigationDestination(isPresented: $showsPointValues) {
            PointValuationSettingsView(language: language)
        }
        .task {
#if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-demoPointValues") {
                showsPointValues = true
            }
#endif
        }
        .sheet(isPresented: $showsWalletInfo) {
            WalletInfoView()
        }
        .confirmationDialog("settings.data.reset.confirm", isPresented: $confirmsDataReset, titleVisibility: .visible) {
            Button("settings.data.reset", role: .destructive) {
                cardCollection.removeAll()
                usageStore.removeAll()
                pointValuationStore.resetToDefaults()
            }
            Button("action.cancel", role: .cancel) {}
        }
    }
}

private struct PointValuationSettingsView: View {
    let language: AppLanguage

    @EnvironmentObject private var pointValuationStore: PointValuationStore

    var body: some View {
        List {
            Section {
                ForEach(RewardValueCatalog.programs) { program in
                    Stepper(
                        value: Binding(
                            get: { pointValuationStore.centsPerPoint(for: program.id) },
                            set: { pointValuationStore.setCentsPerPoint($0, for: program.id) }
                        ),
                        in: 0.05...10,
                        step: 0.05
                    ) {
                        HStack(spacing: 12) {
                            Text(program.name.value(for: language))
                                .foregroundStyle(.primary)

                            Spacer(minLength: 8)

                            HStack(spacing: 2) {
                                Text(
                                    pointValuationStore.centsPerPoint(for: program.id),
                                    format: .number.precision(.fractionLength(0...2))
                                )
                                .monospacedDigit()
                                Text("earnings.centsPerPoint.short")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(hex: "197466"))
                        }
                    }
                }
            } footer: {
                Text("settings.pointValues.disclaimer")
            }

            Section {
                Link(destination: RewardValueCatalog.valuationSourceURL) {
                    Label("settings.pointValues.source", systemImage: "arrow.up.right.square")
                }

                Button {
                    pointValuationStore.resetToDefaults()
                } label: {
                    Label("settings.pointValues.reset", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .navigationTitle("settings.pointValues.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
