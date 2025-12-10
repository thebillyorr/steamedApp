import Foundation

struct StoryLibrary: Codable {
    let stories: [StoryMetadata]
}

struct StoryMetadata: Codable, Identifiable {
    let storyId: String
    let title: String
    let subtitle: String?
    let difficulty: Int
    let topic: String
    let locked: Bool
    
    var id: String { storyId }
}

struct Story: Codable {
    let storyId: String
    let title: String
    let subtitle: String?
    let difficulty: Int
    let topic: String
    let tokens: [StoryToken]
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
