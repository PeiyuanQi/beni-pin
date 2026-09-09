# Data Sourcing

## Source Policy

Use this priority order:

1. Product-specific official benefit guide or program agreement.
2. Official issuer card and benefit pages.
3. Official issuer FAQ, announcement, or support page.
4. Licensed commercial feed with explicit redistribution and image rights.
5. Editorial sources only to discover a possible change that is then verified against an official source.

Every published benefit must include a stable ID, applicable card IDs, English and Simplified Chinese summaries written for BeniPin, cadence, enrollment flag, official source URL, and `lastVerified` date. Consumption earning rates are stored separately on each card with a stable rate ID, bilingual category and qualification details, multiplier, official source URL, and verification date.

## Point Valuations

Earning-rate comparison converts rewards into an estimated return percentage. Cash-back cards use their published percentage directly. Points and miles use a local cents-per-point map keyed by rewards program, while separate stable-ID maps assign each supported card to its program and each earning rate to a comparison category.

The airline, hotel, and transferable-points program defaults use The Points Guy's July 2026 monthly valuations as a consistent cross-program benchmark: <https://thepointsguy.com/loyalty-programs/monthly-valuations/>. These estimates are editorial opinions rather than issuer-guaranteed redemption values. They are not downloaded or refreshed automatically, and users can override every value locally in Settings. Overrides never leave the device and can be reset to the bundled defaults.

## US Credit Card Guide

Do not scrape or republish US Credit Card Guide without a written agreement.

Its current terms explicitly prohibit unlicensed scraping, data mining, data extraction, and data harvesting. The site's CC BY-NC-ND 4.0 notice permits unchanged redistribution only for noncommercial use; it does not grant the commercial, translation, or adaptation rights this app would require. Public RSS, sitemap, REST, or robots access does not override those terms.

- Terms: <https://www.uscreditcardguide.com/terms-of-service-us-credit-card-guide/>
- Robots: <https://www.uscreditcardguide.com/robots.txt>
- App: <https://www.uscreditcardguide.com/ios-android-app/>

A future agreement would need to cover commercial use, automated access, translation and rewriting, caching, in-app display, attribution, images, update service levels, termination, and retained-data handling.

## Update Architecture

The iOS app is a catalog consumer, not a scraper.

The Articles tab is a navigation surface only. Its list contains direct links to the site's homepage, credit-card article categories, and card directories, and opens them in the system browser. It does not embed the site, request an article feed, copy titles or excerpts, cache pages, or infer catalog records at runtime.

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

Editorial pages may identify a candidate card for review. A candidate is added only after a human verifies the current product identity, availability, earning rates, and benefits against an official issuer or loyalty-program source.

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
- Bank of America Air France KLM: <https://www.bankofamerica.com/credit-cards/products/air-france-credit-card/>
- Hawaiian Airlines World Elite Mastercard: <https://www.hawaiianairlines.com/hawaiianmiles2/credit-card>
- Chase World of Hyatt Business: <https://creditcards.chase.com/business-credit-cards/world-of-hyatt/hyatt-business-card>
- Chase Freedom Flex: <https://creditcards.chase.com/cash-back-credit-cards/freedom/flex>
- Capital One Spark Cash: <https://www.capitalone.com/small-business/credit-cards/spark-cash/>
- Capital One Spark Cash Plus: <https://www.capitalone.com/small-business/credit-cards/spark-cash-plus/>

The discontinued Deserve EDU record is retained only so existing cardholders can find their legacy product. Its historical earning rate is sourced from the archived official cardholder agreement published by the Consumer Financial Protection Bureau: <https://files.consumerfinance.gov/a/assets/credit-card-agreements/pdf/Celtic_Bank/Deserve_EDU_Cardholder_Agreement.pdf>. The current Deserve site no longer offers that card: <https://deserve.com/>.

Issuer terms control whenever a BeniPin summary differs from current issuer material.

## Bank of America Cash and Travel Rewards

Customized Cash Rewards and Unlimited Cash Rewards use standard cash-back rates. First-year offers are described as conditional in the rate details; comparisons do not assume eligibility or a relationship-rewards tier. Customized Cash Rewards uses one choice-category row and documents the shared quarterly cap. These cash-back products have no separate recurring benefit record.

Travel Rewards defaults to 1 cent per point for eligible travel and dining statement credits, based on the issuer agreement rather than an editorial valuation; users can override this locally. Its foreign-transaction-fee benefit is informational and cannot be marked used.

