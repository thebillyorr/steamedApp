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
            VStack(spacing: 16) {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(availableDecks) { topic in
                            DeckSelectionCard(topic: topic) {
                                onSelect(topic)
                                dismiss()
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Select Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(topic.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Label("\(getWordCount()) words", systemImage: "character")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(Int(calculateMastery()))%", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Mastery indicator (mini ring)
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray6), lineWidth: 3)
                    
                    Circle()
                        .trim(from: 0, to: calculateMastery() / 100)
                        .stroke(
                            calculateMastery() >= 100 ? Color.green : Color.blue,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(calculateMastery()))%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(width: 50, height: 50)
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
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
