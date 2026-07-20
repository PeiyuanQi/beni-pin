# Product Boundaries

## Apple Wallet

A normal third-party iOS app cannot ask the user for permission and then enumerate every payment card in Apple Wallet.

- `PKPassLibrary.passes()` returns passes the app is entitled to access, normally passes associated with the developer's own pass type identifiers.
- Secure Element and payment-pass access is intended for participating issuers and requires card-specific relationships and restricted entitlements.
- Apple Pay capability checks can answer whether a supported network may be available, but they do not return issuer, card product, card image, card count, or default-card details.
- Payment-method details become available only during a legitimate user-authorized payment. Apple Pay must not be invoked solely to inspect Wallet contents.

BeniPin therefore:

- uses bank and card-product search as the primary add flow;
- stores only the selected internal card product ID;
- does not show a fake Wallet permission prompt;
- does not initiate a zero-dollar or non-payment Apple Pay sheet;
- may add FinanceKit or issuer integrations later only when eligibility, entitlements, privacy disclosures, and product scope are proven.

Apple references:

- <https://developer.apple.com/documentation/passkit/pkpasslibrary/passes()>
- <https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.pass-type-identifiers>
- <https://developer.apple.com/documentation/passkit/pkpaymentauthorizationviewcontroller/canmakepayments(usingnetworks:)>
- <https://developer.apple.com/financekit/>
- <https://developer.apple.com/support/terms/apple-developer-program-license-agreement/>

## Privacy

The MVP has no account, analytics SDK, ad SDK, bank login, or cloud sync.

Local user state contains:

- selected card product IDs;
- used or unused status keyed by card product, benefit, and supported period.

Catalog update requests do not contain local ownership or usage state. The app does not request card number, expiration date, security code, cardholder name, balance, transaction, contact, photo, or location access.

## Card Artwork

The starter catalog uses original neutral artwork rendered in SwiftUI. It does not copy issuer card images or third-party editorial assets. `remoteImageURL` is reserved for assets with documented downstream display rights.

## Usage Periods

Monthly, quarterly, semiannual, and calendar-year statuses reset from the device calendar. Card-anniversary and four-year benefits remain manually controlled because the MVP does not collect account-open dates or previous application dates. Do not infer a false reset date.
