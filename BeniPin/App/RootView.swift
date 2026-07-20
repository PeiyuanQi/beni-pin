import SwiftUI

struct RootView: View {
    private enum Tab: Hashable {
        case cards
        case benefits
        case settings
    }

    let language: AppLanguage
    @Binding var languageRawValue: String

    @EnvironmentObject private var catalogStore: CatalogStore
    @EnvironmentObject private var cardCollection: UserCardCollection
    @State private var hasStarted = false
    @State private var selectedTab: Tab

    init(language: AppLanguage, languageRawValue: Binding<String>) {
        self.language = language
        _languageRawValue = languageRawValue

#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if let tabIndex = arguments.firstIndex(of: "-demoTab"), arguments.indices.contains(tabIndex + 1) {
            switch arguments[tabIndex + 1] {
            case "benefits":
                _selectedTab = State(initialValue: .benefits)
            case "settings":
                _selectedTab = State(initialValue: .settings)
            default:
                _selectedTab = State(initialValue: .cards)
            }
        } else {
            _selectedTab = State(initialValue: .cards)
        }
#else
        _selectedTab = State(initialValue: .cards)
#endif
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MyCardsView(language: language)
            }
            .tabItem {
                Label {
                    Text("tab.cards")
                } icon: {
                    Image(systemName: "creditcard.fill")
                }
            }
            .tag(Tab.cards)

            NavigationStack {
                BenefitSearchView(language: language)
            }
            .tabItem {
                Label {
                    Text("tab.benefits")
                } icon: {
                    Image(systemName: "sparkles")
                }
            }
            .tag(Tab.benefits)

            NavigationStack {
                SettingsView(language: language, languageRawValue: $languageRawValue)
            }
            .tabItem {
                Label {
                    Text("tab.settings")
                } icon: {
                    Image(systemName: "gearshape")
                }
            }
            .tag(Tab.settings)
        }
        .task {
            guard !hasStarted else { return }
            hasStarted = true
            await catalogStore.start()
#if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-demoData") {
                let demoCardIDs = ["amex-platinum", "chase-sapphire-reserve", "capital-one-venture-x"]
                for cardID in demoCardIDs {
                    if let card = catalogStore.catalog.card(id: cardID) {
                        cardCollection.add(card)
                    }
                }
            }
#endif
        }
        .onReceive(NotificationCenter.default.publisher(for: .catalogDidRefresh)) { _ in
            Task { await catalogStore.reloadLocalCatalog() }
        }
        .alert(
            "catalog.refresh.failed.title",
            isPresented: Binding(
                get: { catalogStore.refreshMessage != nil },
                set: { isPresented in
                    if !isPresented { catalogStore.clearRefreshMessage() }
                }
            )
        ) {
            Button("action.ok", role: .cancel) {
                catalogStore.clearRefreshMessage()
            }
        } message: {
            if let refreshMessage = catalogStore.refreshMessage {
                Text(refreshMessage)
            }
        }
    }
}
