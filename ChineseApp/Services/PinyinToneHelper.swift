//
//  PinyinToneHelper.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-11.
//

import Foundation

struct PinyinToneHelper {
    // Direct mapping of toned vowels to their base and tone
    private static let tonedToBaseAndTone: [String: (base: String, tone: Int)] = [
        // 1st tone (macron)
        "ā": ("a", 1), "ē": ("e", 1), "ī": ("i", 1), "ō": ("o", 1), "ū": ("u", 1), "ǖ": ("v", 1),
        // 2nd tone (acute)
        "á": ("a", 2), "é": ("e", 2), "í": ("i", 2), "ó": ("o", 2), "ú": ("u", 2), "ǘ": ("v", 2),
        // 3rd tone (caron)
        "ǎ": ("a", 3), "ě": ("e", 3), "ǐ": ("i", 3), "ǒ": ("o", 3), "ǔ": ("u", 3), "ǚ": ("v", 3),
        // 4th tone (grave)
        "à": ("a", 4), "è": ("e", 4), "ì": ("i", 4), "ò": ("o", 4), "ù": ("u", 4), "ǜ": ("v", 4),
    ]
    
    // Reverse mapping: base vowel + tone to toned vowel
    private static let baseAndToneToToned: [String: String] = [
        "a1": "ā", "e1": "ē", "i1": "ī", "o1": "ō", "u1": "ū", "v1": "ǖ",
        "a2": "á", "e2": "é", "i2": "í", "o2": "ó", "u2": "ú", "v2": "ǘ",
        "a3": "ǎ", "e3": "ě", "i3": "ǐ", "o3": "ǒ", "u3": "ǔ", "v3": "ǚ",
        "a4": "à", "e4": "è", "i4": "ì", "o4": "ò", "u4": "ù", "v4": "ǜ",
    ]
    
    /// Extract the tone number (1-4) from a pinyin string, or nil if no tone marker found
    static func extractTone(from pinyin: String) -> Int? {
        for char in pinyin {
            let charStr = String(char)
            if let (_, tone) = tonedToBaseAndTone[charStr] {
                return tone
            }
        }
        return nil
    }
    
    /// Remove tone markers from pinyin to get base form (e.g., "nǐ" → "ni")
    static func removeTonesMarkers(from pinyin: String) -> String {
        var result = ""
        for char in pinyin {
            let charStr = String(char)
            if let (base, _) = tonedToBaseAndTone[charStr] {
                result.append(base)
            } else {
                result.append(char)
            }
        }
        return result
    }
    
    /// Apply a specific tone to a single syllable (e.g., applyTone("ni", 1) → "nī")
    /// Only applies tone to the FIRST vowel in this syllable
    static func applyTone(_ baseSyllable: String, tone: Int) -> String {
        guard tone >= 1 && tone <= 4 else { return baseSyllable }
        
        var result = ""
        var tonedAlready = false
        
        for char in baseSyllable {
            let charStr = String(char)
            let key = "\(charStr)\(tone)"
            
            // Only replace the first vowel we find
            if !tonedAlready && baseAndToneToToned[key] != nil {
                result.append(baseAndToneToToned[key]!)
                tonedAlready = true
            } else {
                result.append(char)
            }
        }
        return result
    }
    
    /// Apply a specific tone to a syllable within a multi-syllable pinyin string
    /// syllableIndex: which syllable to modify (0 = first, 1 = second, etc.)
    static func applyToneToSyllable(_ pinyin: String, syllableIndex: Int, tone: Int) -> String {
        let syllables = pinyin.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard syllableIndex >= 0 && syllableIndex < syllables.count else { return pinyin }
        
        var result = syllables
        result[syllableIndex] = applyTone(removeTonesMarkers(from: result[syllableIndex]), tone: tone)
        return result.joined(separator: " ")
    }
    
    /// Generate all 4 tone variants of a pinyin string
    /// Returns array of [tone1, tone2, tone3, tone4] for the same pinyin
    static func generateAllToneVariants(from pinyin: String) -> [String] {
        let basePinyin = removeTonesMarkers(from: pinyin)
        return (1...4).map { applyTone(basePinyin, tone: $0) }
    }
    
    /// Get a different tone variant of the correct pinyin (for wrong-tone distractor)
    /// ONLY changes the tone mark on ONE vowel that already has a tone
    /// For multi-syllable words, picks one syllable and changes one tone
    static func getDifferentToneVariant(from correctPinyin: String) -> String? {
        let syllables = correctPinyin.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        
        // Find all syllables that have tones (at least one toned vowel)
        var tonedSyllableIndices: [Int] = []
        for (index, syllable) in syllables.enumerated() {
            if extractTone(from: syllable) != nil {
                tonedSyllableIndices.append(index)
            }
        }
        
        guard !tonedSyllableIndices.isEmpty else { return nil }
        
        // Pick a random toned syllable
        let syllableIndex = tonedSyllableIndices.randomElement()!
        let targetSyllable = syllables[syllableIndex]
        
        guard let currentTone = extractTone(from: targetSyllable) else { return nil }
        
        // Find the toned vowel in this syllable and swap its tone
        var result = ""
        var tonedAlready = false
        
        for char in targetSyllable {
            let charStr = String(char)
            
            if !tonedAlready, let (base, tone) = tonedToBaseAndTone[charStr], tone == currentTone {
                // This is the toned vowel - change its tone
                let newTone = getPreferredDifferentTone(from: tone)
                if let newTonedChar = baseAndToneToToned["\(base)\(newTone)"] {
                    result.append(newTonedChar)
                    tonedAlready = true
                } else {
                    result.append(char)
                }
            } else {
                result.append(char)
            }
        }
        
        var finalResult = syllables
        finalResult[syllableIndex] = result
        return finalResult.joined(separator: " ")
    }
    
    /// Get a preferred different tone (used for wrong-tone distractors)
    private static func getPreferredDifferentTone(from currentTone: Int) -> Int {
        let preferredTones: [Int]
        switch currentTone {
        case 1: preferredTones = [3, 2, 4]  // If 1st tone, prefer 3rd
        case 2: preferredTones = [3, 1, 4]  // If 2nd tone, prefer 3rd
        case 3: preferredTones = [2, 1, 4]  // If 3rd tone, prefer 2nd
        case 4: preferredTones = [2, 3, 1]  // If 4th tone, prefer 2nd
        default: preferredTones = [1, 2, 3, 4]
        }
        
        for tone in preferredTones {
            if tone != currentTone {
                return tone
            }
        }
        return currentTone
    }
}
