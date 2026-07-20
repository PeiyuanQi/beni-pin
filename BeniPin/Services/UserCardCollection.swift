import Foundation

@MainActor
final class UserCardCollection: ObservableObject {
    @Published private(set) var cardIDs: Set<String>

    private let defaults: UserDefaults
    private let storageKey: String

    init(defaults: UserDefaults = .standard, storageKey: String = "userCardProductIDs") {
        self.defaults = defaults
        self.storageKey = storageKey

        if let data = defaults.data(forKey: storageKey),
           let storedIDs = try? JSONDecoder().decode(Set<String>.self, from: data) {
            cardIDs = storedIDs
        } else {
            cardIDs = []
        }
    }

    func contains(_ card: CardProduct) -> Bool {
        cardIDs.contains(card.id)
    }

    func add(_ card: CardProduct) {
        cardIDs.insert(card.id)
        persist()
    }

    func remove(_ card: CardProduct) {
        cardIDs.remove(card.id)
        persist()
    }

    func toggle(_ card: CardProduct) {
        contains(card) ? remove(card) : add(card)
    }

    func removeAll() {
        cardIDs = []
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(cardIDs) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
