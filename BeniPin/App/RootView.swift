import SwiftUI

struct RootView: View {
    private enum Tab: Hashable {
        case cards
        case benefits
        case articles
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
            case "cards":
                _selectedTab = State(initialValue: .cards)
            case "articles":
                _selectedTab = State(initialValue: .articles)
            case "settings":
                _selectedTab = State(initialValue: .settings)
            default:
                _selectedTab = State(initialValue: .benefits)
            }
        } else {
            _selectedTab = State(initialValue: .benefits)
        }
#else
        _selectedTab = State(initialValue: .benefits)
#endif
    }

    var body: some View {
        TabView(selection: $selectedTab) {
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
                ArticleBrowserView()
            }
            .tabItem {
                Label {
                    Text("tab.articles")
                } icon: {
                    Image(systemName: "newspaper.fill")
                }
            }
            .tag(Tab.articles)

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

private struct ArticleBrowserView: View {
    private struct Destination: Identifiable {
        let id: String
        let titleKey: LocalizedStringKey
        let symbolName: String
        let url: URL
    }

    private let articleDestinations = [
        Destination(
            id: "latest",
            titleKey: "articles.latest",
            symbolName: "clock",
            url: URL(string: "https://www.uscreditcardguide.com/zh/")!
        ),
        Destination(
            id: "credit-cards",
            titleKey: "articles.creditCards",
            symbolName: "creditcard",
            url: URL(string: "https://www.uscreditcardguide.com/category/credit-cards/")!
        ),
        Destination(
            id: "business-cards",
            titleKey: "articles.businessCards",
            symbolName: "briefcase",
            url: URL(string: "https://www.uscreditcardguide.com/category/biz-card/")!
        )
    ]

    private let directoryDestinations = [
        Destination(
            id: "card-directory",
            titleKey: "articles.cardDirectory",
            symbolName: "list.bullet.rectangle",
            url: URL(string: "https://www.uscreditcardguide.com/credit-cards/")!
        ),
        Destination(
            id: "business-card-directory",
            titleKey: "articles.businessCardDirectory",
            symbolName: "building.2",
            url: URL(string: "https://www.uscreditcardguide.com/small-business-credit-cards/")!
        )
    ]

    var body: some View {
        List {
            destinationSection("articles.section.browse", destinations: articleDestinations)
            destinationSection("articles.section.directories", destinations: directoryDestinations)
        }
        .navigationTitle("articles.title")
    }

    private func destinationSection(
        _ titleKey: LocalizedStringKey,
        destinations: [Destination]
    ) -> some View {
        Section(titleKey) {
            ForEach(destinations) { destination in
                Link(destination: destination.url) {
                    HStack(spacing: 12) {
                        Image(systemName: destination.symbolName)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.tint)
                            .frame(width: 28, height: 28)
                            .accessibilityHidden(true)

                        Text(destination.titleKey)
                            .foregroundStyle(.primary)

                        Spacer(minLength: 12)

                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                    .frame(minHeight: 36)
                }
            }
        }
    }
}
