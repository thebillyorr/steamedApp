//
//  MultipleChoiceQuestionView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-11.
//

import SwiftUI

enum QuizFeedbackState {
    case neutral
    case correct
    case incorrect
}

struct MultipleChoiceQuestionView: View {
    let word: Word
    let options: [String]
    let correctChoice: String
    let onAnswered: (Bool) -> Void
    
    // Don't store state here - accept it as parameters instead
    let selectedAnswer: String?
    let isAnswered: Bool
    let feedbackState: QuizFeedbackState
    let onOptionSelected: (String, Bool) -> Void  // (option, isCorrect)

    var body: some View {
        VStack(spacing: 20) {
            // Word to translate
            QuestionTitleBox(title: "Translate:", content: word.hanzi)

            // Answer options
            VStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    AnswerOptionButton(
                        text: option,
                        isSelected: selectedAnswer == option,
                        isCorrect: selectedAnswer == option ? (feedbackState == .correct) : nil,
                        isAnswered: isAnswered,
                        action: {
                            if !isAnswered {
                                let correct = (option == correctChoice)
                                onOptionSelected(option, correct)
                            }
                        }
                    )
                }
            }

            // Feedback section (shown after answer)
            if isAnswered {
                VStack(spacing: 12) {
                    QuestionFeedbackBox(
                        state: feedbackState,
                        correctAnswer: feedbackState == .incorrect ? correctChoice : nil
                    )

                    // Next button
                    NextQuestionButton(feedbackState: feedbackState) {
                        let correct = (selectedAnswer == correctChoice)
                        onAnswered(correct)
                    }
                }
                .padding(.top, 8)
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    MultipleChoiceQuestionView(
        word: Word(
            hanzi: "你",
            pinyin: "nǐ",
            english: ["you"],
            level: 1,
            difficulty: 1
        ),
        options: ["you", "me", "he", "she"],
        correctChoice: "you",
        onAnswered: { _ in },
        selectedAnswer: nil,
        isAnswered: false,
        feedbackState: .neutral,
        onOptionSelected: { _, _ in }
    )
}
