import SwiftUI

struct EarningRateRow: View {
    let result: EarningRateResult
    let language: AppLanguage
    var showsCardName = true

    @ScaledMetric(relativeTo: .title3) private var badgeWidth = 60.0

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(result.effectiveReturnPercent, format: .number.precision(.fractionLength(0...2)))
                    .font(.title3.bold())
                    .foregroundStyle(Color(hex: "197466"))
                Text("%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(hex: "197466"))
            }
            .frame(minWidth: badgeWidth, minHeight: 48)
            .fixedSize(horizontal: true, vertical: false)
            .background(Color(hex: "DDEFEA"), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(showsCardName
                        ? result.card.name.value(for: language)
                        : result.earningRate.category.value(for: language))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer(minLength: 8)
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }

                if showsCardName {
                    Text(result.earningRate.category.value(for: language))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 5) {
                    Text(result.earningRate.displayText)
                        .fontWeight(.semibold)

                    if let pointValueCents = result.pointValueCents {
                        Text("×")
                            .foregroundStyle(.tertiary)
                        Text(pointValueCents, format: .number.precision(.fractionLength(0...2)))
                        Text("earnings.centsPerPoint.short")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
