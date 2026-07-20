import SwiftUI

struct BenefitSearchView: View {
    let language: AppLanguage

    @EnvironmentObject private var catalogStore: CatalogStore
    @EnvironmentObject private var cardCollection: UserCardCollection
    @State private var query = ""
    @State private var ownedOnly = true
    @State private var selectedCategory: BenefitCategory?

    private var results: [BenefitSearchResult] {
        BenefitSearch.results(
            in: catalogStore.catalog,
            query: query,
            category: selectedCategory,
            ownedCardIDs: cardCollection.cardIDs,
            ownedOnly: ownedOnly,
            language: language
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("benefits.scope", selection: $ownedOnly) {
                Text("benefits.scope.myCards").tag(true)
                Text("benefits.scope.allCards").tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)

            if results.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                List(results) { result in
                    NavigationLink {
                        BenefitDetailView(
                            benefit: result.benefit,
                            cards: result.cards,
                            language: language
                        )
                    } label: {
                        BenefitRow(
                            benefit: result.benefit,
                            cards: result.cards,
                            language: language
                        )
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await catalogStore.refresh()
                }
            }
        }
        .navigationTitle("benefits.title")
        .searchable(text: $query, prompt: "benefits.search.prompt")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        selectedCategory = nil
                    } label: {
                        if selectedCategory == nil {
                            Label("benefit.category.all", systemImage: "checkmark")
                        } else {
                            Text("benefit.category.all")
                        }
                    }

                    ForEach(BenefitCategory.allCases) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            if selectedCategory == category {
                                Label(LocalizedStringKey(category.localizationKey), systemImage: "checkmark")
                            } else {
                                Label(LocalizedStringKey(category.localizationKey), systemImage: category.symbolName)
                            }
                        }
                    }
                } label: {
                    Image(systemName: selectedCategory == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                }
                .accessibilityLabel(Text("benefits.filter"))
            }
        }
        .onChange(of: cardCollection.cardIDs) { _, cardIDs in
            if cardIDs.isEmpty {
                ownedOnly = false
            }
        }
        .onAppear {
            if cardCollection.cardIDs.isEmpty {
                ownedOnly = false
            }
        }
    }
}
