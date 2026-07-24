import SwiftUI

struct CardArtworkView: View {
    let card: CardProduct
    let language: AppLanguage
    var compact = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: card.artwork.primaryHex), Color(hex: card.artwork.secondaryHex)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: compact ? 70 : 170)
                .offset(x: compact ? 42 : 110, y: compact ? -28 : -70)

            if let remoteImageURL = card.artwork.remoteImageURL {
                AsyncImage(url: remoteImageURL) { phase in
                    if case let .success(image) = phase {
                        image
                            .resizable()
                            .scaledToFill()
                    }
                }
            }

            VStack(alignment: .leading, spacing: compact ? 4 : 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: compact ? 1 : 3) {
                        Text(card.issuer.uppercased())
                            .font(compact ? .system(size: 7, weight: .semibold) : .caption2)
                            .lineLimit(1)

                        Text(card.name.value(for: language))
                            .font(compact ? .caption2 : .headline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .minimumScaleFactor(compact ? 0.72 : 0.65)
                    }

                    Spacer(minLength: 8)

                    Text(card.network.displayName)
                        .font(compact ? .caption2 : .caption)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer(minLength: 4)

                Image(systemName: card.artwork.symbolName)
                    .font(compact ? .caption : .title2)
                    .foregroundStyle(Color(hex: card.artwork.accentHex))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(.white)
            .padding(compact ? 10 : 18)
            .shadow(color: .black.opacity(0.18), radius: 8, y: 3)
        }
        .aspectRatio(1.586, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(.white.opacity(0.18), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(card.issuer), \(card.name.value(for: language))")
    }
}
