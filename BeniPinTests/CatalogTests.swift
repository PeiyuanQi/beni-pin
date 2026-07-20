import XCTest
#if SWIFT_PACKAGE
@testable import BeniPinCore
#else
@testable import BeniPin
#endif

final class CatalogTests: XCTestCase {
    func testStarterCatalogDecodesAndValidates() throws {
        let catalog = try loadStarterCatalog()

        XCTAssertEqual(catalog.schemaVersion, 1)
        XCTAssertEqual(catalog.cards.count, 5)
        XCTAssertEqual(catalog.benefits.count, 24)
        XCTAssertNoThrow(try catalog.validate())
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
        XCTAssertEqual(snapshot.catalog.cards.count, 5)
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
