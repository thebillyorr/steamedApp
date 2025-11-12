//
//  MasteryJourney.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-10.
//

import Foundation

/// Defines the progression of question types based on mastery level
struct MasteryJourney: Codable {
    let stages: [MasteryStage]
    
    /// Get the stage for a given mastery level (0.0 to 1.0)
    func getStage(for mastery: Double) -> MasteryStage? {
        return stages.first { $0.masteryRange.contains(mastery) }
    }
}

/// Represents a single mastery stage (e.g., 0-10%, 10-20%, etc.)
struct MasteryStage: Codable {
    let stageNumber: Int  // 0-9
    let masteryMin: Double  // 0.0, 0.1, 0.2, etc.
    let masteryMax: Double  // 0.1, 0.2, 0.3, etc.
    let questionTypes: [QuestionTypeOption]
    
    var masteryRange: ClosedRange<Double> {
        // Each stage spans from masteryMin to masteryMax (inclusive)
        return masteryMin...masteryMax
    }
}

/// Represents a question type option within a mastery stage
struct QuestionTypeOption: Codable {
    let type: QuestionType
    let weight: Double  // probability weight (normalized by caller)
}

/// Available question types
enum QuestionType: String, Codable {
    case flashcard
    case multipleChoice
    case construction
    case pinyin
    case fillInBlank      // Not implemented yet - will use quiz
    case trueOrFalse      // Not implemented yet - will use quiz
    case speaking         // Not implemented yet - will use quiz
    
    /// For unimplemented types, fall back to the closest implemented type
    var implementedType: QuestionType {
        switch self {
        case .flashcard, .multipleChoice, .construction, .pinyin:
            return self
        case .fillInBlank, .trueOrFalse, .speaking:
            // Fallback to quiz (multipleChoice) for now
            return .multipleChoice
        }
    }
}
