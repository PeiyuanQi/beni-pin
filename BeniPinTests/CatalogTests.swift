import XCTest
#if SWIFT_PACKAGE
@testable import BeniPinCore
#else
@testable import BeniPin
#endif

final class CatalogTests: XCTestCase {
    func testBundledCatalogDecodesAndValidates() throws {
        let catalog = try loadStarterCatalog()

        XCTAssertEqual(catalog.schemaVersion, 1)
        XCTAssertEqual(catalog.cards.count, 26)
        XCTAssertEqual(catalog.benefits.count, 66)
        XCTAssertEqual(catalog.cards.flatMap(\.earningRates).count, 110)
        XCTAssertTrue(catalog.benefits.allSatisfy { $0.category != .points })
        XCTAssertEqual(catalog.card(id: "deserve-edu")?.availability, .discontinued)
        XCTAssertEqual(catalog.card(id: "discover-it-cash-back")?.network, .discover)
        XCTAssertEqual(catalog.card(id: "citi-strata-elite")?.network, .mastercard)
        XCTAssertEqual(catalog.card(id: "boa-air-france-klm")?.network, .visa)
        XCTAssertEqual(catalog.card(id: "chase-world-of-hyatt-business")?.network, .visa)
        XCTAssertEqual(
            catalog.card(id: "chase-freedom-unlimited")?.earningRates.last?.displayText,
            "1.5%"
        )
        XCTAssertNoThrow(try catalog.validate())
    }

