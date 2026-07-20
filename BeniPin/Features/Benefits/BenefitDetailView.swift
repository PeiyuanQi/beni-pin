import SwiftUI

struct BenefitDetailView: View {
    let benefit: CardBenefit
    let cards: [CardProduct]
    let language: AppLanguage

    @EnvironmentObject private var cardCollection: UserCardCollection
    @EnvironmentObject private var usageStore: BenefitUsageStore

    private var ownedCards: [CardProduct] {
        cards.filter { cardCollection.cardIDs.contains($0.id) }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: benefit.category.symbolName)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color(hex: "197466"))
                        .frame(width: 44, height: 44)
                        .background(Color(hex: "DDEFEA"), in: RoundedRectangle(cornerRadius: 8))
                        .accessibilityHidden(true)

                    Text(benefit.title.value(for: language))
                        .font(.title2.bold())
                    Text(benefit.summary.value(for: language))
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            if benefit.isTrackable, !ownedCards.isEmpty {
                Section("benefit.usage.title") {
                    ForEach(ownedCards) { card in
                        Toggle(isOn: completionBinding(for: card)) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(card.name.value(for: language))
                                Text(LocalizedStringKey(benefit.cadence.localizationKey))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(Color(hex: "197466"))
                    }
                }
            }

            Section("benefit.details.title") {
                Text(benefit.details.value(for: language))

                LabeledContent("benefit.cadence.label") {
                    Text(LocalizedStringKey(benefit.cadence.localizationKey))
                }

                if let value = formattedValue {
                    LabeledContent("benefit.value.label", value: value)
                }

                LabeledContent("benefit.enrollment.label") {
                    Text(benefit.enrollmentRequired ? "common.yes" : "common.no")
                }

                LabeledContent("benefit.verified.label") {
                    Text(benefit.lastVerified, format: .dateTime.year().month().day())
                }
            }

            Section("benefit.cards.title") {
                ForEach(cards) { card in
                    HStack(spacing: 12) {
                        CardArtworkView(card: card, compact: true)
                            .frame(width: 112)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.name.value(for: language))
                                .font(.headline)
                            Text(card.issuer)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        if !cardCollection.contains(card) {
                            Button {
                                cardCollection.add(card)
                            } label: {
                                Image(systemName: "plus.circle")
                            }
                            .buttonStyle(.borderless)
                            .accessibilityLabel(Text("cards.add"))
                        }
                    }
                }
            }

            Section("benefit.source.title") {
                Link(destination: benefit.sourceURL) {
                    Label("benefit.source.open", systemImage: "arrow.up.right.square")
                }
                Text("benefit.source.disclaimer")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("benefit.title")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var formattedValue: String? {
        guard let valueCents = benefit.valueCents,
              let currencyCode = benefit.currencyCode else {
            return nil
        }
        return (Double(valueCents) / 100)
            .formatted(.currency(code: currencyCode).precision(.fractionLength(0)))
    }

    private func completionBinding(for card: CardProduct) -> Binding<Bool> {
        Binding(
            get: { usageStore.isCompleted(cardID: card.id, benefit: benefit) },
            set: { _ in usageStore.toggle(cardID: card.id, benefit: benefit) }
        )
    }
}
