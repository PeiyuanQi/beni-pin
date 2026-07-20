import SwiftUI

struct MyCardsView: View {
    let language: AppLanguage

    @EnvironmentObject private var catalogStore: CatalogStore
    @EnvironmentObject private var cardCollection: UserCardCollection
    @EnvironmentObject private var usageStore: BenefitUsageStore
    @State private var isAddingCard = false

    private var ownedCards: [CardProduct] {
        catalogStore.catalog.cards
            .filter { cardCollection.cardIDs.contains($0.id) }
            .sorted { lhs, rhs in
                lhs.name.value(for: language)
                    .localizedCaseInsensitiveCompare(rhs.name.value(for: language)) == .orderedAscending
            }
    }

    var body: some View {
        Group {
            switch catalogStore.phase {
            case .loading:
                ProgressView("catalog.loading")
            case let .failed(message):
                ContentUnavailableView {
                    Label("catalog.failed.title", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                }
            case .ready:
                cardsContent
            }
        }
        .navigationTitle("cards.title")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAddingCard = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(Text("cards.add"))
            }
        }
        .sheet(isPresented: $isAddingCard) {
            AddCardView(language: language)
        }
    }

    @ViewBuilder
    private var cardsContent: some View {
        if ownedCards.isEmpty {
            ContentUnavailableView {
                Label("cards.empty.title", systemImage: "creditcard")
            } description: {
                Text("cards.empty.message")
            } actions: {
                Button("cards.add") {
                    isAddingCard = true
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 280, maximum: 420), spacing: 18)],
                    spacing: 18
                ) {
                    ForEach(ownedCards) { card in
                        NavigationLink {
                            CardDetailView(card: card, language: language)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                CardArtworkView(card: card)
                                cardSummary(card)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .refreshable {
                await catalogStore.refresh()
            }
        }
    }

    private func cardSummary(_ card: CardProduct) -> some View {
        let benefits = catalogStore.catalog.benefits(for: card)
        let trackableBenefits = benefits.filter(\.isTrackable)
        let remaining = trackableBenefits.filter {
            !usageStore.isCompleted(cardID: card.id, benefit: $0)
        }.count

        return HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(card.name.value(for: language))
                    .font(.headline)
                Text(card.family.value(for: language))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 12)
            Text("\(remaining)/\(trackableBenefits.count)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .accessibilityLabel(Text("\(remaining) \(String(localized: "cards.benefits.remaining"))"))
        }
    }
}