    func testLegacyCardWithoutEarningRatesStillDecodes() throws {
        let data = Data(
            """
            {
              "id": "legacy-card",
              "issuer": "Test Bank",
              "name": {"en": "Legacy", "zhHans": "旧卡"},
              "family": {"en": "Legacy", "zhHans": "旧卡"},
              "network": "visa",
              "artwork": {
                "primaryHex": "000000",
                "secondaryHex": "111111",
                "accentHex": "FFFFFF",
                "symbolName": "creditcard",
                "remoteImageURL": null
              },
              "benefitIDs": [],
              "sourceURLs": [],
              "lastVerified": "2026-07-22T00:00:00Z"
            }
            """.utf8
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let card = try decoder.decode(CardProduct.self, from: data)

        XCTAssertTrue(card.earningRates.isEmpty)
        XCTAssertTrue(card.searchAliases.isEmpty)
        XCTAssertEqual(card.availability, .active)
    }

    func testLegacyEarningRateWithoutUnitDefaultsToMultiplier() throws {
        let data = Data(
            """
            {
              "id": "legacy-rate",
              "category": {"en": "Dining", "zhHans": "餐饮"},
              "details": {"en": "Legacy rate", "zhHans": "历史倍率"},
              "multiplier": 3,
              "sourceURL": "https://example.com",
              "lastVerified": "2026-07-22T00:00:00Z"
            }
            """.utf8
        )
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let rate = try decoder.decode(CardEarningRate.self, from: data)

        XCTAssertEqual(rate.unit, .multiplier)
        XCTAssertEqual(rate.displayText, "3X")
    }

    func testRewardValueMapsCoverCurrentCatalog() throws {
        let catalog = try loadStarterCatalog()
        let earningRateIDs = Set(catalog.cards.flatMap(\.earningRates).map(\.id))
        let multiplierCardIDs = Set(
            catalog.cards
                .filter { card in card.earningRates.contains { $0.unit == .multiplier } }
                .map(\.id)
        )

        XCTAssertEqual(Set(RewardValueCatalog.earningCategoryByRateID.keys), earningRateIDs)
        XCTAssertEqual(Set(RewardValueCatalog.rewardProgramByCardID.keys), multiplierCardIDs)
        XCTAssertEqual(
            Set(RewardValueCatalog.defaultCentsPerPointByProgram.keys),
            Set(RewardValueCatalog.programs.map(\.id))
        )
    }

    func testEffectiveReturnUsesPointValueOrCashPercentage() throws {
        let catalog = try loadStarterCatalog()
        let gold = try XCTUnwrap(catalog.card(id: "amex-gold"))
        let goldDining = try XCTUnwrap(gold.earningRates.first { $0.id == "amex-gold-restaurants" })
        let freedom = try XCTUnwrap(catalog.card(id: "chase-freedom-unlimited"))
        let freedomDining = try XCTUnwrap(
            freedom.earningRates.first { $0.id == "freedom-unlimited-dining" }
        )

        XCTAssertEqual(
            RewardValueCatalog.effectiveReturnPercent(
                for: goldDining,
                card: gold,
                centsPerPoint: { _ in 2 }
            ),
            8
        )
        XCTAssertEqual(
            RewardValueCatalog.effectiveReturnPercent(
                for: freedomDining,
                card: freedom,
                centsPerPoint: { _ in 9 }
            ),
            3
        )
    }

    func testValidationRejectsMissingBenefitReference() throws {
        let card = CardProduct(
            id: "test-card",
            issuer: "Test Bank",
            name: LocalizedCopy(en: "Test", zhHans: "测试"),
            family: LocalizedCopy(en: "Test", zhHans: "测试"),
            network: .visa,
            artwork: CardArtwork(
                primaryHex: "000000",
                secondaryHex: "111111",
                accentHex: "FFFFFF",
                symbolName: "creditcard",
                remoteImageURL: nil
            ),
            benefitIDs: ["missing"],
            sourceURLs: [],
            lastVerified: Date()
        )
        let catalog = CardCatalog(
            schemaVersion: 1,
            generatedAt: Date(),
            cards: [card],
            benefits: []
        )

        XCTAssertThrowsError(try catalog.validate()) { error in
            XCTAssertEqual(
                error as? CatalogValidationError,
                .cardReferencesMissingBenefits("test-card", ["missing"])
            )
        }
    }

    func testInvalidCacheFallsBackToBundledCatalog() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("BeniPinCatalogTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        try Data("not valid json".utf8)
            .write(to: tempDirectory.appendingPathComponent("catalog.v1.json"))

        let repository = CatalogRepository(
            bundledCatalogURL: starterCatalogURL(),
            cacheDirectoryURL: tempDirectory
        )
        let snapshot = try await repository.loadBestAvailable()

        XCTAssertEqual(snapshot.origin, .bundled)
        XCTAssertEqual(snapshot.catalog.cards.count, 26)
    }

    func testValidationRejectsOneWayCardBenefitRelationship() throws {
        let card = CardProduct(
            id: "test-card",
            issuer: "Test Bank",
            name: LocalizedCopy(en: "Test", zhHans: "测试"),
            family: LocalizedCopy(en: "Test", zhHans: "测试"),
            network: .visa,
            artwork: CardArtwork(
                primaryHex: "000000",
                secondaryHex: "111111",
                accentHex: "FFFFFF",
                symbolName: "creditcard",
                remoteImageURL: nil
            ),
            benefitIDs: [],
            sourceURLs: [],
            lastVerified: Date()
        )
        let benefit = CardBenefit(
            id: "test-benefit",
            cardIDs: [card.id],
            title: LocalizedCopy(en: "Test", zhHans: "测试"),
            summary: LocalizedCopy(en: "Test", zhHans: "测试"),
            details: LocalizedCopy(en: "Test", zhHans: "测试"),
            category: .shopping,
            cadence: .ongoing,
            isTrackable: false,
            valueCents: nil,
            currencyCode: nil,
            enrollmentRequired: false,
            sourceURL: URL(string: "https://example.com")!,
            lastVerified: Date()
        )
        let catalog = CardCatalog(
            schemaVersion: 1,
            generatedAt: Date(),
            cards: [card],
            benefits: [benefit]
        )

        XCTAssertThrowsError(try catalog.validate()) { error in
            XCTAssertEqual(
                error as? CatalogValidationError,
                .inconsistentRelationship(card.id, benefit.id)
            )
        }
    }

    func testOlderRemoteCatalogDoesNotReplaceNewerCache() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("BeniPinCatalogTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let starter = try loadStarterCatalog()
        let newerCatalog = CardCatalog(
            schemaVersion: starter.schemaVersion,
            generatedAt: Date(timeIntervalSince1970: 2_000_000_000),
            cards: starter.cards,
            benefits: starter.benefits
        )
        let olderCatalog = CardCatalog(
            schemaVersion: starter.schemaVersion,
            generatedAt: Date(timeIntervalSince1970: 1_900_000_000),
            cards: starter.cards,
            benefits: starter.benefits
        )
        let cacheURL = tempDirectory.appendingPathComponent("catalog.v1.json")
        try encodeCatalog(newerCatalog).write(to: cacheURL)
        let remoteData = try encodeCatalog(olderCatalog)
        let remoteURL = URL(string: "https://example.com/catalog.json")!
        let repository = CatalogRepository(
            remoteURL: remoteURL,
            bundledCatalogURL: starterCatalogURL(),
            cacheDirectoryURL: tempDirectory,
            dataLoader: { _ in
                let response = HTTPURLResponse(
                    url: remoteURL,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (remoteData, response)
            }
        )

        let snapshot = try await repository.refreshFromRemote()
        let cachedCatalog = try decodeCatalog(Data(contentsOf: cacheURL))

        XCTAssertEqual(snapshot.origin, .cached)
        XCTAssertEqual(snapshot.catalog.generatedAt, newerCatalog.generatedAt)
        XCTAssertEqual(cachedCatalog.generatedAt, newerCatalog.generatedAt)
    }

    func testFailedRefreshDoesNotThrottleNextAttempt() async throws {
        let defaultsSuite = "BeniPinCatalogTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: defaultsSuite)!
        defer { UserDefaults(suiteName: defaultsSuite)?.removePersistentDomain(forName: defaultsSuite) }
        let repository = CatalogRepository(
            defaults: defaults,
            bundledCatalogURL: starterCatalogURL(),
            dataLoader: { _ in throw URLError(.timedOut) }
        )

        do {
            _ = try await repository.refreshFromRemote()
            XCTFail("Expected refresh to fail")
        } catch {
            let shouldRefresh = await repository.shouldRefresh()
            XCTAssertTrue(shouldRefresh)
        }
    }

    private func loadStarterCatalog() throws -> CardCatalog {
        try decodeCatalog(Data(contentsOf: starterCatalogURL()))
    }

    private func decodeCatalog(_ data: Data) throws -> CardCatalog {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(CardCatalog.self, from: data)
    }

    private func encodeCatalog(_ catalog: CardCatalog) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(catalog)
    }

    private func starterCatalogURL() -> URL {
#if SWIFT_PACKAGE
        return URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("catalog/catalog.v1.json")
#else
        let bundle = Bundle(for: CatalogTests.self)
        return bundle.url(forResource: "catalog.v1", withExtension: "json")!
#endif
    }
}
