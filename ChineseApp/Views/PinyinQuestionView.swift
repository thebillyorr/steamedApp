//
//  PinyinQuestionView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-11.
//

import SwiftUI

struct PinyinQuestionView: View {
    let word: Word
    let options: [String]
    let correctChoice: String
    let onAnswered: (Bool) -> Void
    let selectedAnswer: String?
    let isAnswered: Bool
    let feedbackState: QuizFeedbackState
    let onOptionSelected: (String, Bool) -> Void
    var onReport: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            // Question prompt
            VStack(spacing: 8) {
                Text("Select the correct pinyin for:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(word.hanzi)
                    .font(.system(size: 56, weight: .bold))
            }
            .padding(.vertical, 16)
            
            // Options
            VStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    AnswerOptionButton(
                        text: option,
                        isSelected: selectedAnswer == option,
                        isCorrect: selectedAnswer == option ? (feedbackState == .correct) : nil,
                        isAnswered: isAnswered,
                        action: {
                            if !isAnswered {
                                let correct = option == correctChoice
                                onOptionSelected(option, correct)
                            }
                        }
                    )
                }
            }
            
            // Feedback section
            if isAnswered {
                VStack(spacing: 12) {
                    QuestionFeedbackBox(
                        state: feedbackState,
                        correctAnswer: feedbackState == .incorrect ? correctChoice : nil,
                        onReport: onReport
                    )

                    NextQuestionButton(feedbackState: feedbackState) {
                        onAnswered(feedbackState == .correct)
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    PinyinQuestionView(
        word: Word(
            hanzi: "你",
            pinyin: "nǐ",
            english: ["you"],
            difficulty: 1
        ),
        options: ["nī", "ní", "nǐ", "nì"],
        correctChoice: "nǐ",
        onAnswered: { _ in },
        selectedAnswer: nil,
        isAnswered: false,
        feedbackState: .neutral,
        onOptionSelected: { _, _ in }
    )
}
