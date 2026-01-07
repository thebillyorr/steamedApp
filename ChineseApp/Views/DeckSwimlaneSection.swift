//
//  DeckSwimlaneSection.swift
//  ChineseApp
//
//  Created by Billy Orr on 2026-01-06.
//

import SwiftUI

struct DeckSwimlaneSection: View {
    let title: String
    let decks: [Topic]
    let progressStore: ProgressStore
    let deckMasteryManager: DeckMasteryManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                
                // Optional "See All" button could go here later
            }
            .padding(.horizontal, 16)
            
            // Horizontal Swimlane
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(decks) { topic in
                        NavigationLink(value: topic) {
                            let topicMastery = calculateTopicMastery(for: topic)
                            let isDeckMastered = deckMasteryManager.isDeckMastered(filename: topic.filename) || isAllWordsMastered(for: topic)
                            
                            CompactDeckCard(
                                topic: topic,
                                masteryProgress: topicMastery,
                                isDeckMastered: isDeckMastered
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Add leading padding to first item only
                        .padding(.leading, topic.id == decks.first?.id ? 16 : 0)
                        // Add trailing padding to last item only
                        .padding(.trailing, topic.id == decks.last?.id ? 16 : 0)
                    }
                }
            }
        }
    }
    
    // Helper calculations duplicated from DictionaryView logic to keep this view self-contained
    private func calculateTopicMastery(for topic: Topic) -> Double {
        let words = DataService.loadWords(for: topic)
        guard !words.isEmpty else { return 0.0 }
        
        // Sum of all progress
        let totalMastery = words.reduce(0.0) { sum, word in
            sum + progressStore.getProgress(for: word.hanzi)
        }
        
        return totalMastery / Double(words.count)
    }
    
    // Check if every single word is 1.0 mastery
    private func isAllWordsMastered(for topic: Topic) -> Bool {
        let words = DataService.loadWords(for: topic)
        guard !words.isEmpty else { return false }
        return words.allSatisfy { progressStore.getProgress(for: $0.hanzi) >= 1.0 }
    }
}
