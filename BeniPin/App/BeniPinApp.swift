import SwiftUI

@main
struct BeniPinApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var catalogStore = CatalogStore()
    @StateObject private var cardCollection = UserCardCollection()
    @StateObject private var usageStore = BenefitUsageStore()
    @AppStorage("appLanguage") private var languageRawValue = AppLanguage.system.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: languageRawValue) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            RootView(language: language, languageRawValue: $languageRawValue)
                .environmentObject(catalogStore)
                .environmentObject(cardCollection)
                .environmentObject(usageStore)
                .environment(\.locale, language.locale)
                .tint(Color(hex: "197466"))
        }
    }
}
