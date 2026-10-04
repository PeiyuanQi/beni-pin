import SwiftUI

struct CardDetailView: View {
    private enum Mode: Hashable {
        case benefits
        case earningRates
    }

    let card: CardProduct
    let language: AppLanguage

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var catalogStore: CatalogStore
    @EnvironmentObject private var cardCollection: UserCardCollection
    @EnvironmentObject private var usageStore: BenefitUsageStore
    @EnvironmentObject private var pointValuationStore: PointValuationStore
    @State private var mode = Mode.benefits
    @State private var confirmsRemoval = false

    init(card: CardProduct, language: AppLanguage) {
        self.card = card
        self.language = language

#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-demoEarningRates") {
            _mode = State(initialValue: .earningRates)
        }
#endif
    }

    private var benefits: [CardBenefit] {
        catalogStore.catalog.benefits(for: card)
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("benefits.mode", selection: $mode) {
                Text("benefits.mode.benefits").tag(Mode.benefits)
                Text("benefits.mode.earningRates").tag(Mode.earningRates)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            List {
                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        CardArtworkView(card: card, language: language)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.name.value(for: language))
                                .font(.title2.bold())
                            Text("\(card.issuer) · \(card.family.value(for: language))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if card.availability == .discontinued {
                                Label(
                                    LocalizedStringKey(card.availability.localizationKey),
                                    systemImage: "clock.arrow.circlepath"
                                )
                                .font(.caption)
                                .foregroundStyle(.orange)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                switch mode {
                case .benefits:
                    benefitsSection
                case .earningRates:
                    earningRatesSection
                }
            }
        }
        .navigationTitle(card.name.value(for: language))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    confirmsRemoval = true
                } label: {
                    Image(systemName: "trash")
                }
                .accessibilityLabel(Text("cards.remove"))
            }
        }
        .confirmationDialog("cards.remove.confirm", isPresented: $confirmsRemoval, titleVisibility: .visible) {
            Button("cards.remove", role: .destructive) {
                cardCollection.remove(card)
                dismiss()
            }
            Button("action.cancel", role: .cancel) {}
        }
    }

    private var benefitsSection: some View {
        Section("benefits.title") {
            ForEach(benefits) { benefit in
                NavigationLink {
                    BenefitDetailView(benefit: benefit, cards: [card], language: language)
                } label: {
                    BenefitRow(
                        benefit: benefit,
                        cards: [card],
                        language: language,
                        isCompleted: benefit.isTrackable
                            ? usageStore.isCompleted(cardID: card.id, benefit: benefit)
                            : nil
                    )
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    if benefit.isTrackable {
                        Button {
                            usageStore.toggle(cardID: card.id, benefit: benefit)
                        } label: {
                            Label(
                                usageStore.isCompleted(cardID: card.id, benefit: benefit)
                                    ? "benefit.mark.unused"
                                    : "benefit.mark.used",
                                systemImage: usageStore.isCompleted(cardID: card.id, benefit: benefit)
                                    ? "arrow.uturn.backward"
                                    : "checkmark"
                            )
                        }
                        .tint(Color(hex: "197466"))
                    }
                }
            }
        }
    }

    private var earningRatesSection: some View {
        Section {
            if card.earningRates.isEmpty {
                ContentUnavailableView {
                    Label("earnings.empty.title", systemImage: "chart.bar.xaxis")
                } description: {
                    Text("earnings.card.empty.message")
                }
            } else {
                ForEach(card.earningRates) { rate in
                    Link(destination: rate.sourceURL) {
                        VStack(alignment: .leading, spacing: 8) {
                            EarningRateRow(
                                result: EarningRateResult(
                                    card: card,
                                    earningRate: rate,
                                    centsPerPoint: pointValuationStore.centsPerPoint(for:)
                                ),
                                language: language,
                                showsCardName: false
                            )

                            Text(rate.details.value(for: language))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if rate.unit == .multiplier {
                                Text("earnings.estimatedReturn")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            (Text("benefit.checked") + Text(" ")
                                + Text(rate.lastVerified, format: .dateTime.year().month(.abbreviated).day()))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(Text("benefit.source.open"))
                }
            }
        } header: {
            Text("benefits.mode.earningRates")
        } footer: {
            if !card.earningRates.isEmpty {
                Text("earnings.card.footer")
            }
        }
    }
}
