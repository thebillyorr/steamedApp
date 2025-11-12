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
    
    @State private var selectedCharacters: [String] = []
    @State private var feedbackState: QuizFeedbackState = .neutral
    @State private var isAnswered = false
    
    var constructedWord: String {
        selectedCharacters.joined()
    }
    
    var isCorrect: Bool {
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
                    
                    if selectedCharacters.isEmpty {
                        Text("Tap characters below to construct")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    } else {
                        HStack(spacing: 8) {
                            Spacer()
                            ForEach(Array(selectedCharacters.enumerated()), id: \.offset) { index, char in
                                Button(action: {
                                    if !isAnswered {
                                        selectedCharacters.remove(at: index)
                                    }
                                }) {
                                    Text(char)
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
                                let isSelected = selectedCharacters.contains(availableCharacters[index])
                                Button(action: {
                                    if !isAnswered {
                                        toggleCharacter(availableCharacters[index])
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
            
            Spacer()
            
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
                .padding(.top, 8)
                .transition(.scale.combined(with: .opacity))
            } else {
                // Submit button - only show before answering
                Button(action: submit) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedCharacters.isEmpty ? Color.gray : Color.blue
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .fontWeight(.semibold)
                }
                .disabled(selectedCharacters.isEmpty)
            }
        }
        .padding(.horizontal)
    }
    
    private func toggleCharacter(_ char: String) {
        if selectedCharacters.contains(char) {
            selectedCharacters.removeAll { $0 == char }
        } else {
            selectedCharacters.append(char)
        }
    }
    
    private func submit() {
        isAnswered = true
        feedbackState = isCorrect ? .correct : .incorrect
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
        onSubmit: { _ in }
    )
}
