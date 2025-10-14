import SwiftUI

struct CardView: View {
    let card: MemoryCard

    var body: some View {
        ZStack {
            if card.isFaceUp {
                // Front
                RoundedRectangle(cornerRadius: 14)
                    .fill(.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(.primary.opacity(0.2), lineWidth: 1)
                    )
                Image(systemName: card.symbol)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.primary)
            } else {
                // Back
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(colors: [.blue, .indigo],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(.white.opacity(0.25), lineWidth: 2)
                    )
            }
        }
        .frame(height: 150)
        .opacity(card.isMatched ? 0 : 1) // disappear when matched
        .accessibilityLabel(card.isMatched ? "Matched"
                           : (card.isFaceUp ? "Face up \(card.symbol)" : "Face down"))
    }
}

#Preview {
    VStack {
        CardView(card: MemoryCard(symbol: "ladybug", isFaceUp: true))
        CardView(card: MemoryCard(symbol: "ladybug"))
        CardView(card: MemoryCard(symbol: "ladybug", isMatched: true))
    }
    .padding()
}
