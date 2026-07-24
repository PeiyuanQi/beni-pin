import Foundation

struct RewardProgram: Identifiable, Hashable, Sendable {
    let id: String
    let name: LocalizedCopy
    let defaultCentsPerPoint: Double
}

enum EarningCategory: String, CaseIterable, Identifiable, Sendable {
    case travel
    case dining
    case groceries
    case gasTransportation
    case shopping
    case housing
    case rotating
    case mixed
    case other

    var id: String { rawValue }

    var localizationKey: String {
        "earnings.category.\(rawValue)"
    }

    var symbolName: String {
        switch self {
        case .travel: "airplane"
        case .dining: "fork.knife"
        case .groceries: "cart"
        case .gasTransportation: "car"
        case .shopping: "bag"
        case .housing: "house"
        case .rotating: "arrow.triangle.2.circlepath"
        case .mixed: "square.grid.2x2"
        case .other: "creditcard"
        }
    }
}

enum RewardValueCatalog {
    static let valuationSourceURL = URL(
        string: "https://thepointsguy.com/loyalty-programs/monthly-valuations/"
    )!

    static let programs: [RewardProgram] = [
        RewardProgram(
            id: "amex-membership-rewards",
            name: LocalizedCopy(en: "Amex Membership Rewards", zhHans: "Amex Membership Rewards"),
            defaultCentsPerPoint: 2
        ),
        RewardProgram(
            id: "atmos-rewards",
            name: LocalizedCopy(en: "Atmos Rewards", zhHans: "Atmos Rewards"),
            defaultCentsPerPoint: 1.55
        ),
        RewardProgram(
            id: "bilt-rewards",
            name: LocalizedCopy(en: "Bilt Rewards", zhHans: "Bilt Rewards"),
            defaultCentsPerPoint: 2.2
        ),
        RewardProgram(
            id: "capital-one-miles",
            name: LocalizedCopy(en: "Capital One Miles", zhHans: "Capital One 里程"),
            defaultCentsPerPoint: 1.85
        ),
        RewardProgram(
            id: "chase-ultimate-rewards",
            name: LocalizedCopy(en: "Chase Ultimate Rewards", zhHans: "Chase Ultimate Rewards"),
            defaultCentsPerPoint: 2.05
        ),
        RewardProgram(
            id: "citi-thankyou",
            name: LocalizedCopy(en: "Citi ThankYou Rewards", zhHans: "Citi ThankYou Rewards"),
            defaultCentsPerPoint: 1.9
        ),
        RewardProgram(
            id: "flying-blue",
            name: LocalizedCopy(en: "Flying Blue", zhHans: "Flying Blue"),
            defaultCentsPerPoint: 1.55
        ),
        RewardProgram(
            id: "ihg-one-rewards",
            name: LocalizedCopy(en: "IHG One Rewards", zhHans: "IHG One Rewards"),
            defaultCentsPerPoint: 0.6
        ),
        RewardProgram(
            id: "marriott-bonvoy",
            name: LocalizedCopy(en: "Marriott Bonvoy", zhHans: "Marriott Bonvoy"),
            defaultCentsPerPoint: 0.8
        ),
        RewardProgram(
            id: "united-mileageplus",
            name: LocalizedCopy(en: "United MileagePlus", zhHans: "United MileagePlus"),
            defaultCentsPerPoint: 1.3
        ),
        RewardProgram(
            id: "world-of-hyatt",
            name: LocalizedCopy(en: "World of Hyatt", zhHans: "World of Hyatt"),
            defaultCentsPerPoint: 1.6
        )
    ]

    static let defaultCentsPerPointByProgram: [String: Double] = Dictionary(
        uniqueKeysWithValues: programs.map { ($0.id, $0.defaultCentsPerPoint) }
    )

