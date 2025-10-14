//
//  ContentView.swift
//  Memory Game
//
//  Created by Victoria Huynh on 10/13/25.
//

import SwiftUI

// MARK: - Model
struct MemoryCard: Identifiable, Equatable {
    let id = UUID()
    let symbol: String              // e.g. "ladybug"
    var isFaceUp = false
    var isMatched = false
}

// MARK: - Symbols & Deck Builder
private let baseSymbols = [
    "ladybug","leaf","pawprint","flame","heart",
    "star","bolt","tortoise","ant","bicycle",
    "cloud","moon","sun.min","globe.americas","hare"
]

private func makeShuffledDeck(pairCount: Int) -> [MemoryCard] {
    let safe = max(1, min(pairCount, baseSymbols.count))
    let chosen = Array(baseSymbols.prefix(safe))
    return (chosen + chosen).shuffled().map { MemoryCard(symbol: $0) }
}

// MARK: - View
struct ContentView: View {
    @State private var pairCount: Int = 6
    @State private var cards: [MemoryCard] = []
    @State private var indexOfFaceUpCard: Int? = nil   // first flipped (if any)
    @State private var isResolvingPair = false         // blocks taps during flip-back
    @State private var deckId: Int = 0                 // workaround to force reloads if needed

    // Grid columns for 3 / 6 / 10 pairs = 6 / 12 / 20 cards
    private var columns: [GridItem] {
        let total = pairCount * 2
        let colCount: Int
        switch total {
        case ...6:       colCount = 3   // 3 pairs: 2 rows x 3 columns
        case 7...12:     colCount = 4   // 6 pairs
        default:         colCount = 5   // 10 pairs
        }
        return Array(repeating: GridItem(.flexible()), count: colCount)
    }

    // Optional: show Play Again when done
    private var allMatched: Bool {
        !cards.isEmpty && cards.allSatisfy { $0.isMatched }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Menu {
                        // choices
                        Button("3 pairs")  { pairCount = 3 }
                        Button("6 pairs")  { pairCount = 6 }
                        Button("10 pairs") { pairCount = 10 }
                    } label: {
                        // the orange "button" label
                        Label("\(pairCount) Pairs ", systemImage: "chevron.down")
                            .font(.body)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent) // makes it a button
                        .tint(.orange)                    // make it orange
                        .accessibilityLabel("Select number of pairs")
                    Spacer()
                

                // Grid
                ScrollView {
                    let cols = columns // precompute to keep the type-checker happy
                    LazyVGrid(columns: cols, spacing: 12) {
                        ForEach(cards) { card in
                            CardView(card: card)
                                .onTapGesture { handleTap(card) }
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(duration: 0.25), value: card.isFaceUp)
                                .animation(.spring(duration: 0.25), value: card.isMatched)
                        }
                    }
                    .padding(.horizontal)
                }
            }
                        
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if allMatched {
                        Button("Play Again") {
                            withAnimation(.easeInOut) { resetGame() }
                        }
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Reset Game") {
                        withAnimation(.easeInOut) { resetGame() }
                    }
                }
            }
            .id(deckId) // force reload if SwiftUI caches the deck layout
            .onAppear { resetGame() }
            .onChange(of: pairCount) { _ in
                withAnimation(.easeInOut) { resetGame() }
            }
        }
    }

    // MARK: - Game Logic (KEEP THESE INSIDE ContentView)
    private func resetGame() {
        cards = makeShuffledDeck(pairCount: pairCount)
        indexOfFaceUpCard = nil
        isResolvingPair = false
        deckId &+= 1
    }

    private func handleTap(_ tapped: MemoryCard) {
        guard !isResolvingPair else { return }
        guard let i = cards.firstIndex(of: tapped) else { return }
        guard !cards[i].isMatched, !cards[i].isFaceUp else { return }

        cards[i].isFaceUp = true

        if let first = indexOfFaceUpCard {
            isResolvingPair = true
            resolvePair(firstIndex: first, secondIndex: i)
        } else {
            indexOfFaceUpCard = i
        }
    }

    private func resolvePair(firstIndex: Int, secondIndex: Int) {
        if cards[firstIndex].symbol == cards[secondIndex].symbol {
            cards[firstIndex].isMatched = true
            cards[secondIndex].isMatched = true
            indexOfFaceUpCard = nil
            isResolvingPair = false
        } else {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 700_000_000) // 0.7s
                if firstIndex < cards.count { cards[firstIndex].isFaceUp = false }
                if secondIndex < cards.count { cards[secondIndex].isFaceUp = false }
                indexOfFaceUpCard = nil
                isResolvingPair = false
            }
        }
    }
}

#Preview {
    ContentView()
}
