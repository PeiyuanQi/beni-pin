import Foundation

@MainActor
final class BenefitUsageStore: ObservableObject {
    @Published private(set) var completedKeys: Set<String>

    private let defaults: UserDefaults
    private let storageKey: String
    private let calendar: Calendar

    init(
        defaults: UserDefaults = .standard,
        storageKey: String = "completedBenefitPeriods",
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.defaults = defaults
        self.storageKey = storageKey
        self.calendar = calendar

        if let data = defaults.data(forKey: storageKey),
           let storedKeys = try? JSONDecoder().decode(Set<String>.self, from: data) {
            completedKeys = storedKeys
        } else {
            completedKeys = []
        }
    }

    func isCompleted(cardID: String, benefit: CardBenefit, on date: Date = Date()) -> Bool {
        guard benefit.isTrackable else { return false }
        return completedKeys.contains(key(cardID: cardID, benefit: benefit, date: date))
    }

    func toggle(cardID: String, benefit: CardBenefit, on date: Date = Date()) {
        guard benefit.isTrackable else { return }
        let storageKey = key(cardID: cardID, benefit: benefit, date: date)
        if completedKeys.contains(storageKey) {
            completedKeys.remove(storageKey)
        } else {
            completedKeys.insert(storageKey)
        }
        persist()
    }

    func removeAll() {
        completedKeys = []
        persist()
    }

    func periodKey(for benefit: CardBenefit, on date: Date = Date()) -> String {
        let components = calendar.dateComponents([.year, .month], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 1

        switch benefit.cadence {
        case .ongoing:
            return "ongoing"
        case .monthly:
            return String(format: "%04d-%02d", year, month)
        case .quarterly:
            return "\(year)-Q\(((month - 1) / 3) + 1)"
        case .semiannual:
            return "\(year)-H\(month <= 6 ? 1 : 2)"
        case .annual:
            return "\(year)"
        case .anniversary:
            return "anniversary"
        case .fourYears:
            return "four-years"
        }
    }

    private func key(cardID: String, benefit: CardBenefit, date: Date) -> String {
        "\(cardID)|\(benefit.id)|\(periodKey(for: benefit, on: date))"
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(completedKeys) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
