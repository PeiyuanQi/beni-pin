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
                WalletCardStack(cards: ownedCards) { card in
                    NavigationLink {
                        CardDetailView(card: card, language: language)
                    } label: {
                        walletCard(card)
                            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: 460)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .refreshable {
                await catalogStore.refresh()
            }
        }
    }

    private func walletCard(_ card: CardProduct) -> some View {
        let benefits = catalogStore.catalog.benefits(for: card).filter { $0.category != .points }
        let trackableBenefits = benefits.filter(\.isTrackable)
        let remaining = trackableBenefits.filter {
            !usageStore.isCompleted(cardID: card.id, benefit: $0)
        }.count

        return CardArtworkView(card: card, language: language)
            .overlay(alignment: .bottomTrailing) {
                if !trackableBenefits.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: remaining == 0 ? "checkmark.circle.fill" : "sparkles")
                            .accessibilityHidden(true)
                        Text("\(remaining)/\(trackableBenefits.count)")
                            .monospacedDigit()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(.black.opacity(0.34), in: Capsule())
                    .padding(16)
                    .accessibilityLabel(
                        Text("\(remaining) \(String(localized: "cards.benefits.remaining"))")
                    )
                }
            }
            .shadow(color: .black.opacity(0.18), radius: 12, y: 6)
    }
}

private struct WalletCardStack<CardContent: View>: View {
    let cards: [CardProduct]
    @ViewBuilder let cardContent: (CardProduct) -> CardContent

    private let cardAspectRatio: CGFloat = 1.586
    private let visibleCardFraction: CGFloat = 0.22

    private var stackAspectRatio: CGFloat {
        let cardHeightFraction = 1 / cardAspectRatio
        let peekHeightFraction = visibleCardFraction * CGFloat(max(cards.count - 1, 0))
        return 1 / (cardHeightFraction + peekHeightFraction)
    }

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width
            let cardHeight = cardWidth / cardAspectRatio
            let peekHeight = cardWidth * visibleCardFraction

            ZStack(alignment: .top) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    cardContent(card)
                        .frame(width: cardWidth, height: cardHeight)
                        .offset(y: CGFloat(index) * peekHeight)
                        .zIndex(Double(index))
                        .accessibilitySortPriority(Double(cards.count - index))
                }
            }
        }
        .aspectRatio(stackAspectRatio, contentMode: .fit)
        .animation(.snappy, value: cards.map(\.id))
    }
}
