//
//  DataService.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import Foundation

class DataService {
    // organize topics by category for horizontal scrolling
    static let topicsByCategory: [(category: String, topics: [Topic])] = [
        (
            category: "Beginner",
            topics: [
                Topic(name: "Beginner 1", filename: "beginner_1"),
                Topic(name: "Beginner 2", filename: "beginner_2"),
                Topic(name: "Beginner 3", filename: "beginner_3"),
                Topic(name: "Beginner 4", filename: "beginner_4"),
                Topic(name: "Beginner 5", filename: "beginner_5"),
                Topic(name: "Beginner 6", filename: "beginner_6"),
                Topic(name: "Beginner 7", filename: "beginner_7"),
                Topic(name: "Beginner 8", filename: "beginner_8")
            ]
        ),
        (
            category: "Intermediate",
            topics: [
                Topic(name: "Intermediate 1", filename: "intermediate_1"),
                Topic(name: "Intermediate 2", filename: "intermediate_2")
            ]
        )
    ]
    
    // flat list of all topics for practice mode
    static var allTopics: [Topic] {
        return topicsByCategory.flatMap { $0.topics }
    }
    
    static func loadWords(for topic: Topic) -> [Word] {
        // load character DB first (if available)
        let charMap = loadCharacters()
        
        guard let url = Bundle.main.url(forResource: topic.filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              var words = try? JSONDecoder().decode([Word].self, from: data) else {
            print("❌ Failed to load \(topic.filename).json")
            return []
        }
        
        // resolve characterIDs to Character objects when possible
        for i in words.indices {
            if let ids = words[i].characterIDs {
                words[i].characters = ids.compactMap { charMap[$0] }
            } else if words[i].characters == nil {
                // fallback: split hanzi into characters and resolve
                let chars = words[i].hanzi.map { String($0) }
                words[i].characters = chars.compactMap { charMap[$0] }
                if !words[i].characters!.isEmpty {
                    words[i].characterIDs = words[i].characters!.map { $0.hanzi }
                }
            }
        }
        
        return words
    }
    
    static func loadCharacters() -> [String: Character] {
        guard let url = Bundle.main.url(forResource: "characters", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let list = try? JSONDecoder().decode([Character].self, from: data) else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: list.map { ($0.hanzi, $0) })
    }
    
    // MARK: - Mastery Journey System
    
    static private var cachedJourney: MasteryJourney?
    
    /// Load the mastery journey from JSON
    static func loadMasteryJourney() -> MasteryJourney {
        if let cached = cachedJourney {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "mastery_journey", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let journey = try? JSONDecoder().decode(MasteryJourney.self, from: data) else {
            print("❌ Failed to load mastery_journey.json - using fallback")
            return MasteryJourney.fallback()
        }
        
        cachedJourney = journey
        return journey
    }
    
    /// Get the number of words currently unlocked for a topic
    /// First 5 words always unlocked, then 1 new word per session completed
    /// Configurable via constant
    static func getUnlockedWordCount(for topicFilename: String, totalWords: Int) -> Int {
        let baseUnlockedWords = 5  // First 5 words always available
        let wordsReleasedPerSession = 1  // Can be changed to 2, 3, etc.
        
        let sessionCount = ProgressManager.getSessionCount(for: topicFilename)
        let unlockedCount = baseUnlockedWords + (sessionCount * wordsReleasedPerSession)
        
        // Cap at total words in topic
        return min(unlockedCount, totalWords)
    }
    
    /// Get the indices of currently unlocked words
    static func getUnlockedWordIndices(for topicFilename: String, totalWords: Int) -> [Int] {
        let unlockedCount = getUnlockedWordCount(for: topicFilename, totalWords: totalWords)
        return Array(0..<unlockedCount)
    }
    
    /// Determine the question type for a word at its current mastery level
    /// Each appearance of a word can have a different question type
    static func getQuestionType(for hanzi: String, journey: MasteryJourney) -> QuestionType {
        let mastery = ProgressStore.shared.getProgress(for: hanzi)
        
        guard let stage = journey.getStage(for: mastery) else {
            // Fallback to flashcard if no stage found
            return .flashcard
        }
        
        // Randomly select a question type based on weights
        let totalWeight = stage.questionTypes.reduce(0) { $0 + $1.weight }
        var random = Double.random(in: 0..<totalWeight)
        
        for option in stage.questionTypes {
            random -= option.weight
            if random <= 0 {
                return option.type.implementedType  // Use implemented type
            }
        }
        
        // Fallback
        return stage.questionTypes.first?.type.implementedType ?? .flashcard
    }
}
