import Foundation

enum CatalogOrigin: String, Equatable, Sendable {
    case bundled
    case cached
    case remote

    var localizationKey: String {
        "catalog.origin.\(rawValue)"
    }
}

struct CatalogSnapshot: Equatable, Sendable {
    let catalog: CardCatalog
    let origin: CatalogOrigin
}

actor CatalogRepository {
    static let productionURL = URL(
        string: "https://raw.githubusercontent.com/PeiyuanQi/beni-pin/main/catalog/catalog.v1.json"
    )!

    private let bundledCatalogURL: URL?
    private let fileManager: FileManager
    private let defaults: UserDefaults
    private let remoteURL: URL
    private let loadRemoteData: @Sendable (URLRequest) async throws -> (Data, URLResponse)
    private let cacheDirectoryURL: URL

    private let etagKey = "catalogRemoteETag"
    private let lastCheckKey = "catalogLastRemoteCheck"

    init(
        bundle: Bundle = .main,
        fileManager: FileManager = .default,
        defaults: UserDefaults = .standard,
        remoteURL: URL = CatalogRepository.productionURL,
        session: URLSession = .shared,
        bundledCatalogURL: URL? = nil,
        cacheDirectoryURL: URL? = nil,
        dataLoader: (@Sendable (URLRequest) async throws -> (Data, URLResponse))? = nil
    ) {
        self.bundledCatalogURL = bundledCatalogURL
            ?? bundle.url(forResource: "catalog.v1", withExtension: "json")
        self.fileManager = fileManager
        self.defaults = defaults
        self.remoteURL = remoteURL
        self.loadRemoteData = dataLoader ?? { request in
            try await session.data(for: request)
        }
        self.cacheDirectoryURL = cacheDirectoryURL
            ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                .appendingPathComponent("BeniPin", isDirectory: true)
    }

    func loadBestAvailable() throws -> CatalogSnapshot {
        var candidates: [CatalogSnapshot] = []

        if let bundledURL = bundledCatalogURL {
            let catalog = try decodeCatalog(Data(contentsOf: bundledURL))
            candidates.append(CatalogSnapshot(catalog: catalog, origin: .bundled))
        }

        if fileManager.fileExists(atPath: cacheURL.path) {
            if let data = try? Data(contentsOf: cacheURL),
               let catalog = try? decodeCatalog(data) {
                candidates.append(CatalogSnapshot(catalog: catalog, origin: .cached))
            }
        }

        guard let newest = candidates.max(by: { $0.catalog.generatedAt < $1.catalog.generatedAt }) else {
            throw CatalogRepositoryError.noCatalogAvailable
        }
        return newest
    }

    func shouldRefresh(maxAge: TimeInterval = 24 * 60 * 60, now: Date = Date()) -> Bool {
        guard let lastCheck = defaults.object(forKey: lastCheckKey) as? Date else {
            return true
        }
        return now.timeIntervalSince(lastCheck) >= maxAge
    }

    func refreshFromRemote() async throws -> CatalogSnapshot {
        var request = URLRequest(url: remoteURL)
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let etag = defaults.string(forKey: etagKey) {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        let (data, response) = try await loadRemoteData(request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CatalogRepositoryError.invalidResponse
        }

        if httpResponse.statusCode == 304 {
            defaults.set(Date(), forKey: lastCheckKey)
            return try loadBestAvailable()
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw CatalogRepositoryError.httpStatus(httpResponse.statusCode)
        }

        let catalog = try decodeCatalog(data)
        if let current = try? loadBestAvailable(), catalog.generatedAt < current.catalog.generatedAt {
            defaults.set(Date(), forKey: lastCheckKey)
            return current
        }

        try fileManager.createDirectory(at: cacheURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: cacheURL, options: .atomic)

        if let etag = httpResponse.value(forHTTPHeaderField: "ETag") {
            defaults.set(etag, forKey: etagKey)
        }
        defaults.set(Date(), forKey: lastCheckKey)

        return CatalogSnapshot(catalog: catalog, origin: .remote)
    }

    private var cacheURL: URL {
        cacheDirectoryURL.appendingPathComponent("catalog.v1.json")
    }

    private func decodeCatalog(_ data: Data) throws -> CardCatalog {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let catalog = try decoder.decode(CardCatalog.self, from: data)
        try catalog.validate()
        return catalog
    }
}

enum CatalogRepositoryError: LocalizedError, Equatable {
    case noCatalogAvailable
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .noCatalogAvailable:
            return "No bundled or cached catalog is available."
        case .invalidResponse:
            return "The catalog server returned an invalid response."
        case let .httpStatus(status):
            return "The catalog server returned HTTP \(status)."
        }
    }
}
