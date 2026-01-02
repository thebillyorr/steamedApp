//
//  DeckSelectionView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-22.
//

import SwiftUI

struct DeckSelectionView: View {
    let currentDeck: Topic
    let onSelect: (Topic) -> Void
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var progressStore = ProgressStore.shared
    
    var availableDecks: [Topic] {
        DataService.allTopics.filter { $0.filename != currentDeck.filename }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Separate "My Bookmarks" if it exists and isn't the current deck
                        if let bookmarks = availableDecks.first(where: { $0.filename == "bookmarks_deck" }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("MY COLLECTION")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 4)
                                
                                DeckSelectionCard(topic: bookmarks) {
                                    onSelect(bookmarks)
                                    dismiss()
                                }
                            }
                        }
                        
                        // Other Decks
                        let otherDecks = availableDecks.filter { $0.filename != "bookmarks_deck" }
                        if !otherDecks.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ALL DECKS")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 4)
                                    .padding(.top, 8)
                                
                                ForEach(otherDecks) { topic in
                                    DeckSelectionCard(topic: topic) {
                                        onSelect(topic)
                                        dismiss()
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Select Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DeckSelectionCard: View {
    let topic: Topic
    let onTap: () -> Void
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var deckMasteryManager = DeckMasteryManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 16) {
                // Icon Section
                ZStack {
                    if topic.icon == "Logo" {
                        Image("Logo")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(isDeckMastered ? .orange : (colorScheme == .dark ? .steamedBlue : .steamedDarkBlue))
                    } else {
                        Image(systemName: topic.icon)
                            .font(.system(size: 32))
                            .foregroundColor(isDeckMastered ? .orange : (colorScheme == .dark ? .steamedBlue : .steamedDarkBlue))
                    }
                }
                .frame(width: 60, height: 60)
                
                // Content Section
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(topic.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if isDeckMastered {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 14))
                        }
                    }
                    
                    // Progress Bar
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(getWordCount()) words")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(calculateMastery()))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(isDeckMastered ? .orange : .secondary)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(
                                        isDeckMastered ?
                                        LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing) :
                                        LinearGradient(colors: [.steamedBlue, .steamedDarkBlue], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .frame(width: geo.size.width * (calculateMastery() / 100), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var isDeckMastered: Bool {
        (topic.filename == "bookmarks_deck" ? false : deckMasteryManager.isDeckMastered(filename: topic.filename)) || calculateMastery() >= 100
    }
    
    private func calculateMastery() -> Double {
        let words = DataService.loadWords(for: topic)
        guard !words.isEmpty else { return 0 }
        
        let totalProgress = words.reduce(0) { total, word in
            total + progressStore.getProgress(for: word.hanzi)
        }
        
        let percentage = (totalProgress / Double(words.count)) * 100
        return min(percentage, 100)
    }
    
    private func getWordCount() -> Int {
        DataService.loadWords(for: topic).count
    }
}

#Preview {
    DeckSelectionView(
        currentDeck: DataService.allTopics[0],
        onSelect: { _ in }
    )
}
