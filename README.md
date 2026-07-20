# BeniPin

BeniPin is a privacy-first native iOS app for organizing U.S. credit-card benefits. It supports English and Simplified Chinese, lets users add cards by issuer or product, searches benefits across owned or all cards, and tracks whether recurring benefits were used in the current period.

The app stores only catalog product IDs and local usage state. It does not request or store card numbers, expiration dates, security codes, balances, or transactions.

## Current MVP

- Native SwiftUI app targeting iOS 17 and later.
- English and Simplified Chinese UI plus bilingual catalog search.
- Searchable manual card catalog grouped by issuer.
- My Cards grid with neutral, original card artwork.
- Benefit search by title, description, issuer, card family, and category.
- My Cards and All Cards search scopes.
- Local used/unused tracking for monthly, quarterly, semiannual, annual, anniversary, and four-year benefits.
- Bundled last-known-good catalog with validated remote JSON updates, ETag support, atomic cache replacement, pull-to-refresh, and opportunistic background refresh.
- Five starter card products and 24 benefits summarized from official issuer sources.

Apple does not provide a public permission flow that lets a normal third-party app enumerate all payment cards in Apple Wallet. BeniPin explains that limitation and uses manual selection rather than a fake Apple Pay transaction or misleading Wallet authorization flow. See [Product Boundaries](docs/product-boundaries.md).

## Development Flow

- Read `AGENTS.md` before using a coding agent in this repository.
- Prefer a git worktree for parallel or unrelated work. Project-local worktrees belong under `.worktrees/`.
- Requirements: Xcode with the iOS 17 SDK or later. The current project was verified with Xcode 26.6 and Swift 6.3.3.
- Setup: open `BeniPin.xcodeproj`; no third-party runtime dependencies are required.
- Run locally: select the `BeniPin` scheme, choose an iPhone or iPad simulator, and press Run.
- Core tests:

  ```sh
  swift test --disable-sandbox --scratch-path /tmp/BeniPinSwiftBuild
  ```

- Generic device build without signing:

  ```sh
  xcodebuild -project BeniPin.xcodeproj -scheme BeniPin \
    -configuration Debug -destination 'generic/platform=iOS' \
    -derivedDataPath /tmp/BeniPinDerivedData \
    CODE_SIGNING_ALLOWED=NO build
  ```

- Hosted iOS tests, when a compatible simulator runtime is installed:

  ```sh
  xcodebuild -project BeniPin.xcodeproj -scheme BeniPin \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
  ```

- Documentation-only verification: `git diff --check`.

## Catalog Updates

The canonical catalog is [`catalog/catalog.v1.json`](catalog/catalog.v1.json). The app ships that file in its bundle and checks the same path on `origin/main` through GitHub Raw. Remote content must pass schema and cross-reference validation before it replaces the local cache; a corrupt cache is ignored in favor of the bundled catalog.

Update workflow:

1. Verify facts against official issuer product pages or benefit guides.
2. Rewrite concise English and Chinese summaries; do not copy editorial wording.
3. Update `lastVerified`, `generatedAt`, source URLs, and stable IDs.
4. Run the core tests and generic device build above.
5. Review the diff before publishing to `main`.

Automated scraping of US Credit Card Guide is intentionally not implemented because its terms prohibit unlicensed scraping and its content license is not suitable for this product. See [Data Sourcing](docs/data-sourcing.md).

## Repository Layout

```text
BeniPin/                 SwiftUI app, domain models, and services
BeniPinTests/            Catalog, search, and local-state tests
catalog/                 Versioned benefit catalog published to the app
docs/                    Product, privacy, and sourcing decisions
BeniPin.xcodeproj/       Checked-in Xcode project and shared scheme
Package.swift            macOS-runnable core test target
```
