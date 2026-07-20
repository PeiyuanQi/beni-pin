# Agent Instructions

## Compatibility

- `CLAUDE.md` is the Claude Code bridge to this instruction file.

## Project Context

- Read `README.md` for the human development flow and current project status.
- This repository contains a native SwiftUI iOS app targeting iOS 17 and later.
- The app is privacy-first: persist only catalog product IDs and benefit usage state. Do not add PAN, expiration date, CVV, account balance, transaction, or credential storage.
- A normal third-party app cannot enumerate arbitrary Apple Wallet payment cards. Keep manual card selection as the primary workflow unless Apple grants a product-specific entitlement and the design is updated with evidence.
- Treat `catalog/catalog.v1.json` as the catalog source of truth. Stable card and benefit IDs must not be reused for materially different products or benefits.
- Keep documentation aligned when behavior, APIs, data shapes, dependencies, or workflows change.

## Git Workflow

- Prefer git worktrees for parallel or unrelated agent work so multiple agents can develop concurrently without colliding.
- Put project-local worktrees under `.worktrees/`; that directory is ignored by Git.
- Treat existing uncommitted changes as user-owned unless explicitly told otherwise.
- Keep changes scoped and prefer rebase-based conflict resolution unless the repository later adopts a different strategy.

## Coding Rules

- Follow repository lint, format, naming, and type-checking configuration as it is introduced.
- Use SwiftUI, Foundation, PassKit capability checks, URLSession, and BackgroundTasks before adding runtime dependencies.
- Keep UI and catalog content localized in English and `zh-Hans`; search must match both languages regardless of the selected UI language.
- Do not automate ingestion from a website unless its terms or a written agreement explicitly allow the intended scraping, transformation, translation, caching, and redistribution.
- Prefer official issuer terms and benefit guides. Every benefit must keep an official source URL and `lastVerified` date.
- Check license compatibility before adding third-party code, assets, fonts, icons, or tools, and record required notices.

## Verification

- Run `git diff --check` for documentation-only changes.
- Run core tests with `swift test --disable-sandbox --scratch-path /tmp/BeniPinSwiftBuild`.
- Build without signing with `xcodebuild -project BeniPin.xcodeproj -scheme BeniPin -configuration Debug -destination 'generic/platform=iOS' -derivedDataPath /tmp/BeniPinDerivedData CODE_SIGNING_ALLOWED=NO build`.
- When a compatible simulator runtime is installed, run hosted tests with `xcodebuild -project BeniPin.xcodeproj -scheme BeniPin -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`.
- Verify catalog changes through `CatalogTests`, bilingual search through `BenefitSearchTests`, and local persistence or period behavior through `UserStateTests`.
- For UI changes, inspect at least one English and one Simplified Chinese simulator screenshot at an iPhone viewport. Check Dynamic Type separately before App Store submission.
