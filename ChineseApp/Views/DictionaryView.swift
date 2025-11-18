//
//  DictionaryView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import SwiftUI

struct DictionaryView: View {
    let categories = DataService.topicsByCategory
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var deckMasteryManager = DeckMasteryManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(categories, id: \.category) { category, topics in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(topics) { topic in
                                        NavigationLink(value: topic) {
                                            let topicMastery = calculateTopicMastery(for: topic)
                                            let isDeckMastered = deckMasteryManager.isDeckMastered(filename: topic.filename)
                                            DeckMasteryTile(
                                                topic: topic,
                                                masteryProgress: topicMastery,
                                                isDeckMastered: isDeckMastered
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
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
}

#Preview {
    DictionaryView()
}
