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
    // difficulty 1 (easy) .. 5 (hard)
    var difficulty: Int = 3

    init(hanzi: String, pinyin: String, english: [String], difficulty: Int = 3) {
        self.hanzi = hanzi
        self.pinyin = pinyin
        self.english = english
        self.difficulty = difficulty
    }
}

// small helper
