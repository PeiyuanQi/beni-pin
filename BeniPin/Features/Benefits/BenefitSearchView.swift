import SwiftUI

struct BenefitSearchView: View {
    private enum Mode: Hashable {
        case benefits
        case earningRates
    }

    let language: AppLanguage

    @EnvironmentObject private var catalogStore: CatalogStore
    @EnvironmentObject private var cardCollection: UserCardCollection
    @State private var mode = Mode.benefits
    @State private var query = ""
    @State private var selectedCategory: BenefitCategory?

    private var ownedCards: [CardProduct] {
        catalogStore.catalog.cards
            .filter { cardCollection.cardIDs.contains($0.id) }
            .sorted { lhs, rhs in
                lhs.name.value(for: language)
                    .localizedCaseInsensitiveCompare(rhs.name.value(for: language)) == .orderedAscending
            }
    }

    private var availableCategories: [BenefitCategory] {
        BenefitCategory.allCases.filter { category in
            category != .points && catalogStore.catalog.benefits.contains { benefit in
                benefit.category == category && !cardCollection.cardIDs.isDisjoint(with: benefit.cardIDs)
            }
        }
    }

    private var results: [BenefitSearchResult] {
        BenefitSearch.results(
            in: catalogStore.catalog,
            query: query,
            category: selectedCategory,
            ownedCardIDs: cardCollection.cardIDs,
            ownedOnly: true,
            excludedCategories: [.points],
            language: language
        )
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

            switch mode {
            case .benefits:
                benefitsContent
            case .earningRates:
                earningRatesContent
            }
        }
    }

    @ViewBuilder
    private var benefitsContent: some View {
        if ownedCards.isEmpty {
            emptyCardsView
        } else {
            searchField
            categoryFilter

            if results.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                List(results) { result in
                    NavigationLink {
                        BenefitDetailView(
                            benefit: result.benefit,
                            cards: result.cards,
                            language: language
                        )
                    } label: {
                        BenefitRow(
                            benefit: result.benefit,
                            cards: result.cards,
                            language: language
                        )
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await catalogStore.refresh()
                }
            }
        }
    }

    @ViewBuilder
    private var earningRatesContent: some View {
        if ownedCards.isEmpty {
            emptyCardsView
        } else if ownedCards.allSatisfy({ $0.earningRates.isEmpty }) {
            ContentUnavailableView {
                Label("earnings.empty.title", systemImage: "chart.bar.xaxis")
            } description: {
                Text("earnings.empty.message")
            }
        } else {
            List {
                ForEach(ownedCards) { card in
                    if !card.earningRates.isEmpty {
                        Section {
                            ForEach(card.earningRates) { earningRate in
                                Link(destination: earningRate.sourceURL) {
                                    EarningRateRow(
                                        earningRate: earningRate,
                                        language: language
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        } header: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(card.name.value(for: language))
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .textCase(nil)
                                Text(card.issuer)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .textCase(nil)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                await catalogStore.refresh()
            }
        }
    }

    private var emptyCardsView: some View {
        ContentUnavailableView {
            Label("benefits.empty.cards.title", systemImage: "creditcard")
        } description: {
            Text("benefits.empty.cards.message")
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            TextField("benefits.search.prompt", text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("benefits.search.clear"))
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                categoryButton(
                    title: LocalizedStringKey("benefit.category.all"),
                    symbolName: "square.grid.2x2",
                    category: nil
                )

                ForEach(availableCategories) { category in
                    categoryButton(
                        title: LocalizedStringKey(category.localizationKey),
                        symbolName: category.symbolName,
                        category: category
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.vertical, 8, for: .scrollContent)
    }

    private func categoryButton(
        title: LocalizedStringKey,
        symbolName: String,
        category: BenefitCategory?
    ) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            withAnimation(.snappy) {
                selectedCategory = category
            }
        } label: {
            Label(title, systemImage: isSelected ? "checkmark" : symbolName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(
                    isSelected ? Color(hex: "197466") : Color.secondary.opacity(0.12),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct EarningRateRow: View {
    let earningRate: CardEarningRate
    let language: AppLanguage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(earningRate.multiplierText)X")
                .font(.title3.bold())
                .foregroundStyle(Color(hex: "197466"))
                .frame(width: 54, height: 38)
                .background(Color(hex: "DDEFEA"), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(earningRate.category.value(for: language))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer(minLength: 8)
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }

                Text(earningRate.details.value(for: language))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .accessibilityHidden(true)
                    Text("benefit.checked")
                    Text(earningRate.lastVerified, format: .dateTime.year().month(.abbreviated).day())
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
