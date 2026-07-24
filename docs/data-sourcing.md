# Data Sourcing

## Source Policy

Use this priority order:

1. Product-specific official benefit guide or program agreement.
2. Official issuer card and benefit pages.
3. Official issuer FAQ, announcement, or support page.
4. Licensed commercial feed with explicit redistribution and image rights.
5. Editorial sources only to discover a possible change that is then verified against an official source.

Every published benefit must include a stable ID, applicable card IDs, English and Simplified Chinese summaries written for BeniPin, cadence, enrollment flag, official source URL, and `lastVerified` date. Consumption earning rates are stored separately on each card with a stable rate ID, bilingual category and qualification details, multiplier, official source URL, and verification date.

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

Card discovery in the app searches every product in the downloaded BeniPin catalog, including bilingual earning-rate text and curated product aliases. Expanding the catalog requires publishing additional issuer-verified card records; the app must not fall back to live searches of editorial websites.

The app checks the reviewed GitHub Raw catalog on foreground launch and schedules an opportunistic `BGAppRefreshTask` no earlier than 24 hours later. iOS decides whether and when background work runs, so this is not a guaranteed cron schedule. Manual pull-to-refresh and Settings refresh are always available.

## Current Official Sources

- American Express Platinum: <https://www.americanexpress.com/us/credit-cards/card/platinum/>
- American Express Gold: <https://www.americanexpress.com/us/credit-cards/card/gold-card/>
- Chase Sapphire Reserve: <https://www.chase.com/sapphire-cards/personal/reserve>
- Chase Sapphire Preferred: <https://www.chase.com/sapphire-cards/personal/preferred>
- Capital One Venture X: <https://www.capitalone.com/credit-cards/venture-x/>
- Chase United Club: <https://creditcards.chase.com/travel-credit-cards/united/club-infinite>
- Chase Freedom Unlimited: <https://creditcards.chase.com/cash-back-credit-cards/freedom/unlimited>
- Chase World of Hyatt: <https://creditcards.chase.com/travel-credit-cards/world-of-hyatt-credit-card>
- Chase IHG One Rewards Premier: <https://creditcards.chase.com/travel-credit-cards/ihg-rewards-club/premier>
- Discover it Cash Back: <https://www.discover.com/credit-cards/cash-back/it-card/>
- Bilt card lineup: <https://www.bilt.com/card>
- American Express Marriott Bonvoy Brilliant: <https://www.americanexpress.com/us/credit-cards/card/marriott-bonvoy-brilliant/>
- Bank of America Atmos Rewards Ascent: <https://www.bankofamerica.com/credit-cards/products/alaska-airlines-credit-card/>
- Bank of America Atmos Rewards Summit: <https://www.bankofamerica.com/credit-cards/products/alaska-airlines-infinite-credit-card/>
- Citi Strata card lineup: <https://www.citi.com/credit-cards/citi-strata-all-cards>
- Citi Strata: <https://www.citi.com/credit-cards/citi-strata-credit-card>
- Citi Strata Premier: <https://www.citi.com/credit-cards/citi-strata-premier-credit-card>
- Citi Strata Elite: <https://www.citi.com/credit-cards/citi-strata-elite-credit-card>

The discontinued Deserve EDU record is retained only so existing cardholders can find their legacy product. Its historical earning rate is sourced from the archived official cardholder agreement published by the Consumer Financial Protection Bureau: <https://files.consumerfinance.gov/a/assets/credit-card-agreements/pdf/Celtic_Bank/Deserve_EDU_Cardholder_Agreement.pdf>. The current Deserve site no longer offers that card: <https://deserve.com/>.

Issuer terms control whenever a BeniPin summary differs from current issuer material.
