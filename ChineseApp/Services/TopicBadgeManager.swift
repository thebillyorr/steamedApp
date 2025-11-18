//
//  TopicBadgeManager.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-15.
//

import Foundation
import Combine

final class TopicBadgeManager: ObservableObject {
    static let shared = TopicBadgeManager()
    
    @Published private(set) var earnedBadges: [String: TopicBadge] = [:]
    
    private let badgesKey = "topicBadges"
    
    private init() {
        earnedBadges = TopicBadgeManager.loadBadges()
    }
    
    // MARK: - Query Methods
    
    /// Check if user has earned badge for a topic
    func hasBadge(for category: String) -> Bool {
        earnedBadges[category]?.isEarned ?? false
    }
    
    /// Get badge for category, if earned
    func getBadge(for category: String) -> TopicBadge? {
        earnedBadges[category]
    }
    
    /// Get all earned badges
    func getAllEarnedBadges() -> [TopicBadge] {
        earnedBadges.values.filter { $0.isEarned }.sorted { $0.awardedAt > $1.awardedAt }
    }
    
    // MARK: - Award Methods
    
    /// Award badge when topic is completed
    func awardBadge(for category: String) {
        var badges = earnedBadges
        badges[category] = TopicBadge(
            category: category,
            isEarned: true,
            awardedAt: Date()
        )
        earnedBadges = badges
        saveBadges(badges)
    }
    
    /// Check if a new topic was just completed (auto-called from DeckMasteryManager)
    func checkAndAwardTopicBadge(category: String) {
        guard !hasBadge(for: category) else { return }  // Already has badge
        guard DeckMasteryManager.shared.isTopicMastered(category: category) else { return }
        
        awardBadge(for: category)
    }
    
    // MARK: - Persistence
    
    private func saveBadges(_ badges: [String: TopicBadge]) {
        if let encoded = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(encoded, forKey: badgesKey)
        }
    }
    
    private static func loadBadges() -> [String: TopicBadge] {
        if let data = UserDefaults.standard.data(forKey: "topicBadges"),
           let decoded = try? JSONDecoder().decode([String: TopicBadge].self, from: data) {
            return decoded
        }
        return [:]
    }
    
    func resetAll() {
        earnedBadges = [:]
        UserDefaults.standard.removeObject(forKey: badgesKey)
    }
}

// MARK: - Data Structure

struct TopicBadge: Codable {
    let category: String
    let isEarned: Bool
    let awardedAt: Date
    
    /// Get roman numeral for badge display
    var romanNumeral: String {
        switch category.lowercased() {
        case "beginner":
            return "I"
        case "intermediate":
            return "II"
        case "advanced":
            return "III"
        default:
            return "?"
        }
    }
    
    /// Get background color for badge
    var badgeColor: String {
        switch category.lowercased() {
        case "beginner":
            return "#E8B34B"  // Bronze/gold
        case "intermediate":
            return "#C0C0C0"  // Silver
        case "advanced":
            return "#FFD700"  // Gold
        default:
            return "#808080"  // Gray
        }
    }
}
