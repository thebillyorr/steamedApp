//
//  ProgressManager.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import Foundation

final class ProgressManager {
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
    static func addProgress(for hanzi: String, delta: Double) {
        var current = loadProgress()
        // allow positive or negative deltas; clamp result to [0.0, 1.0]
        let raw = (current[hanzi] ?? 0) + delta
        let newValue = max(0.0, min(raw, 1.0))
        current[hanzi] = newValue
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
}
