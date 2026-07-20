import Foundation

@MainActor
final class CatalogStore: ObservableObject {
    enum Phase: Equatable {
        case loading
        case ready
        case failed(String)
    }

    @Published private(set) var catalog = CardCatalog.empty
    @Published private(set) var origin: CatalogOrigin = .bundled
    @Published private(set) var phase: Phase = .loading
    @Published private(set) var isRefreshing = false
    @Published private(set) var refreshMessage: String?

    private let repository: CatalogRepository

    init(repository: CatalogRepository = CatalogRepository()) {
        self.repository = repository
    }

    func start() async {
        do {
            apply(try await repository.loadBestAvailable())
            phase = .ready
        } catch {
            phase = .failed(error.localizedDescription)
            return
        }

        if await repository.shouldRefresh() {
            await refresh(showFailure: false)
        }
    }

    func reloadLocalCatalog() async {
        guard let snapshot = try? await repository.loadBestAvailable() else { return }
        apply(snapshot)
        phase = .ready
    }

    func refresh(showFailure: Bool = true) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            apply(try await repository.refreshFromRemote())
            phase = .ready
            refreshMessage = nil
        } catch {
            if showFailure {
                refreshMessage = error.localizedDescription
            }
        }
    }

    func clearRefreshMessage() {
        refreshMessage = nil
    }

    private func apply(_ snapshot: CatalogSnapshot) {
        catalog = snapshot.catalog
        origin = snapshot.origin
    }
}
