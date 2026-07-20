import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english
    case simplifiedChinese

    var id: String { rawValue }

    var locale: Locale {
        switch self {
        case .system:
            return .autoupdatingCurrent
        case .english:
            return Locale(identifier: "en")
        case .simplifiedChinese:
            return Locale(identifier: "zh-Hans")
        }
    }

    var usesSimplifiedChinese: Bool {
        switch self {
        case .simplifiedChinese:
            return true
        case .english:
            return false
        case .system:
            return Locale.preferredLanguages.first?.lowercased().hasPrefix("zh-hans") == true
                || Locale.preferredLanguages.first?.lowercased().hasPrefix("zh-cn") == true
        }
    }
}
