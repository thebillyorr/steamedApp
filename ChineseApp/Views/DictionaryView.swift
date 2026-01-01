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
                    
                    // Themed Decks Section
                    VStack(alignment: .leading, spacing: 24) {
                        let groupedDecks = Dictionary(grouping: decks) { $0.category }
                        // Define custom order for categories
                        let categoryOrder = ["Entertainment", "Nature & Outdoors", "Living in China", "Travel", "Speak like a Local"]
                        
                        ForEach(categoryOrder, id: \.self) { category in
                            if let categoryDecks = groupedDecks[category] {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(category)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 16)
                                    
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 16)], spacing: 16) {
                                        ForEach(categoryDecks) { topic in
                                            NavigationLink(value: topic) {
                                                let topicMastery = calculateTopicMastery(for: topic)
                                                let isDeckMastered = deckMasteryManager.isDeckMastered(filename: topic.filename) || isAllWordsMastered(for: topic)
                                                DeckCardView(
                                                    topic: topic,
                                                    masteryProgress: topicMastery,
                                                    isDeckMastered: isDeckMastered
                                                )
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
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

#Preview {
    DictionaryView()
}
