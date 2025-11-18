//
//  DeckMasteryManager.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-15.
//

import Foundation
import Combine

final class DeckMasteryManager: ObservableObject {
    static let shared = DeckMasteryManager()
    
    @Published private(set) var masteredDecks: [String: DeckMasteryState] = [:]
    
    private let deckMasteryKey = "deckMastery"
    
    private init() {
        masteredDecks = DeckMasteryManager.loadMasteredDecks()
    }
    
    // MARK: - Query Methods
    
    /// Check if a deck has passed the final exam (is mastered)
    func isDeckMastered(filename: String) -> Bool {
        masteredDecks[filename]?.isMastered ?? false
    }
    
    /// Get the date when deck was mastered, if applicable
    func getMasteredDate(filename: String) -> Date? {
        masteredDecks[filename]?.masteredAt
    }
    
    // MARK: - Update Methods
    
    /// Mark a deck as mastered (passed final exam)
    func masterDeck(filename: String) {
        var decks = masteredDecks
        decks[filename] = DeckMasteryState(
            filename: filename,
            isMastered: true,
            masteredAt: Date()
        )
        masteredDecks = decks
        saveMasteredDecks(decks)
    }
    
    // MARK: - Topic Completion Checking
    
    /// Check if all decks in a topic category are mastered
    func isTopicMastered(category: String) -> Bool {
        guard let categoryTopics = DataService.topicsByCategory.first(where: { $0.category == category })?.topics else {
            return false
        }
        return categoryTopics.allSatisfy { isDeckMastered(filename: $0.filename) }
    }
    
    /// Get all topics that are fully mastered
    func getMasteredTopics() -> [String] {
        DataService.topicsByCategory
            .filter { isTopicMastered(category: $0.category) }
            .map { $0.category }
    }
    
    // MARK: - Persistence
    
    private func saveMasteredDecks(_ decks: [String: DeckMasteryState]) {
        if let encoded = try? JSONEncoder().encode(decks) {
            UserDefaults.standard.set(encoded, forKey: deckMasteryKey)
        }
    }
    
    private static func loadMasteredDecks() -> [String: DeckMasteryState] {
        if let data = UserDefaults.standard.data(forKey: "deckMastery"),
           let decoded = try? JSONDecoder().decode([String: DeckMasteryState].self, from: data) {
            return decoded
        }
        return [:]
    }
    
    // MARK: - Reset (for testing)
    
    func resetAll() {
        masteredDecks = [:]
        UserDefaults.standard.removeObject(forKey: deckMasteryKey)
    }
    
    /// Reset a single deck's mastery state (for testing)
    func resetDeck(filename: String) {
        var decks = masteredDecks
        decks.removeValue(forKey: filename)
        masteredDecks = decks
        saveMasteredDecks(decks)
        print("✅ Reset deck: \(filename)")
    }
}

// MARK: - Data Structure

struct DeckMasteryState: Codable {
    let filename: String
    let isMastered: Bool
    let masteredAt: Date?
}
