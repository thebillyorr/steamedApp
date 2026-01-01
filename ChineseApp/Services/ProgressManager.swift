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
    
    // Reset streak (for testing or if user wants to)
    static func resetStreak() {
        UserDefaults.standard.removeObject(forKey: streakCountKey)
        UserDefaults.standard.removeObject(forKey: lastPracticeDateKey)
    }
    
    // reset (optional for testing)
    static func resetAll() {
        UserDefaults.standard.removeObject(forKey: progressKey)
        UserDefaults.standard.removeObject(forKey: sessionCountKey)
        resetStreak()
    }
    
    // MARK: - Testing Helpers
    
    // (Removed resetDeck, resetWord, setWordMastered, setDeckMastered as requested)
}
