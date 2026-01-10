//
//  ProgressStore.swift
//  ChineseApp
//
//  Created by assistant on 2025-11-07.
//

import Foundation
import Combine

@MainActor
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published private(set) var progress: [String: Double] = [:]

    private init() {
        // Capture container safely from MainActor before detaching
        guard let container = ProgressManager.shared.container else {
             print("⚠️ ProgressStore init: No container available yet.")
             return
        }

        Task {
            // Because init is synchronous, we launch a Task
            // Since ProgressStore is @MainActor, this Task inherits MainActor context by default
            
            // However, ProgressManager.loadProgress is synchronous and non-actor-isolated.
            // But to avoid blocking the main thread, we prefer doing the fetch off-main.
            
            // We use Task.detached for background work
            await Task.detached(priority: .userInitiated) {
                // Fetch on background thread
                let data = ProgressManager.loadProgress(from: container)
                
                // Update on Main thread
                await MainActor.run {
                    self.progress = data
                }
            }.value
        }
    }

    func addProgress(for hanzi: String, delta: Double, in deckFilename: String? = nil) {
        ProgressManager.addProgress(for: hanzi, delta: delta, in: deckFilename)
        // reload published value
        if let container = ProgressManager.shared.container {
            progress = ProgressManager.loadProgress(from: container)
        }
    }

    func getProgress(for hanzi: String) -> Double {
        progress[hanzi] ?? 0
    }

    #if DEBUG
    func resetAll() {
        ProgressManager.resetAll()
        progress = [:]
    }
    
    // MARK: - Testing Helpers
    
    func setWordMastered(_ hanzi: String) {
        guard let container = ProgressManager.shared.container else { return }
        var current = ProgressManager.loadProgress(from: container)
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
        guard let container = ProgressManager.shared.container else { return }
        var current = ProgressManager.loadProgress(from: container)
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
    #endif
}
