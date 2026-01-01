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
    var onReport: (() -> Void)? = nil
    
    var body: some View {
        Group {
            if state == .incorrect, let answer = correctAnswer {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Correct answer:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(answer)
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: { onReport?() }) {
                        Image(systemName: "flag")
                            .foregroundColor(.orange)
                            .padding(.leading, 8)
                            .accessibilityLabel("Report an issue")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
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
        GeometryReader { geo in
            ZStack {
                VisualEffectBlur(style: .systemThinMaterialDark)
                    .edgesIgnoringSafeArea(.all)
                Color.black.opacity(0.35)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Image(systemName: "flag")
                        .font(.system(size: 44))
                        .foregroundColor(.orange)
                    Text("Think something is wrong?")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("We realize there may be mistakes in our app. Send details and a screenshot to \n \n report@steamed.app \n \n  We'll do our very best to fix it!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    Button(action: onClose) {
                        Text("Got it")
                            .font(.headline)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 36)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(32)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 24)
                .frame(maxWidth: 360)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .transition(.opacity.combined(with: .scale))
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