- <https://www.bankofamerica.com/credit-cards/products/cash-back-credit-card/>
- <https://www.bankofamerica.com/credit-cards/products/unlimited-cash-back-credit-card/>
- <https://www.bankofamerica.com/credit-cards/products/travel-rewards-credit-card/>
- <https://www.bankofamerica.com/bofa-rewards/increasing-bofa-rewards-with-credit-cards/>
- <https://secure.bankofamerica.com/apply-now-services/credit-cards/rest/get-disclosures/v1/usa/show-in-browser?cId=4079343&isMobile=true&locale=en_US&poCd=W2>

## September 2026 Ongoing-Benefit Review

The September 1–8 post excerpts supplied by the user were used only to identify candidates. The user requested ongoing benefits and excluded welcome offers. No editorial content was scraped or copied into the catalog.

Added British Airways Visa Signature, Iberia Visa Signature, Aer Lingus Visa Signature, U.S. Bank SKYPASS Select, and IHG One Rewards Premier Business. Each includes bilingual names, curated aliases, card earning rates, and issuer-sourced benefits. IHG earning comparisons count the card's 10X, not the combined 26X marketing figure that includes separate hotel and elite-status earnings.

Fixed anniversary Avios and recurring spending bonuses use the existing `points` benefit category and are now visible in Benefits and card details. They are informational rather than marked used; purchase multipliers remain exclusively in Earning. No schema changes are required. Older app versions that explicitly hide the points category will continue to hide those bonuses until updated.

British Airways, Iberia, AerClub and Korean Air SKYPASS each have independent editable valuations initialized to 1 cent. These are neutral comparison assumptions, not issuer redemption guarantees or figures attributed to the existing July benchmark. The Settings explanation identifies this distinction. Bank of America Travel Rewards retains its issuer-backed 1-cent travel/dining redemption baseline.

### Sources checked September 9, 2026 UTC

- [British Airways card and terms](https://creditcards.chase.com/travel-credit-cards/avios/british-airways)
- [Iberia card and terms](https://creditcards.chase.com/travel-credit-cards/avios/iberia)
- [Aer Lingus card and terms](https://creditcards.chase.com/travel-credit-cards/avios/aer-lingus)
- [SKYPASS Select current benefits](https://www.skypassvisa.com/credit/visaSelectCard.do)
- [SKYPASS FAQ](https://www.skypassvisa.com/credit/faqs.do)
- [SKYPASS historical issuer booklet](https://www.skypassvisa.com/credit/skypass/pdfs/VisaSelect_Benefits_Booklet.pdf), used only to corroborate the travel-credit account-year basis, not current amounts or the current benefit lineup
- [IHG Premier Business card and terms](https://creditcards.chase.com/business-credit-cards/IHG/business-premier)
- [Sapphire Reserve current benefits](https://www.chase.com/sapphire-cards/personal/reserve)
- [Sapphire benefit terms](https://www.chase.com/personal/credit-cards/offerdetails/chasesapphire)

Sapphire Reserve's two $10 monthly non-restaurant DoorDash discounts have separate stable IDs so each can be marked used independently. Its current $5 restaurant discount is separate as well. All require activated DashPass and eligible payment/orders. Voucher, anniversary and multi-year checklist states use the existing manual-reset behavior; no account anniversary, transaction amounts or credentials are stored. SKYPASS Priority Pass and application-fee credits remain informational because the accessible current source did not establish their precise reset periods.

### Reported changes awaiting official confirmation

| Reported change | Verified public terms | Catalog decision |
| --- | --- | --- |
| IHG Business anniversary night rises to 50,000 points after December 31, 2026 | Chase still states 40,000 points, with points top-ups allowed | Retain 40,000; do not activate the reported future value without an official notice and its applicability |
| Sapphire Reserve $15 monthly DoorDash benefit beginning October 1, 2026 | Chase still states one $5 restaurant discount and two $10 non-restaurant discounts | Add current benefits; do not publish the future amount as current |

BoA welcome bonuses and Rakuten referrals, targeted Amex Offers, the Capital One transfer promotion, and the targeted Bilt Rent Day redemption offer were excluded under the user's scope. The three BoA cards already added remain supported with standard earning rates. BoA Checking, Amex Rewards Checking, and X Money are bank-account products and were not added to the credit-card catalog. The underlying Amex, Capital One and Bilt cards already exist; the excerpts identify promotions rather than new card products.
