import Foundation

struct CardCatalog: Codable, Equatable, Sendable {
    let schemaVersion: Int
    let generatedAt: Date
    let cards: [CardProduct]
    let benefits: [CardBenefit]

    static let empty = CardCatalog(
        schemaVersion: 1,
        generatedAt: .distantPast,
        cards: [],
        benefits: []
    )

    func validate() throws {
        guard schemaVersion == 1 else {
            throw CatalogValidationError.unsupportedSchema(schemaVersion)
        }

        let cardIDs = Set(cards.map(\.id))
        let benefitIDs = Set(benefits.map(\.id))

        guard cardIDs.count == cards.count else {
            throw CatalogValidationError.duplicateCardID
        }
        guard benefitIDs.count == benefits.count else {
            throw CatalogValidationError.duplicateBenefitID
        }

        for card in cards {
            let missing = card.benefitIDs.filter { !benefitIDs.contains($0) }
            guard missing.isEmpty else {
                throw CatalogValidationError.cardReferencesMissingBenefits(card.id, missing)
            }

            for benefitID in card.benefitIDs {
                guard benefit(id: benefitID)?.cardIDs.contains(card.id) == true else {
                    throw CatalogValidationError.inconsistentRelationship(card.id, benefitID)
                }
            }
        }

        for benefit in benefits {
            let missing = benefit.cardIDs.filter { !cardIDs.contains($0) }
            guard missing.isEmpty else {
                throw CatalogValidationError.benefitReferencesMissingCards(benefit.id, missing)
            }


            for cardID in benefit.cardIDs {
                guard card(id: cardID)?.benefitIDs.contains(benefit.id) == true else {
                    throw CatalogValidationError.inconsistentRelationship(cardID, benefit.id)
                }
            }
        }
    }

    func card(id: String) -> CardProduct? {
        cards.first { $0.id == id }
    }

    func benefit(id: String) -> CardBenefit? {
        benefits.first { $0.id == id }
    }

    func benefits(for card: CardProduct) -> [CardBenefit] {
        card.benefitIDs.compactMap(benefit(id:))
    }
}

struct CardProduct: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let issuer: String
    let name: LocalizedCopy
    let family: LocalizedCopy
    let network: PaymentNetwork
    let artwork: CardArtwork
    let benefitIDs: [String]
    let sourceURLs: [URL]
    let lastVerified: Date
}

struct CardArtwork: Codable, Hashable, Sendable {
    let primaryHex: String
    let secondaryHex: String
    let accentHex: String
    let symbolName: String
    let remoteImageURL: URL?
}

struct CardBenefit: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let cardIDs: [String]
    let title: LocalizedCopy
    let summary: LocalizedCopy
    let details: LocalizedCopy
    let category: BenefitCategory
    let cadence: BenefitCadence
    let isTrackable: Bool
    let valueCents: Int?
    let currencyCode: String?
    let enrollmentRequired: Bool
    let sourceURL: URL
    let lastVerified: Date
}

enum PaymentNetwork: String, Codable, CaseIterable, Sendable {
    case americanExpress
    case mastercard
    case visa

    var displayName: String {
        switch self {
        case .americanExpress: "American Express"
        case .mastercard: "Mastercard"
        case .visa: "Visa"
        }
    }
}

enum BenefitCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case travelCredit
    case lounge
    case dining
    case hotel
    case transportation
    case shopping
    case protection
    case points

    var id: String { rawValue }

    var localizationKey: String {
        "benefit.category.\(rawValue)"
    }

    var symbolName: String {
        switch self {
        case .travelCredit: "airplane"
        case .lounge: "sofa"
        case .dining: "fork.knife"
        case .hotel: "bed.double"
        case .transportation: "tram.fill"
        case .shopping: "bag"
        case .protection: "shield.checkered"
        case .points: "sparkles"
        }
    }
}

enum BenefitCadence: String, Codable, CaseIterable, Sendable {
    case ongoing
    case monthly
    case quarterly
    case semiannual
    case annual
    case anniversary
    case fourYears

    var localizationKey: String {
        "benefit.cadence.\(rawValue)"
    }
}

enum CatalogValidationError: LocalizedError, Equatable {
    case unsupportedSchema(Int)
    case duplicateCardID
    case duplicateBenefitID
    case cardReferencesMissingBenefits(String, [String])
    case benefitReferencesMissingCards(String, [String])
    case inconsistentRelationship(String, String)

    var errorDescription: String? {
        switch self {
        case let .unsupportedSchema(version):
            return "Unsupported catalog schema version \(version)."
        case .duplicateCardID:
            return "The catalog contains duplicate card IDs."
        case .duplicateBenefitID:
            return "The catalog contains duplicate benefit IDs."
        case let .cardReferencesMissingBenefits(cardID, benefitIDs):
            return "Card \(cardID) references missing benefits: \(benefitIDs.joined(separator: ", "))."
        case let .benefitReferencesMissingCards(benefitID, cardIDs):
            return "Benefit \(benefitID) references missing cards: \(cardIDs.joined(separator: ", "))."
        case let .inconsistentRelationship(cardID, benefitID):
            return "Card \(cardID) and benefit \(benefitID) do not reference each other."
        }
    }
}
