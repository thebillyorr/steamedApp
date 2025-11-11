//
//  Word.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import Foundation

struct Word: Identifiable, Codable {
    // stable id derived from hanzi so identity is consistent across loads
    var id: String { hanzi }
    let hanzi: String
    let pinyin: String
    // allow multiple english definitions
    let english: [String]
    let level: Int
    // difficulty 1 (easy) .. 5 (hard)
    var difficulty: Int = 3

    // character IDs as stored in JSON (array of hanzi strings)
    var characterIDs: [String]? = nil

    // resolved Character objects (not encoded back to JSON by default)
    var characters: [Character]? = nil

    enum CodingKeys: String, CodingKey {
        case hanzi, pinyin, english, level, characters, difficulty
    }

    init(hanzi: String, pinyin: String, english: [String], level: Int, characterIDs: [String]? = nil, difficulty: Int = 3) {
        self.hanzi = hanzi
        self.pinyin = pinyin
        self.english = english
        self.level = level
        self.characterIDs = characterIDs
        self.difficulty = difficulty
        self.characters = nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hanzi = try container.decode(String.self, forKey: .hanzi)
        pinyin = try container.decode(String.self, forKey: .pinyin)

        // english now expected as an array of strings (no legacy support)
        english = (try? container.decode([String].self, forKey: .english)) ?? []

        level = try container.decode(Int.self, forKey: .level)
        difficulty = (try? container.decode(Int.self, forKey: .difficulty)) ?? 3

        // try decoding characters as array of Character objects (full-objects)
        if let charObjs = try? container.decode([Character].self, forKey: .characters) {
            self.characters = charObjs
            self.characterIDs = charObjs.map { $0.hanzi }
        } else if let charIDs = try? container.decode([String].self, forKey: .characters) {
            // characters is an array of hanzi strings
            self.characterIDs = charIDs
            self.characters = nil
        } else {
            self.characterIDs = nil
            self.characters = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hanzi, forKey: .hanzi)
        try container.encode(pinyin, forKey: .pinyin)
        try container.encode(english, forKey: .english)
        try container.encode(level, forKey: .level)

        // prefer to encode characterIDs (compact reference form) if present
        if let ids = characterIDs {
            try container.encode(ids, forKey: .characters)
        } else if let chars = characters {
            try container.encode(chars, forKey: .characters)
        }
        try container.encode(difficulty, forKey: .difficulty)
    }
}

// small helper
