//
//  FlashcardQuestionView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-11.
//

import SwiftUI

struct FlashcardQuestionView: View {
    let word: Word
    let isNewWord: Bool
    @State private var showAnswer = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Card background
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 6)

            // Content - centered
            VStack(spacing: 8) {
                Spacer()
                
                Text(word.hanzi)
                    .font(.system(size: 40, weight: .semibold, design: .default))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                if showAnswer {
                    VStack(spacing: 6) {
                        Text(word.pinyin)
                            .foregroundColor(.secondary)
                            .font(.headline)
                        Text(word.english.joined(separator: ", "))
                            .font(.title3)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    showAnswer.toggle()
                }
            }
            
            // New Word badge - fixed in top right, doesn't animate with tap
            if isNewWord {
                HStack(spacing: 4) {
                    Text("✨")
                        .font(.system(size: 14))
                    Text("New Word")
                        .font(.system(.body, design: .default))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(12)
            }
        }
        .frame(width: 320, height: 520)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FlashcardQuestionView(
        word: Word(
            hanzi: "你",
            pinyin: "nǐ",
            english: ["you"],
            level: 1,
            difficulty: 1
        ),
        isNewWord: true
    )
}
