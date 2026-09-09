import XCTest
#if SWIFT_PACKAGE
@testable import BeniPinCore
#else
@testable import BeniPin
#endif

final class BenefitSearchTests: XCTestCase {
    private var catalog: CardCatalog!

    override func setUpWithError() throws {
#if SWIFT_PACKAGE
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("catalog/catalog.v1.json")
#else
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "catalog.v1", withExtension: "json"))
#endif
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        catalog = try decoder.decode(CardCatalog.self, from: Data(contentsOf: url))
    }

    func testSearchMatchesEnglishAndChineseRegardlessOfAppLanguage() {
        let englishResults = BenefitSearch.results(
            in: catalog,
            query: "lounge",
            category: nil,
            ownedCardIDs: [],
            ownedOnly: false,
            language: .simplifiedChinese
        )
        let chineseResults = BenefitSearch.results(
            in: catalog,
            query: "贵宾室",
            category: nil,
            ownedCardIDs: [],
            ownedOnly: false,
            language: .english
        )

        XCTAssertGreaterThanOrEqual(englishResults.count, 3)
        XCTAssertEqual(Set(englishResults.map(\.id)), Set(chineseResults.map(\.id)))
    }

    func testRecurringAviosBonusIsSearchableInBothLanguages() {
        for language in [AppLanguage.english, .simplifiedChinese] {
            for query in ["anniversary", "周年"] {
                let results = BenefitSearch.results(
                    in: catalog,
                    query: query,
                    category: .points,
                    ownedCardIDs: ["chase-british-airways"],
                    ownedOnly: true,
                    language: language
                )
                XCTAssertEqual(results.map(\.id), ["chase-british-airways-anniversary-avios"])
            }
        }
    }

    func testOwnedOnlyScopeExcludesOtherCards() {
        let results = BenefitSearch.results(
            in: catalog,
            query: "",
            category: nil,
            ownedCardIDs: ["amex-gold"],
            ownedOnly: true,
            language: .english
        )

        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { result in
            result.cards.allSatisfy { $0.id == "amex-gold" }
        })
    }

    func testCategoryFilterReturnsOnlySelectedCategory() {
        let results = BenefitSearch.results(
            in: catalog,
            query: "",
            category: .lounge,
            ownedCardIDs: [],
            ownedOnly: false,
            language: .english
        )

        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.benefit.category == .lounge })
    }

    func testBenefitsCanExcludeAConfiguredCategory() {
        let baseline = BenefitSearch.results(
            in: catalog,
            query: "",
            category: nil,
            ownedCardIDs: ["amex-platinum"],
            ownedOnly: true,
            language: .english
        )
        let results = BenefitSearch.results(
            in: catalog,
            query: "",
            category: nil,
            ownedCardIDs: ["amex-platinum"],
            ownedOnly: true,
            excludedCategories: [.lounge],
            language: .english
        )

        XCTAssertTrue(baseline.contains { $0.benefit.category == .lounge })
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.benefit.category != .lounge })
    }

    func testCardSearchMatchesEarningRateInBothLanguages() {
        let englishResults = BenefitSearch.cards(in: catalog, query: "supermarkets", language: .simplifiedChinese)
        let chineseResults = BenefitSearch.cards(in: catalog, query: "美国超市", language: .english)

        XCTAssertEqual(
            Set(englishResults.map(\.id)),
            ["amex-gold", "citi-strata", "citi-strata-premier"]
        )
        XCTAssertEqual(chineseResults.map(\.id), ["amex-gold"])
    }

    func testRequestedCardNamesAndAliasesAreSearchable() {
        let expectations: [(query: String, cardIDs: Set<String>)] = [
            ("Chase United Club", ["chase-united-club"]),
            ("CFU", ["chase-freedom-unlimited"]),
            ("Chase BA", ["chase-british-airways"]),
            ("Chase IB", ["chase-iberia"]),
            ("Chase EI", ["chase-aer-lingus"]),
            ("英国航空", ["chase-british-airways"]),
            ("伊比利亚航空", ["chase-iberia"]),
            ("爱尔兰航空", ["chase-aer-lingus"]),
            ("US Bank Korean Air", ["us-bank-skypass-select"]),
            ("大韩航空", ["us-bank-skypass-select"]),
            ("Chase IHG Premier Business", ["chase-ihg-premier-business"]),
            ("洲际商业卡", ["chase-ihg-premier-business"]),
            ("BoA Customized Cash Rewards", ["boa-customized-cash-rewards"]),
            ("BoA Unlimited Cash Rewards", ["boa-unlimited-cash-rewards"]),
            ("BoA Travel Rewards", ["boa-travel-rewards"]),
            ("自选返现", ["boa-customized-cash-rewards"]),
            ("无限返现", ["boa-unlimited-cash-rewards"]),
            ("美国银行旅行奖励", ["boa-travel-rewards"]),
            ("Chase Sapphire Preferred", ["chase-sapphire-preferred"]),
            ("Chase Hyatt", ["chase-world-of-hyatt", "chase-world-of-hyatt-business"]),
            ("Chase IHG", ["chase-ihg-premier", "chase-ihg-premier-business"]),
            ("Deserve", ["deserve-edu"]),
            ("Discover", ["discover-it-cash-back"]),
            ("Bilt", ["bilt-blue", "bilt-obsidian", "bilt-palladium"]),
            ("Amex Marriott Brilliant", ["amex-marriott-bonvoy-brilliant"]),
            ("Alaska BOA ATOMS", ["boa-atmos-ascent", "boa-atmos-summit"]),
            ("Citi Strata", ["citi-strata", "citi-strata-premier", "citi-strata-elite"]),
            ("Citi Strata Card", ["citi-strata"]),
            ("Citi Strata Premier", ["citi-strata-premier"]),
            ("Citi Strata Elite", ["citi-strata-elite"]),
            ("Air France KLM", ["boa-air-france-klm"]),
            ("Hawaiian Airlines", ["barclays-hawaiian-airlines"]),
            ("Hyatt Business", ["chase-world-of-hyatt-business"]),
            ("CFF", ["chase-freedom-flex"]),
            ("Spark Cash", ["capital-one-spark-cash", "capital-one-spark-cash-plus"]),
            ("Spark Cash Plus", ["capital-one-spark-cash-plus"]),
        ]

        for expectation in expectations {
            let results = BenefitSearch.cards(
                in: catalog,
                query: expectation.query,
                language: .english
            )
            let chineseResults = BenefitSearch.cards(
                in: catalog,
                query: expectation.query,
                language: .simplifiedChinese
            )
            XCTAssertEqual(Set(results.map(\.id)), Set(chineseResults.map(\.id)))

            XCTAssertEqual(
                Set(results.map(\.id)),
                expectation.cardIDs,
                "Unexpected results for \(expectation.query)"
            )
        }
    }
}
