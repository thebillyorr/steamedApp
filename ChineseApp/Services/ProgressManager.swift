//
//  ProgressManager.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import Foundation

import Foundation
import SwiftData

public final class ProgressManager {
    static let shared = ProgressManager()
    
    var container: ModelContainer?
    
    func setContainer(_ container: ModelContainer) {
        self.container = container
    }
    
    private static let progressKey = "wordProgress"
    private static let sessionCountKey = "sessionCounts"

    // MARK: - Word Progress
    
    // load all progress as [hanzi : 0.0-1.0]
    static func loadProgress() -> [String: Double] {
        guard let container = shared.container else {
            print("⚠️ SwiftData container not set.")
            return [:]
        }
        
        let context = ModelContext(container)
        var results: [String: Double] = [:]
        
        do {
            let limit = FetchDescriptor<WordProgress>()
            let words = try context.fetch(limit)
            
            for w in words {
                results[w.hanzi] = w.mastery
            }
        } catch {
            print("❌ Failed to load progress: \(error)")
        }
        
        return results
    }

    // save full map back - Efficient Upsert
    static func saveProgress(_ dict: [String: Double]) {
        guard let container = shared.container else { return }
        let context = ModelContext(container)
        
        do {
            // This is heavy, but used rarely (bulk updates)
            for (hanzi, mastery) in dict {
                let descriptor = FetchDescriptor<WordProgress>(predicate: #Predicate { $0.hanzi == hanzi })
                if let existing = try context.fetch(descriptor).first {
                    existing.mastery = mastery
                } else {
                    let newWord = WordProgress(hanzi: hanzi, mastery: mastery)
                    context.insert(newWord)
                }
            }
            try context.save()
        } catch {
            print("❌ Failed to save bulk progress: \(error)")
        }
    }

    // add delta, cap at 1.0
    // If the word is in a mastered deck, mastery stays locked at 1.0
    @MainActor
    static func addProgress(for hanzi: String, delta: Double, in deckFilename: String? = nil) {
        guard let container = shared.container else { return }
        // Using mainContext for easy @MainActor safety if called from UI, 
        // or create a background context if off-main. 
        // Given we are mostly on UI thread for this app:
        let context = container.mainContext 
        
        do {
            // 1. Fetch
            let descriptor = FetchDescriptor<WordProgress>(predicate: #Predicate { $0.hanzi == hanzi })
            let results = try context.fetch(descriptor)
            let wordEntry = results.first
            
            let currentMastery = wordEntry?.mastery ?? 0.0
            
            // 2. Calculate
            let raw = currentMastery + delta
            let newValue = max(0.0, min(raw, 1.0))
            
            let finalValue: Double
            if let deckName = deckFilename, DeckMasteryManager.shared.isDeckMastered(filename: deckName) {
                finalValue = 1.0  // Stay locked
            } else {
                finalValue = newValue
            }
            
            // 3. Save / Upsert
            if let existing = wordEntry {
                existing.mastery = finalValue
                existing.lastPracticed = Date()
            } else {
                let newEntry = WordProgress(hanzi: hanzi, mastery: finalValue)
                context.insert(newEntry)
            }
            
            // Auto-save is implicit in mainContext heavily, but explicit is safer
            try context.save()
            
        } catch {
            print("❌ Failed to add progress: \(error)")
        }
    }

    // convenience getter - Read directly from DB for fresh data
    static func getProgress(for hanzi: String) -> Double {
        guard let container = shared.container else { return 0.0 }
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<WordProgress>(predicate: #Predicate { $0.hanzi == hanzi })
        return (try? context.fetch(descriptor).first?.mastery) ?? 0.0
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
    
    // MARK: - Daily Streak Tracking
    
    private static let streakCountKey = "streakCount"
    private static let lastPracticeDateKey = "lastPracticeDate"
    
    // Get current streak count
    static func getStreakCount() -> Int {
        UserDefaults.standard.integer(forKey: streakCountKey)
    }
    
    // Record practice session and update streak
    static func recordDailyPractice() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = UserDefaults.standard.object(forKey: lastPracticeDateKey) as? Date ?? Date(timeIntervalSince1970: 0)
        let lastDateNormalized = Calendar.current.startOfDay(for: lastDate)
        
        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: lastDateNormalized, to: today).day ?? 0
        
        if daysDifference == 0 {
            // Same day - no streak change
            return
        } else if daysDifference == 1 {
            // Consecutive day - increment streak
            var streak = getStreakCount()
            streak += 1
            UserDefaults.standard.set(streak, forKey: streakCountKey)
        } else {
            // Missed day(s) - reset streak to 1
            UserDefaults.standard.set(1, forKey: streakCountKey)
        }
        
        // Update last practice date
        UserDefaults.standard.set(today, forKey: lastPracticeDateKey)
    }
    
    // Reset streak
    #if DEBUG
    static func resetStreak() {
        UserDefaults.standard.removeObject(forKey: streakCountKey)
        UserDefaults.standard.removeObject(forKey: lastPracticeDateKey)
    }
    
    // reset (optional for testing)
    @MainActor
    static func resetAll() {
        // Clear SwiftData
        if let container = shared.container {
            let context = container.mainContext // use main context or create new one
            do {
                try context.delete(model: WordProgress.self)
            } catch {
                print("❌ Failed to clear WordProgress: \(error)")
            }
        }
        
        UserDefaults.standard.removeObject(forKey: progressKey)
        UserDefaults.standard.removeObject(forKey: sessionCountKey)
        resetStreak()
    }
    #endif
    
    // MARK: - Testing Helpers
    
    // (Removed resetDeck, resetWord, setWordMastered, setDeckMastered as requested)
}
