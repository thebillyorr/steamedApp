//
//  Word.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import Foundation

struct Word: Identifiable, Codable {
    // stable id derived from hanzi so identity is consistent across loads
    // unless a custom ID is provided (e.g. for special tokens)
    var customId: String?
    var id: String { customId ?? hanzi }
    
    var hanzi: String
    let pinyin: String
    // allow multiple english definitions
    let english: [String]
    // difficulty 1 (easy) .. 6 (hard)
    var difficulty: Int = 3

    init(hanzi: String, pinyin: String, english: [String], difficulty: Int = 3, customId: String? = nil) {
        self.hanzi = hanzi
        self.pinyin = pinyin
        self.english = english
        self.difficulty = difficulty
        self.customId = customId
    }
}

// small helper
