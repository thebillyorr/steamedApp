//
//  ConstructionQuestionView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-11.
//

import SwiftUI

struct ConstructionQuestionView: View {
    let word: Word
    let availableCharacters: [String]
    let onSubmit: (Bool) -> Void
    
    // State from parent
    let selectedCharactersIndices: [Int]  // Changed to indices
    let isAnswered: Bool
    let feedbackState: QuizFeedbackState
    let onCharacterToggled: (Int) -> Void  // Changed to accept index
    let onSubmitted: () -> Void
    
    private var constructedWord: String {
        selectedCharactersIndices.map { availableCharacters[$0] }.joined()
    }
    
    private var isCorrect: Bool {
        constructedWord == word.hanzi
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // English meaning at top
            VStack(spacing: 8) {
                Text("Construct the word for:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(word.english.joined(separator: ", "))
                    .font(.system(size: 32, weight: .bold))
            }
            .padding(.vertical, 16)
            
            // Construction area - shows selected characters
            VStack(spacing: 8) {
                Text("Your construction:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                    
                    if selectedCharactersIndices.isEmpty {
                        Text("Tap characters below to construct")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    } else {
                        HStack(spacing: 8) {
                            Spacer()
                            ForEach(Array(selectedCharactersIndices.enumerated()), id: \.offset) { position, charIndex in
                                Button(action: {
                                    if !isAnswered {
                                        onCharacterToggled(charIndex)
                                    }
                                }) {
                                    Text(availableCharacters[charIndex])
                                        .font(.system(size: 20, weight: .semibold))
                                        .frame(width: 36, height: 36)
                                        .background(Color(.secondarySystemBackground))
                                        .foregroundColor(.primary)
                                        .cornerRadius(8)
                                }
                                .disabled(isAnswered)
                            }
                            Spacer()
                        }
                        .padding(12)
                    }
                }
                .frame(height: 60)
            }
            
            // Character options - 6 buttons in 2 rows of 3
            VStack(spacing: 12) {
                ForEach(0..<2, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { col in
                            let index = row * 3 + col
                            if index < availableCharacters.count {
                                let isSelected = selectedCharactersIndices.contains(index)
                                Button(action: {
                                    if !isAnswered {
                                        onCharacterToggled(index)
                                    }
                                }) {
                                    Text(availableCharacters[index])
                                        .font(.system(size: 20, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(
                                            isSelected
                                                ? Color(.secondarySystemBackground)
                                                : Color(.secondarySystemBackground)
                                        )
                                        .foregroundColor(.primary)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    isSelected ? Color.blue : Color(.separator),
                                                    lineWidth: isSelected ? 2 : 1
                                                )
                                        )
                                }
                                .disabled(isAnswered)
                                .opacity(isAnswered && !isSelected ? 0.5 : 1.0)
                            }
                        }
                    }
                }
            }
            
            // Submit button - always visible but grayed out until construction is complete
            if !isAnswered {
                Button(action: onSubmitted) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedCharactersIndices.isEmpty ? Color.gray : Color.blue
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .fontWeight(.semibold)
                }
                .disabled(selectedCharactersIndices.isEmpty)
            }
            
            // Feedback section
            if isAnswered {
                VStack(spacing: 12) {
                    QuestionFeedbackBox(
                        state: feedbackState,
                        correctAnswer: feedbackState == .incorrect ? word.hanzi : nil
                    )

                    NextQuestionButton(feedbackState: feedbackState) {
                        onSubmit(isCorrect)
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    ConstructionQuestionView(
        word: Word(
            hanzi: "你",
            pinyin: "nǐ",
            english: ["you"],
            level: 1,
            difficulty: 1
        ),
        availableCharacters: ["你", "好", "我", "他", "是", "的"],
        onSubmit: { _ in },
        selectedCharactersIndices: [],
        isAnswered: false,
        feedbackState: .neutral,
        onCharacterToggled: { _ in },
        onSubmitted: { }
    )
}
