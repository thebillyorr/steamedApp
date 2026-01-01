//
//  ProgressStore.swift
//  ChineseApp
//
//  Created by assistant on 2025-11-07.
//

import Foundation
import Combine

final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published private(set) var progress: [String: Double] = [:]

    private init() {
        progress = ProgressManager.loadProgress()
    }

    func addProgress(for hanzi: String, delta: Double, in deckFilename: String? = nil) {
        ProgressManager.addProgress(for: hanzi, delta: delta, in: deckFilename)
        // reload published value
        progress = ProgressManager.loadProgress()
    }

    func getProgress(for hanzi: String) -> Double {
        progress[hanzi] ?? 0
    }

    func resetAll() {
        ProgressManager.resetAll()
        progress = [:]
    }
    
    // MARK: - Testing Helpers
    
    func setWordMastered(_ hanzi: String) {
        var current = ProgressManager.loadProgress()
        current[hanzi] = 1.0
        ProgressManager.saveProgress(current)
        self.progress = current
    }
    
    func setDeckMastered(filename: String) {
        guard let topic = DataService.allTopics.first(where: { $0.filename == filename }) else {
            print("❌ Deck not found: \(filename)")
            return
        }
        
        // 1. Master all words in this deck
        let words = DataService.loadWords(for: topic)
        var current = ProgressManager.loadProgress()
        for word in words {
            current[word.hanzi] = 1.0
        }
        ProgressManager.saveProgress(current)
        
        // 2. Pass the exam (lock the deck)
        DeckMasteryManager.shared.masterDeck(filename: filename)
        
        // 3. Update local state
        self.progress = current
        print("✅ Deck mastered: \(filename)")
    }
}