    static let rewardProgramByCardID: [String: String] = [
        "amex-platinum": "amex-membership-rewards",
        "amex-gold": "amex-membership-rewards",
        "chase-sapphire-reserve": "chase-ultimate-rewards",
        "chase-sapphire-preferred": "chase-ultimate-rewards",
        "capital-one-venture-x": "capital-one-miles",
        "chase-united-club": "united-mileageplus",
        "chase-world-of-hyatt": "world-of-hyatt",
        "chase-ihg-premier": "ihg-one-rewards",
        "bilt-blue": "bilt-rewards",
        "bilt-obsidian": "bilt-rewards",
        "bilt-palladium": "bilt-rewards",
        "amex-marriott-bonvoy-brilliant": "marriott-bonvoy",
        "boa-atmos-ascent": "atmos-rewards",
        "boa-atmos-summit": "atmos-rewards",
        "citi-strata": "citi-thankyou",
        "citi-strata-premier": "citi-thankyou",
        "citi-strata-elite": "citi-thankyou",
        "boa-air-france-klm": "flying-blue",
        "barclays-hawaiian-airlines": "atmos-rewards",
        "chase-world-of-hyatt-business": "world-of-hyatt"
    ]

    static let earningCategoryByRateID: [String: EarningCategory] = [
        "amex-platinum-flights": .travel,
        "amex-platinum-prepaid-hotels": .travel,
        "amex-platinum-other-purchases": .other,
        "amex-gold-prepaid-hotels": .travel,
        "amex-gold-restaurants": .dining,
        "amex-gold-us-supermarkets": .groceries,
        "amex-gold-flights": .travel,
        "amex-gold-rentals-cruises": .travel,
        "amex-gold-other-purchases": .other,
        "chase-reserve-chase-travel": .travel,
        "chase-reserve-direct-flights-hotels": .travel,
        "chase-reserve-dining": .dining,
        "chase-reserve-other-purchases": .other,
        "chase-preferred-chase-travel": .travel,
        "chase-preferred-dining": .dining,
        "chase-preferred-gas-ev-vacation-homes": .mixed,
        "chase-preferred-online-grocery-streaming": .mixed,
        "chase-preferred-other-travel": .travel,
        "chase-preferred-other-purchases": .other,
        "venture-x-hotels-rental-cars": .travel,
        "venture-x-flights-rentals-activities": .travel,
        "venture-x-entertainment": .shopping,
        "venture-x-other-purchases": .other,
        "united-club-united-purchases": .travel,
        "united-club-other-travel": .travel,
        "united-club-dining": .dining,
        "united-club-other-purchases": .other,
        "freedom-unlimited-chase-travel": .travel,
        "freedom-unlimited-dining": .dining,
        "freedom-unlimited-drugstores": .shopping,
        "freedom-unlimited-other-purchases": .other,
        "hyatt-card-hyatt": .travel,
        "hyatt-card-dining": .dining,
        "hyatt-card-travel-fitness": .mixed,
        "hyatt-card-other-purchases": .other,
        "ihg-premier-ihg": .travel,
        "ihg-premier-travel-dining-gas": .mixed,
        "ihg-premier-other-purchases": .other,
        "deserve-edu-other-purchases": .other,
        "discover-it-quarterly-categories": .rotating,
        "discover-it-other-purchases": .other,
        "bilt-blue-housing": .housing,
        "bilt-blue-bilt-dining": .dining,
        "bilt-blue-hotels": .travel,
        "bilt-blue-lyft": .gasTransportation,
        "bilt-blue-flights": .travel,
        "bilt-blue-other-purchases": .other,
        "bilt-obsidian-housing": .housing,
        "bilt-obsidian-hotels": .travel,
        "bilt-obsidian-choice-category": .rotating,
        "bilt-obsidian-bilt-dining": .dining,
        "bilt-obsidian-flights": .travel,
        "bilt-obsidian-other-travel": .travel,
        "bilt-obsidian-lyft": .gasTransportation,
        "bilt-obsidian-other-purchases": .other,
        "bilt-palladium-housing": .housing,
        "bilt-palladium-bilt-dining": .dining,
        "bilt-palladium-hotels": .travel,
        "bilt-palladium-lyft": .gasTransportation,
        "bilt-palladium-flights": .travel,
        "bilt-palladium-other-purchases": .other,
        "marriott-brilliant-marriott": .travel,
        "marriott-brilliant-restaurants": .dining,
        "marriott-brilliant-flights": .travel,
        "marriott-brilliant-other-purchases": .other,
        "atmos-ascent-airlines": .travel,
        "atmos-ascent-everyday": .mixed,
        "atmos-ascent-rent": .housing,
        "atmos-ascent-other-purchases": .other,
        "atmos-summit-airlines": .travel,
        "atmos-summit-dining": .dining,
        "atmos-summit-foreign-purchases": .other,
        "atmos-summit-rent": .housing,
        "atmos-summit-other-purchases": .other,
        "citi-strata-citi-travel": .travel,
        "citi-strata-supermarkets": .groceries,
        "citi-strata-transit-gas": .gasTransportation,
        "citi-strata-self-select": .rotating,
        "citi-strata-restaurants": .dining,
        "citi-strata-other-purchases": .other,
        "citi-strata-premier-citi-travel": .travel,
        "citi-strata-premier-air-hotels": .travel,
        "citi-strata-premier-restaurants": .dining,
        "citi-strata-premier-supermarkets": .groceries,
        "citi-strata-premier-gas": .gasTransportation,
        "citi-strata-premier-other-purchases": .other,
        "citi-strata-elite-citi-travel": .travel,
        "citi-strata-elite-air-travel": .travel,
        "citi-strata-elite-citi-nights": .dining,
        "citi-strata-elite-restaurants": .dining,
        "citi-strata-elite-other-purchases": .other,
        "boa-air-france-airlines": .travel,
        "boa-air-france-dining": .dining,
        "boa-air-france-other-purchases": .other,
        "barclays-hawaiian-airlines-purchases": .travel,
        "barclays-hawaiian-gas-dining-grocery": .mixed,
        "barclays-hawaiian-other-purchases": .other,
        "chase-hyatt-business-hyatt": .travel,
        "chase-hyatt-business-top-categories": .mixed,
        "chase-hyatt-business-fitness": .other,
        "chase-hyatt-business-other-purchases": .other,
        "chase-freedom-flex-quarterly": .rotating,
        "chase-freedom-flex-chase-travel": .travel,
        "chase-freedom-flex-dining": .dining,
        "chase-freedom-flex-drugstores": .shopping,
        "chase-freedom-flex-other-purchases": .other,
        "capital-one-spark-cash-business-travel": .travel,
        "capital-one-spark-cash-other-purchases": .other,
        "capital-one-spark-cash-plus-business-travel": .travel,
        "capital-one-spark-cash-plus-other-purchases": .other
    ]

