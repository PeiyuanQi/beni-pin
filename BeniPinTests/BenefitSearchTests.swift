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

        XCTAssertEqual(englishResults.map(\.id), ["amex-gold"])
        XCTAssertEqual(chineseResults.map(\.id), ["amex-gold"])
    }
}
