//
//  DictionaryView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import SwiftUI

struct DictionaryView: View {
    let decks = DataService.decks
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var deckMasteryManager = DeckMasteryManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Bookmarks Section (Large)
                    BookmarkedDeckView()
                        .padding(.horizontal, 16)
                        .frame(height: 200) // Give it some height
                    
                    // Themed Decks Section (Modern Swimlanes)
                    if true {
                        let groupedDecks = Dictionary(grouping: decks) { $0.category }
                        let categoryOrder = ["Entertainment", "Nature & Outdoors", "Living in China", "Travel", "Speak like a Local"]
                        
                        VStack(spacing: 32) {
                            ForEach(categoryOrder, id: \.self) { category in
                                if let categoryDecks = groupedDecks[category] {
                                    DeckSwimlaneSection(
                                        title: category,
                                        decks: categoryDecks,
                                        progressStore: progressStore,
                                        deckMasteryManager: deckMasteryManager
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dictionary")
            .navigationDestination(for: Topic.self) { topic in
                DeckView(topic: topic)
            }
        }
    }
    
    private func calculateTopicMastery(for topic: Topic) -> Double {
        let words = DataService.loadWords(for: topic)
        guard !words.isEmpty else { return 0.0 }
        
        let totalMastery = words.reduce(0.0) { sum, word in
            sum + progressStore.getProgress(for: word.hanzi)
        }
        
        return totalMastery / Double(words.count)
    }
    
    private func isAllWordsMastered(for topic: Topic) -> Bool {
        let words = DataService.loadWords(for: topic)
        guard !words.isEmpty else { return false }
        return words.allSatisfy { progressStore.getProgress(for: $0.hanzi) >= 1.0 }
    }
}

struct DictionaryDeckCard: View {
    let topic: Topic
    let masteryProgress: Double
    let isDeckMastered: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Icon Section
            ZStack {
                Image(systemName: topic.icon)
                    .font(.system(size: 32))
                    // Orange if mastered, otherwise adaptive blue
                    .foregroundColor(isDeckMastered ? .orange : (colorScheme == .dark ? .steamedBlue : .steamedDarkBlue))
            }
            .frame(width: 70, height: 70)
            
            // Content Section
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(topic.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                // Progress Bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(isDeckMastered ? "Mastered" : "\(Int(masteryProgress * 100))% Mastered")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
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
                                .frame(width: geo.size.width * CGFloat(masteryProgress), height: 6)
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
        .background(Color(.secondarySystemGroupedBackground)) // Better contrast in dark mode
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}

#Preview {
    DictionaryView()
}
