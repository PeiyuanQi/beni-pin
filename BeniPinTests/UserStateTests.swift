import XCTest
#if SWIFT_PACKAGE
@testable import BeniPinCore
#else
@testable import BeniPin
#endif

final class UserStateTests: XCTestCase {
    @MainActor
    func testCardCollectionPersistsOnlyProductIDs() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let card = makeCard()
        let storageKey = "cards"
        let collection = UserCardCollection(defaults: defaults, storageKey: storageKey)

        collection.add(card)

        let reloaded = UserCardCollection(defaults: defaults, storageKey: storageKey)
        XCTAssertEqual(reloaded.cardIDs, [card.id])
    }

    @MainActor
    func testBenefitUsageUsesCurrentMonthlyPeriod() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let benefit = makeBenefit(cadence: .monthly)
        let date = ISO8601DateFormatter().date(from: "2026-07-19T12:00:00Z")!
        let store = BenefitUsageStore(
            defaults: defaults,
            storageKey: "usage",
            calendar: calendar
        )

        XCTAssertEqual(store.periodKey(for: benefit, on: date), "2026-07")
        XCTAssertFalse(store.isCompleted(cardID: "test-card", benefit: benefit, on: date))

        store.toggle(cardID: "test-card", benefit: benefit, on: date)

        XCTAssertTrue(store.isCompleted(cardID: "test-card", benefit: benefit, on: date))
    }

    @MainActor
    func testRemoveAllClearsStoredProductIDs() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let storageKey = "cards"
        let collection = UserCardCollection(defaults: defaults, storageKey: storageKey)
        collection.add(makeCard())

        collection.removeAll()

        let reloaded = UserCardCollection(defaults: defaults, storageKey: storageKey)
        XCTAssertTrue(reloaded.cardIDs.isEmpty)
    }

    @MainActor
    func testNonTrackableBenefitCannotBeCompleted() {
        let (defaults, suiteName) = makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let benefit = makeBenefit(cadence: .ongoing, isTrackable: false)
        let store = BenefitUsageStore(defaults: defaults, storageKey: "usage")

        store.toggle(cardID: "test-card", benefit: benefit)

        XCTAssertFalse(store.isCompleted(cardID: "test-card", benefit: benefit))
        XCTAssertTrue(store.completedKeys.isEmpty)
    }

    private func makeDefaults() -> (UserDefaults, String) {
        let suiteName = "BeniPinTests.\(UUID().uuidString)"
        return (UserDefaults(suiteName: suiteName)!, suiteName)
    }

    private func makeCard() -> CardProduct {
        CardProduct(
            id: "test-card",
            issuer: "Test Bank",
            name: LocalizedCopy(en: "Test Card", zhHans: "测试卡"),
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
    }

    private func makeBenefit(cadence: BenefitCadence, isTrackable: Bool = true) -> CardBenefit {
        CardBenefit(
            id: "test-benefit",
            cardIDs: ["test-card"],
            title: LocalizedCopy(en: "Test", zhHans: "测试"),
            summary: LocalizedCopy(en: "Test", zhHans: "测试"),
            details: LocalizedCopy(en: "Test", zhHans: "测试"),
            category: .shopping,
            cadence: cadence,
            isTrackable: isTrackable,
            valueCents: nil,
            currencyCode: nil,
            enrollmentRequired: false,
            sourceURL: URL(string: "https://example.com")!,
            lastVerified: Date()
        )
    }
}