    static func category(for earningRate: CardEarningRate) -> EarningCategory {
        earningCategoryByRateID[earningRate.id] ?? .other
    }

    static func program(for card: CardProduct) -> RewardProgram? {
        guard let programID = rewardProgramByCardID[card.id] else { return nil }
        return programs.first { $0.id == programID }
    }

    static func effectiveReturnPercent(
        for earningRate: CardEarningRate,
        card: CardProduct,
        centsPerPoint: (String) -> Double
    ) -> Double {
        switch earningRate.unit {
        case .percent:
            return earningRate.multiplier
        case .multiplier:
            guard let programID = rewardProgramByCardID[card.id] else {
                return earningRate.multiplier
            }
            return earningRate.multiplier * centsPerPoint(programID)
        }
    }
}

@MainActor
final class PointValuationStore: ObservableObject {
    @Published private(set) var overrides: [String: Double]

    private let defaults: UserDefaults
    private let storageKey: String

    init(defaults: UserDefaults = .standard, storageKey: String = "pointValuationOverrides") {
        self.defaults = defaults
        self.storageKey = storageKey

        if let data = defaults.data(forKey: storageKey),
           let storedOverrides = try? JSONDecoder().decode([String: Double].self, from: data) {
            overrides = storedOverrides.filter { programID, value in
                RewardValueCatalog.defaultCentsPerPointByProgram[programID] != nil
                    && value.isFinite
                    && value > 0
            }
        } else {
            overrides = [:]
        }
    }

    func centsPerPoint(for programID: String) -> Double {
        overrides[programID]
            ?? RewardValueCatalog.defaultCentsPerPointByProgram[programID]
            ?? 1
    }

    func setCentsPerPoint(_ value: Double, for programID: String) {
        guard RewardValueCatalog.defaultCentsPerPointByProgram[programID] != nil,
              value.isFinite,
              value > 0 else {
            return
        }

        overrides[programID] = min(max(value, 0.05), 10)
        persist()
    }

    func resetToDefaults() {
        overrides = [:]
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(overrides) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
