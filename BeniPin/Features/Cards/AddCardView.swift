import SwiftUI

struct AddCardView: View {
    let language: AppLanguage

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var catalogStore: CatalogStore
    @EnvironmentObject private var cardCollection: UserCardCollection
    @State private var query = ""
    @State private var showsWalletInfo = false

    private var cards: [CardProduct] {
        BenefitSearch.cards(in: catalogStore.catalog, query: query, language: language)
    }

    private var issuers: [String] {
        Array(Set(cards.map(\.issuer))).sorted()
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showsWalletInfo = true
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("wallet.import.title")
                                    .foregroundStyle(.primary)
                                Text("wallet.import.subtitle")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "wallet.pass")
                        }
                    }
                }

                ForEach(issuers, id: \.self) { issuer in
                    Section(issuer) {
                        ForEach(cards.filter { $0.issuer == issuer }) { card in
                            Button {
                                cardCollection.toggle(card)
                            } label: {
                                HStack(spacing: 12) {
                                    CardArtworkView(card: card, language: language, compact: true)
                                        .frame(width: 104)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(card.name.value(for: language))
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text(card.family.value(for: language))
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
                                    Spacer(minLength: 6)
                                    Image(systemName: cardCollection.contains(card) ? "checkmark.circle.fill" : "plus.circle")
                                        .font(.title3)
                                        .foregroundStyle(cardCollection.contains(card) ? Color(hex: "197466") : .secondary)
                                }
                            }
                            .accessibilityLabel(
                                Text("\(card.name.value(for: language)), \(cardCollection.contains(card) ? String(localized: "cards.added") : String(localized: "cards.notAdded"))")
                            )
                        }
                    }
                }
            }
            .navigationTitle("cards.add")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "cards.search.prompt")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("action.done") { dismiss() }
                }
            }
            .sheet(isPresented: $showsWalletInfo) {
                WalletInfoView()
            }
        }
    }
}
