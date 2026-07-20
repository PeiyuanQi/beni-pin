# Data Sourcing

## Source Policy

Use this priority order:

1. Product-specific official benefit guide or program agreement.
2. Official issuer card and benefit pages.
3. Official issuer FAQ, announcement, or support page.
4. Licensed commercial feed with explicit redistribution and image rights.
5. Editorial sources only to discover a possible change that is then verified against an official source.

Every published benefit must include a stable ID, applicable card IDs, English and Simplified Chinese summaries written for BeniPin, cadence, enrollment flag, official source URL, and `lastVerified` date.

## US Credit Card Guide

Do not scrape or republish US Credit Card Guide without a written agreement.

Its current terms explicitly prohibit unlicensed scraping, data mining, data extraction, and data harvesting. The site's CC BY-NC-ND 4.0 notice permits unchanged redistribution only for noncommercial use; it does not grant the commercial, translation, or adaptation rights this app would require. Public RSS, sitemap, REST, or robots access does not override those terms.

- Terms: <https://www.uscreditcardguide.com/terms-of-service-us-credit-card-guide/>
- Robots: <https://www.uscreditcardguide.com/robots.txt>
- App: <https://www.uscreditcardguide.com/ios-android-app/>

A future agreement would need to cover commercial use, automated access, translation and rewriting, caching, in-app display, attribution, images, update service levels, termination, and retained-data handling.

## Update Architecture

The iOS app is a catalog consumer, not a scraper.

```text
approved issuer sources
        |
        v
candidate change detection
        |
        v
schema validation + human review
        |
        v
catalog/catalog.v1.json on main
        |
        v
bundled seed / ETag download / atomic cache
```

Recommended operating cadence:

- check approved issuer pages weekly for structural or content changes;
- review highly volatile statement credits at least monthly;
- re-verify every active record before an App Store release;
- publish only after a human confirms the applicable product version, network, effective date, amount, cadence, enrollment requirement, and exclusions.

The app checks the reviewed GitHub Raw catalog on foreground launch and schedules an opportunistic `BGAppRefreshTask` no earlier than 24 hours later. iOS decides whether and when background work runs, so this is not a guaranteed cron schedule. Manual pull-to-refresh and Settings refresh are always available.

## Starter Official Sources

- American Express Platinum: <https://www.americanexpress.com/us/credit-cards/card/platinum/>
- American Express Gold: <https://www.americanexpress.com/us/credit-cards/card/gold-card/>
- Chase Sapphire Reserve: <https://www.chase.com/sapphire-cards/personal/reserve>
- Chase Sapphire Preferred: <https://www.chase.com/sapphire-cards/personal/preferred>
- Capital One Venture X: <https://www.capitalone.com/credit-cards/venture-x/>

Issuer terms control whenever a BeniPin summary differs from current issuer material.
