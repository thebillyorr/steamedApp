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
    
    /// Fallback journey in case JSON loading fails
    static func fallback() -> MasteryJourney {
        return MasteryJourney(stages: [
            MasteryStage(stageNumber: 0, masteryMin: 0.0, masteryMax: 0.1, questionTypes: [QuestionTypeOption(type: .flashcard, weight: 1.0)]),
            MasteryStage(stageNumber: 1, masteryMin: 0.1, masteryMax: 0.2, questionTypes: [QuestionTypeOption(type: .flashcard, weight: 1.0)]),
            MasteryStage(stageNumber: 2, masteryMin: 0.2, masteryMax: 0.3, questionTypes: [QuestionTypeOption(type: .flashcard, weight: 0.5), QuestionTypeOption(type: .multipleChoice, weight: 0.5)]),
            MasteryStage(stageNumber: 3, masteryMin: 0.3, masteryMax: 0.4, questionTypes: [QuestionTypeOption(type: .flashcard, weight: 0.25), QuestionTypeOption(type: .multipleChoice, weight: 0.75)]),
            MasteryStage(stageNumber: 4, masteryMin: 0.4, masteryMax: 0.5, questionTypes: [QuestionTypeOption(type: .multipleChoice, weight: 1.0)]),
            MasteryStage(stageNumber: 5, masteryMin: 0.5, masteryMax: 0.6, questionTypes: [QuestionTypeOption(type: .multipleChoice, weight: 0.8), QuestionTypeOption(type: .multipleChoice, weight: 0.2)]),
            MasteryStage(stageNumber: 6, masteryMin: 0.6, masteryMax: 0.7, questionTypes: [QuestionTypeOption(type: .multipleChoice, weight: 0.5), QuestionTypeOption(type: .multipleChoice, weight: 0.5)]),
            MasteryStage(stageNumber: 7, masteryMin: 0.7, masteryMax: 0.8, questionTypes: [QuestionTypeOption(type: .multipleChoice, weight: 0.25), QuestionTypeOption(type: .multipleChoice, weight: 0.5), QuestionTypeOption(type: .multipleChoice, weight: 0.25)]),
            MasteryStage(stageNumber: 8, masteryMin: 0.8, masteryMax: 0.9, questionTypes: [QuestionTypeOption(type: .multipleChoice, weight: 0.5), QuestionTypeOption(type: .multipleChoice, weight: 0.25), QuestionTypeOption(type: .multipleChoice, weight: 0.25)]),
            MasteryStage(stageNumber: 9, masteryMin: 0.9, masteryMax: 1.0, questionTypes: [QuestionTypeOption(type: .multipleChoice, weight: 0.33), QuestionTypeOption(type: .multipleChoice, weight: 0.33), QuestionTypeOption(type: .multipleChoice, weight: 0.34)])
        ])
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
    case fillInBlank      // Not implemented yet - will use quiz
    case trueOrFalse      // Not implemented yet - will use quiz
    case speaking         // Not implemented yet - will use quiz
    
    /// For unimplemented types, fall back to the closest implemented type
    var implementedType: QuestionType {
        switch self {
        case .flashcard, .multipleChoice:
            return self
        case .fillInBlank, .trueOrFalse, .speaking:
            // Fallback to quiz (multipleChoice) for now
            return .multipleChoice
        }
    }
}
