import Foundation

struct LocalizedCopy: Codable, Hashable, Sendable {
    let en: String
    let zhHans: String

    func value(for language: AppLanguage) -> String {
        language.usesSimplifiedChinese ? zhHans : en
    }
}
