import SwiftUI

struct CardDetailView: View {
    let card: CardProduct
    let language: AppLanguage

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var catalogStore: CatalogStore
    @EnvironmentObject private var cardCollection: UserCardCollection
    @EnvironmentObject private var usageStore: BenefitUsageStore
    @State private var confirmsRemoval = false

    private var benefits: [CardBenefit] {
        catalogStore.catalog.benefits(for: card)
    }

    var body: some View {
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
                    }
                }
                .padding(.vertical, 8)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

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
}
