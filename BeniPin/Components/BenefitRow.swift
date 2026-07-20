import SwiftUI

struct BenefitRow: View {
    let benefit: CardBenefit
    let cards: [CardProduct]
    let language: AppLanguage
    var isCompleted: Bool? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: benefit.category.symbolName)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color(hex: "197466"))
                .frame(width: 32, height: 32)
                .background(Color(hex: "DDEFEA"), in: RoundedRectangle(cornerRadius: 8))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(benefit.title.value(for: language))
                        .font(.headline)
                        .foregroundStyle(isCompleted == true ? .secondary : .primary)
                    Spacer(minLength: 4)
                    if isCompleted == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(hex: "197466"))
                            .accessibilityLabel(Text("benefit.status.used"))
                    }
                }

                Text(benefit.summary.value(for: language))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                HStack(spacing: 6) {
                    Text(LocalizedStringKey(benefit.cadence.localizationKey))
                    if let firstCard = cards.first {
                        Text("·")
                        Text(firstCard.name.value(for: language))
                            .lineLimit(1)
                    }
                    if cards.count > 1 {
                        Text("+\(cards.count - 1)")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .accessibilityHidden(true)
                    Text("benefit.checked")
                    Text(benefit.lastVerified, format: .dateTime.year().month(.abbreviated).day())
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
