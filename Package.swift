// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BeniPinCore",
    platforms: [
        .macOS(.v13),
        .iOS(.v17)
    ],
    products: [
        .library(name: "BeniPinCore", targets: ["BeniPinCore"])
    ],
    targets: [
        .target(
            name: "BeniPinCore",
            path: "BeniPin",
            exclude: [
                "App",
                "Components",
                "Features",
                "Resources",
                "Utilities",
                "Services/BackgroundRefreshCoordinator.swift",
                "Services/CatalogStore.swift",
                "Services/WalletCapability.swift"
            ],
            sources: [
                "Localization/AppLanguage.swift",
                "Models/BenefitSearch.swift",
                "Models/CardCatalog.swift",
                "Models/LocalizedCopy.swift",
                "Services/BenefitUsageStore.swift",
                "Services/CatalogRepository.swift",
                "Services/UserCardCollection.swift"
            ]
        ),
        .testTarget(
            name: "BeniPinCoreTests",
            dependencies: ["BeniPinCore"],
            path: "BeniPinTests"
        )
    ]
)
