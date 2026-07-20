import SwiftUI

struct BenefitSearchView: View {
    let language: AppLanguage

    @EnvironmentObject private var catalogStore: CatalogStore
    @EnvironmentObject private var cardCollection: UserCardCollection
    @State private var query = ""
    @State private var ownedOnly = true
    @State private var selectedCategory: BenefitCategory?

    private var availableCategories: [BenefitCategory] {
        BenefitCategory.allCases.filter { category in
            catalogStore.catalog.benefits.contains { $0.category == category }
        }
    }

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
            searchField
            categoryFilter

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

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            TextField("benefits.search.prompt", text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("benefits.search.clear"))
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                categoryButton(
                    title: LocalizedStringKey("benefit.category.all"),
                    symbolName: "square.grid.2x2",
                    category: nil
                )

                ForEach(availableCategories) { category in
                    categoryButton(
                        title: LocalizedStringKey(category.localizationKey),
                        symbolName: category.symbolName,
                        category: category
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.vertical, 8, for: .scrollContent)
    }

    private func categoryButton(
        title: LocalizedStringKey,
        symbolName: String,
        category: BenefitCategory?
    ) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            withAnimation(.snappy) {
                selectedCategory = category
            }
        } label: {
            Label(title, systemImage: isSelected ? "checkmark" : symbolName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(
                    isSelected ? Color(hex: "197466") : Color.secondary.opacity(0.12),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
