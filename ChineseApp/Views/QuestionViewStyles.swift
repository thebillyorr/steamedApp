// MARK: - Unified Next Button
struct NextQuestionButton: View {
    let feedbackState: QuizFeedbackState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("Next Question")
                Image(systemName: "arrow.right")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                feedbackState == .correct ? Color.green : Color.orange
            )
            .foregroundColor(.white)
            .cornerRadius(10)
            .fontWeight(.semibold)
        }
    }
}
//
//  QuestionViewStyles.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-11.
//

import SwiftUI

// MARK: - Unified Answer Option Button
struct AnswerOptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?  // nil = not answered yet, true/false = feedback shown
    let isAnswered: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        // Before answering
        if !isAnswered {
            return isSelected ? Color.blue : Color(.secondarySystemBackground)
        }
        
        // After answering - show feedback
        if isSelected && isCorrect == true {
            return Color.green.opacity(0.2)
        } else if isSelected && isCorrect == false {
            return Color.red.opacity(0.2)
        } else {
            return Color(.secondarySystemBackground)
        }
    }
    
    var borderColor: Color {
        // Before answering
        if !isAnswered {
            return isSelected ? Color.blue : Color(.separator)
        }
        
        // After answering
        if isSelected && isCorrect == true {
            return Color.green
        } else if isSelected && isCorrect == false {
            return Color.red
        } else {
            return Color(.separator)
        }
    }
    
    var borderWidth: CGFloat {
        if !isAnswered {
            return isSelected ? 2 : 1
        }
        return isSelected ? 2 : 1
    }
    
    var textColor: Color {
        if !isAnswered {
            return isSelected ? .white : .primary
        }
        // After answering, use primary color
        return .primary
    }
    
    var showCheckmark: Bool {
        isAnswered && isSelected && isCorrect == true
    }
    
    var showXmark: Bool {
        isAnswered && isSelected && isCorrect == false
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                if showCheckmark {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                } else if showXmark {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
            .foregroundColor(textColor)
        }
        .buttonStyle(.plain)
        .disabled(isAnswered)
        .opacity(isAnswered && !isSelected ? 0.5 : 1.0)
    }
}

// MARK: - Unified Feedback Box
struct QuestionFeedbackBox: View {
    let state: QuizFeedbackState
    let correctAnswer: String?
    var word: Word? = nil
    var onReport: (() -> Void)? = nil
    
    var body: some View {
        Group {
            if state == .incorrect, let answer = correctAnswer {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Correct Answer")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            Text(answer)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            if let word = word {
                                VStack(alignment: .leading, spacing: 2) {
                                    if answer != word.hanzi {
                                        Text(word.hanzi)
                                            .font(.headline)
                                    }
                                    if answer != word.pinyin {
                                        Text(word.pinyin)
                                            .font(.subheadline)
                                    }
                                    let englishText = word.english.joined(separator: ", ")
                                    if !word.english.contains(answer) && answer != englishText {
                                        Text(englishText)
                                            .font(.caption)
                                    }
                                }
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                            }
                        }
                        
                        Spacer()
                        
                        if let word = word {
                            BookmarkButton(wordID: word.id, size: 32)
                        }
                    }
                    
                    Divider()
                        .background(Color.red.opacity(0.2))
                    
                    Button(action: { onReport?() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "flag")
                            Text("Report Issue")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.leading, 36) // Align with text
                }
                .padding(16)
                .background(Color.red.opacity(0.05))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.1), lineWidth: 1)
                )
            } else {
                EmptyView()
            }
        }
    }
}

// MARK: - VisualEffectBlur for overlay blur
struct VisualEffectBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Report Issue Overlay
struct ReportIssueOverlay: View {
    var onClose: () -> Void
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 24) {
                // Icon
                Image(systemName: "flag")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.steamedGradient)
                
                VStack(spacing: 12) {
                    Text("Spot a mistake?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("We're constantly improving. Please send details and a screenshot to:")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("report@steamed.app")
                        .font(.headline)
                        .foregroundColor(.steamedDarkBlue)
                        .padding(.vertical, 4)
                    
                    Text("We'll do our very best to fix it!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: onClose) {
                    Text("Got it")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.steamedGradient)
                        .cornerRadius(16)
                }
            }
            .padding(32)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
            .frame(maxWidth: 400)
        }
        .transition(.opacity)
    }
}

// MARK: - Unified Question Title
struct QuestionTitleBox: View {
    let title: String
    let content: String
    let fontSize: CGFloat = 56
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(content)
                .font(.system(size: fontSize, weight: .bold))
        }
        .padding(.vertical, 24)
    }
}

// MARK: - Summary Stat Card
struct SummaryStatCard: View {
    let title: String
    let value: String
    let icon: String
    // Fixed to theme gradient
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Color.steamedGradient)
                .frame(width: 50, height: 50)
                .background(Color.steamedBlue.opacity(0.15))
                .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
