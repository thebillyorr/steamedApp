//
//  DataService.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import Foundation

class DataService {
    // List of all available decks
    static let decks: [Topic] = [

        // Things to do
        Topic(name: "Aquarium", filename: "Aquarium", icon: "fish", category: "Entertainment"),
        Topic(name: "Zoo", filename: "Zoo", icon: "pawprint.fill", category: "Entertainment"),
        Topic(name: "Shopping Mall", filename: "Shopping Mall", icon: "building.2.crop.circle.fill", category: "Entertainment"),
        Topic(name: "Museum", filename: "Museum", icon: "paintpalette.fill", category: "Entertainment"),
        Topic(name: "Amusement Park", filename: "Theme Park", icon: "star.circle.fill", category: "Entertainment"),
        Topic(name: "Cafe & Drinks", filename: "Cafe", icon: "cup.and.saucer.fill", category: "Entertainment"),
        

        // Outdoors
        Topic(name: "Camping", filename: "Camping", icon: "tent", category: "Nature & Outdoors"),
        Topic(name: "Hiking", filename: "Hiking", icon: "figure.hiking", category: "Nature & Outdoors"),
        Topic(name: "Gardening", filename: "Gardening", icon: "leaf.fill", category: "Nature & Outdoors"),
        
        // Living in China
        Topic(name: "Digital Life", filename: "Digital Life", icon: "iphone", category: "Living in China"),
        Topic(name: "Online Chat", filename: "Online Chat", icon: "bubble.left.and.bubble.right", category: "Living in China"),
        Topic(name: "Chinese New Year", filename: "Chinese New Year", icon: "party.popper", category: "Living in China"),
        Topic(name: "Tea Culture", filename: "Tea", icon: "cup.and.saucer.fill", category: "Living in China"),
        Topic(name: "Corporate", filename: "Corporate", icon: "building.2.fill", category: "Living in China"),
        Topic(name: "Shopping", filename: "Shopping", icon: "bag.fill", category: "Living in China"),

        
        
        // Travel
        Topic(name: "Air Travel", filename: "Plane", icon: "airplane", category: "Travel"),
        Topic(name: "Train Travel", filename: "Train", icon: "tram.fill", category: "Travel"),
        Topic(name: "Hotel Stay", filename: "Hotel", icon: "bed.double.fill", category: "Travel"),
        Topic(name: "Car Travel", filename: "Car Travel", icon: "car.fill", category: "Travel"),
    
        
        
        
        // Speak like a Local
        Topic(name: "Chinese Lingo", filename: "Chinese Lingo", icon: "quote.bubble.fill", category: "Speak like a Local"),
        Topic(name: "Internet Lingo", filename: "Internet Lingo", icon: "network", category: "Speak like a Local"),
        Topic(name: "Office Lingo", filename: "Office Lingo", icon: "briefcase.fill", category: "Speak like a Local"),

        
    ]
    
    // flat list of all topics for practice mode
    static var allTopics: [Topic] {
        let favorites = Topic(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "My Bookmarks",
            filename: "bookmarks_deck",
            icon: "Logo",
            category: "User"
        )
        return [favorites] + decks
    }
    
    // MARK: - Dictionary Loading
    
    static private var cachedDictionary: [String: Word]?
    static private var cachedHanziIndex: [String: Word]?
    
    /// Load the master dictionary (hashmap of word ID -> Word object)
    static func loadDictionary() -> [String: Word] {
        if let cached = cachedDictionary {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "dictionary", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              var dict = try? JSONDecoder().decode([String: Word].self, from: data) else {
            print("❌ Failed to load dictionary.json")
            return [:]
        }
        
        // Inject the dictionary key as the customId so that word.id returns the stable ID (e.g. "w00001")
        // instead of the Hanzi. This is crucial for bookmarks to work correctly.
        for key in dict.keys {
            dict[key]?.customId = key
        }
        
        cachedDictionary = dict
        return dict
    }
    
    static func getWord(byHanzi hanzi: String) -> Word? {
        if let index = cachedHanziIndex {
            return index[hanzi]
        }
        
        let dict = loadDictionary()
        var index: [String: Word] = [:]
        for word in dict.values {
            index[word.hanzi] = word
        }
        cachedHanziIndex = index
        return index[hanzi]
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
        // Special case for Bookmarks deck
        if topic.filename == "bookmarks_deck" {
            let bookmarkedIDs = BookmarkManager.shared.bookmarkedWordIDs
            let dictionary = loadDictionary()
            return bookmarkedIDs.compactMap { dictionary[$0] }
        }

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
        // Special case: Bookmarks deck always has all words unlocked
        if topicFilename == "bookmarks_deck" {
            return totalWords
        }

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
