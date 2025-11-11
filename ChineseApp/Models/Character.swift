//
//  Character.swift
//  ChineseApp
//
//  Created by assistant on 2025-11-07.
//

import Foundation

struct Character: Codable, Identifiable, Hashable {
    // use the hanzi itself as a stable id
    let id: String
    let hanzi: String
    let pinyin: String?
    let english: String?
    let level: Int?

    init(hanzi: String, pinyin: String? = nil, english: String? = nil, level: Int? = nil) {
        self.hanzi = hanzi
        self.id = hanzi
        self.pinyin = pinyin
        self.english = english
        self.level = level
    }
}
