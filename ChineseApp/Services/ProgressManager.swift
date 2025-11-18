//
//  ProgressManager.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import Foundation

public final class ProgressManager {
    private static let progressKey = "wordProgress"
    private static let sessionCountKey = "sessionCounts"

    // MARK: - Word Progress
    
    // load all progress as [hanzi : 0.0-1.0]
    static func loadProgress() -> [String: Double] {
        UserDefaults.standard.dictionary(forKey: progressKey) as? [String: Double] ?? [:]
    }

    // save full map back
    static func saveProgress(_ dict: [String: Double]) {
        UserDefaults.standard.set(dict, forKey: progressKey)
    }

    // add delta, cap at 1.0
    // If the word is in a mastered deck, mastery stays locked at 1.0
    static func addProgress(for hanzi: String, delta: Double, in deckFilename: String? = nil) {
        var current = loadProgress()
        // allow positive or negative deltas; clamp result to [0.0, 1.0]
        let raw = (current[hanzi] ?? 0) + delta
        let newValue = max(0.0, min(raw, 1.0))
        
        // If this word belongs to a mastered deck, keep it locked at 1.0
        if let deckName = deckFilename, DeckMasteryManager.shared.isDeckMastered(filename: deckName) {
            current[hanzi] = 1.0  // Stay locked
        } else {
            current[hanzi] = newValue
        }
        
        saveProgress(current)
    }

    // convenience getter
    static func getProgress(for hanzi: String) -> Double {
        loadProgress()[hanzi] ?? 0
    }

    // MARK: - Session Count Tracking (per-topic)
    
    // load session counts as [topicFilename : count]
    static func loadSessionCounts() -> [String: Int] {
        UserDefaults.standard.dictionary(forKey: sessionCountKey) as? [String: Int] ?? [:]
    }
    
    // save session counts
    static func saveSessionCounts(_ dict: [String: Int]) {
        UserDefaults.standard.set(dict, forKey: sessionCountKey)
    }
    
    // get session count for a topic
    static func getSessionCount(for topicFilename: String) -> Int {
        loadSessionCounts()[topicFilename] ?? 0
    }
    
    // increment session count when a practice session completes
    static func recordSessionCompletion(for topicFilename: String) {
        var counts = loadSessionCounts()
        counts[topicFilename, default: 0] += 1
        saveSessionCounts(counts)
    }
    
    // reset (optional for testing)
    static func resetAll() {
        UserDefaults.standard.removeObject(forKey: progressKey)
        UserDefaults.standard.removeObject(forKey: sessionCountKey)
    }
    
    // MARK: - Testing Helpers
    
    /// Set a specific word to 100% mastery (for testing)
    public static func setWordMastered(_ hanzi: String) {
        var current = loadProgress()
        current[hanzi] = 1.0
        saveProgress(current)
    }
    
    /// Master a deck by filename: set all words to 100%, pass the exam, and auto-award badge if topic complete (for testing)
    public static func setDeckMastered(filename: String) {
        // Find the topic with this filename
        guard let topic = DataService.allTopics.first(where: { $0.filename == filename }) else {
            print("❌ Deck not found: \(filename)")
            return
        }
        
        // 1. Master all words in this deck
        let words = DataService.loadWords(for: topic)
        var current = loadProgress()
        for word in words {
            current[word.hanzi] = 1.0
        }
        saveProgress(current)
        
        // 2. Pass the exam (lock the deck)
        DeckMasteryManager.shared.masterDeck(filename: filename)
        
        // 3. Auto-check if topic is now complete, award badge if so
        if let category = DataService.topicsByCategory.first(where: { categoryTopics in
            categoryTopics.topics.contains { $0.filename == filename }
        })?.category {
            TopicBadgeManager.shared.checkAndAwardTopicBadge(category: category)
        }
        
        print("✅ Deck mastered: \(filename)")
    }
    
    /// Reset a single word's progress to 0.0 (for testing)
    public static func resetWord(_ hanzi: String) {
        var current = loadProgress()
        current.removeValue(forKey: hanzi)
        saveProgress(current)
        print("✅ Reset word: \(hanzi)")
    }
}
