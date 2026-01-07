import Foundation

struct StoryLibrary: Codable {
    let stories: [StoryMetadata]
}

struct StoryMetadata: Identifiable, Codable {
    // Explicit memberwise initializer for use in StoryService
    init(storyId: String, title: String, subtitle: String?, difficulty: Int, topic: [String], locked: Bool) {
        self.storyId = storyId
        self.title = title
        self.subtitle = subtitle
        self.difficulty = difficulty
        self.topic = topic
        self.locked = locked
    }
    enum CodingKeys: String, CodingKey {
        case storyId, title, subtitle, difficulty, topic, locked
    }
    let storyId: String
    let title: String
    let subtitle: String?
    let difficulty: Int
    let topic: [String]
    let locked: Bool

    var id: String { storyId }

    // Custom decoding to support String or [String] for topic
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        storyId = try container.decode(String.self, forKey: .storyId)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        difficulty = try container.decode(Int.self, forKey: .difficulty)
        locked = try container.decodeIfPresent(Bool.self, forKey: .locked) ?? false
        if let topics = try? container.decode([String].self, forKey: .topic) {
            topic = topics
        } else if let single = try? container.decode(String.self, forKey: .topic), !single.isEmpty {
            topic = [single]
        } else {
            topic = []
        }
    }

    // For encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(storyId, forKey: .storyId)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(locked, forKey: .locked)
        if topic.count == 1 {
            try container.encode(topic[0], forKey: .topic)
        } else {
            try container.encode(topic, forKey: .topic)
        }
    }
}

struct Story: Codable {
    enum CodingKeys: String, CodingKey {
        case storyId, title, subtitle, difficulty, topic, tokens
    }
    let storyId: String
    let title: String
    let subtitle: String?
    let difficulty: Int
    let topic: [String]
    let tokens: [StoryToken]

    // Custom decoding to support String or [String] for topic
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        storyId = try container.decode(String.self, forKey: .storyId)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        difficulty = try container.decode(Int.self, forKey: .difficulty)
        tokens = try container.decode([StoryToken].self, forKey: .tokens)
        if let topics = try? container.decode([String].self, forKey: .topic) {
            topic = topics
        } else if let single = try? container.decode(String.self, forKey: .topic), !single.isEmpty {
            topic = [single]
        } else {
            topic = []
        }
    }

    // For encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(storyId, forKey: .storyId)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(tokens, forKey: .tokens)
        if topic.count == 1 {
            try container.encode(topic[0], forKey: .topic)
        } else {
            try container.encode(topic, forKey: .topic)
        }
    }
}

struct StoryToken: Identifiable {
    let id: String?
    let text: String
    
    var uniqueId: String { UUID().uuidString }
}

extension StoryToken: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case text
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(text, forKey: .text)
    }
}
