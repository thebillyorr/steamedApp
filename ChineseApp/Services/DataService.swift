//
//  DataService.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import Foundation

class DataService {
    // organize topics by category for horizontal scrolling
    // seen and mastered flags are stored in ProgressManager via UserDefaults, not on Word struct
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
                Topic(name: "Intermediate 2", filename: "intermediate_2"),
                Topic(name: "Intermediate 3", filename: "intermediate_3"),
                Topic(name: "Intermediate 4", filename: "intermediate_4"),
                Topic(name: "Intermediate 5", filename: "intermediate_5"),
                Topic(name: "Intermediate 6", filename: "intermediate_6"),
                Topic(name: "Intermediate 7", filename: "intermediate_7"),
                Topic(name: "Intermediate 8", filename: "intermediate_8")
            ]
        )
    ]
    
    // flat list of all topics for practice mode
    static var allTopics: [Topic] {
        return topicsByCategory.flatMap { $0.topics }
    }
    
    // MARK: - Dictionary Loading
    
    static private var cachedDictionary: [String: Word]?
    
    /// Load the master dictionary (hashmap of word ID -> Word object)
    static func loadDictionary() -> [String: Word] {
        if let cached = cachedDictionary {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "dictionary", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dict = try? JSONDecoder().decode([String: Word].self, from: data) else {
            print("❌ Failed to load dictionary.json")
            return [:]
        }
        
        cachedDictionary = dict
        return dict
    }
    
    /// Get the dictionary (public accessor for services like StoryService)
    static func getDictionary() -> [String: Word] {
        return loadDictionary()
    }
    
    // MARK: - Deck Loading
    
    /// Represents the deck structure with word IDs
    private struct DeckFile: Codable {
        let deckName: String
        let topic: String
        let wordIDs: [String]
    }
    
    static func loadWords(for topic: Topic) -> [Word] {
        // Load the deck file (contains word IDs)
        guard let url = Bundle.main.url(forResource: topic.filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let deckFile = try? JSONDecoder().decode(DeckFile.self, from: data) else {
            print("❌ Failed to load \(topic.filename).json")
            return []
        }
        
        // Load the dictionary
        let dictionary = loadDictionary()
        
        // Resolve word IDs to full Word objects
        var words: [Word] = []
        for wordID in deckFile.wordIDs {
            if let word = dictionary[wordID] {
                words.append(word)
            } else {
                print("⚠️ Word ID not found in dictionary: \(wordID)")
            }
        }
        
        return words
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
            print("❌ CRITICAL: Failed to load mastery_journey.json")
            fatalError("mastery_journey.json is missing from bundle")
        }
        
        cachedJourney = journey
        return journey
    }
    
    /// Get the number of words currently unlocked for a topic
    /// First 5 words always unlocked, then 1 new word per session completed
    /// Configurable via constant
    static func getUnlockedWordCount(for topicFilename: String, totalWords: Int) -> Int {
        let baseUnlockedWords = 8  // First 5 words always available
        let wordsReleasedPerSession = 2  // Can be changed to 2, 3, etc.
        
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
