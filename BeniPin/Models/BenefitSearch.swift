import Foundation

struct BenefitSearchResult: Identifiable, Hashable {
    let benefit: CardBenefit
    let cards: [CardProduct]

    var id: String { benefit.id }
}

enum BenefitSearch {
    static func results(
        in catalog: CardCatalog,
        query: String,
        category: BenefitCategory?,
        ownedCardIDs: Set<String>,
        ownedOnly: Bool,
        language: AppLanguage
    ) -> [BenefitSearchResult] {
        let normalizedQuery = normalize(query)

        return catalog.benefits.compactMap { benefit in
            guard category == nil || benefit.category == category else {
                return nil
            }

            let cards = benefit.cardIDs.compactMap(catalog.card(id:))
            let visibleCards = ownedOnly ? cards.filter { ownedCardIDs.contains($0.id) } : cards
            guard !visibleCards.isEmpty else {
                return nil
            }

            if !normalizedQuery.isEmpty {
                let searchableText = [
                    benefit.title.en,
                    benefit.title.zhHans,
                    benefit.summary.en,
                    benefit.summary.zhHans,
                    benefit.details.en,
                    benefit.details.zhHans,
                    visibleCards.map(\.issuer).joined(separator: " "),
                    visibleCards.map { "\($0.name.en) \($0.name.zhHans)" }.joined(separator: " "),
                    visibleCards.map { "\($0.family.en) \($0.family.zhHans)" }.joined(separator: " ")
                ].joined(separator: " ")

                guard normalize(searchableText).contains(normalizedQuery) else {
                    return nil
                }
            }

            return BenefitSearchResult(benefit: benefit, cards: visibleCards)
        }
        .sorted { lhs, rhs in
            let leftValue = lhs.benefit.valueCents ?? 0
            let rightValue = rhs.benefit.valueCents ?? 0
            if leftValue != rightValue {
                return leftValue > rightValue
            }
            return lhs.benefit.title.value(for: language)
                .localizedCaseInsensitiveCompare(rhs.benefit.title.value(for: language)) == .orderedAscending
        }
    }

    static func cards(in catalog: CardCatalog, query: String, language: AppLanguage) -> [CardProduct] {
        let normalizedQuery = normalize(query)
        guard !normalizedQuery.isEmpty else {
            return catalog.cards.sorted(by: cardSort(language: language))
        }

        return catalog.cards.filter { card in
            let benefitText = catalog.benefits(for: card)
                .map { "\($0.title.en) \($0.title.zhHans) \($0.summary.en) \($0.summary.zhHans)" }
                .joined(separator: " ")
            let searchableText = [
                card.issuer,
                card.name.en,
                card.name.zhHans,
                card.family.en,
                card.family.zhHans,
                card.network.displayName,
                benefitText
            ].joined(separator: " ")
            return normalize(searchableText).contains(normalizedQuery)
        }
        .sorted(by: cardSort(language: language))
    }

    private static func normalize(_ value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func cardSort(language: AppLanguage) -> (CardProduct, CardProduct) -> Bool {
        { lhs, rhs in
            if lhs.issuer != rhs.issuer {
                return lhs.issuer.localizedCaseInsensitiveCompare(rhs.issuer) == .orderedAscending
            }
            return lhs.name.value(for: language)
                .localizedCaseInsensitiveCompare(rhs.name.value(for: language)) == .orderedAscending
        }
    }
}
