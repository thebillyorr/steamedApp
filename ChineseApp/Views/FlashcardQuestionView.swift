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
    let onGotIt: () -> Void
    let onNeedToReview: () -> Void
    
    @State private var showAnswer = false
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var showHint = false
    @State private var isBouncing = false
    @State private var hintTask: Task<Void, Never>?
    
    private func resetHintTimer() {
        hintTask?.cancel()
        showHint = false
        hintTask = Task {
            try? await Task.sleep(nanoseconds: 8 * 1_000_000_000) // 8 Seconds
            if !Task.isCancelled {
                withAnimation(.easeInOut) {
                    showHint = true
                }
            }
        }
    }
    
    private var cardRotation: Double {
        // Rotate based on drag offset
        // More rotation as you drag further
        (dragOffset / 320.0) * 25.0  // Max 25 degrees of rotation
    }
    
    private var swipePercentage: CGFloat {
        abs(dragOffset) / 320.0
    }
    
    private var isSwipingRight: Bool {
        dragOffset > 0
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            // Background indicators (FIXED behind, revealed as card moves)
            HStack(spacing: 0) {
                // Left side - "Got it" (shown only when swiping RIGHT)
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    Text("Got it")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .opacity(dragOffset > 10 ? 1.0 : 0)
                
                Spacer()
                
                // Right side - "Need Review" (shown only when swiping LEFT)
                VStack(spacing: 12) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    Text("Need Review")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .opacity(dragOffset < -10 ? 1.0 : 0)
            }
            .frame(width: 320, height: 520)
            .zIndex(0)
            
            // Hint Text (Underneath)
            if showHint && dragOffset == 0 {
                VStack(spacing: 8) {
                    (Text("Swipe Left if you ")
                        .foregroundColor(.primary.opacity(0.7))
                    + Text("Need Review")
                        .foregroundColor(.red))
                    
                    (Text("Swipe Right if you ")
                        .foregroundColor(.primary.opacity(0.7))
                    + Text("Got It")
                        .foregroundColor(.green))
                }
                .font(.system(size: 14, weight: .semibold))
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .offset(y: 340) // Lower down
                .opacity(isBouncing ? 1.0 : 0.8) // Subtle pulse opacity
                .offset(y: isBouncing ? -5 : 5) // Gentle bounce
                .transition(.opacity)
                .zIndex(20)
                .allowsHitTesting(false)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        isBouncing = true
                    }
                }
            }
            
            // Card (on top, slides to reveal indicators behind)
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
                    resetHintTimer() // Reset inactivity timer on tap
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        showAnswer.toggle()
                    }
                }
                
                // New Word badge
                if isNewWord {
                    HStack(spacing: 4) {
                        Text("✨")
                            .font(.system(size: 14))
                        Text("New Word")
                            .font(.system(.body, design: .default))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(12)
                }
            }
            .frame(width: 320, height: 520)
            .zIndex(10)
            .offset(x: dragOffset * 0.5)
            .rotationEffect(Angle(degrees: cardRotation))
            .opacity(max(0.4, 1.0 - swipePercentage * 0.6))
            .scaleEffect(max(0.9, 1.0 - swipePercentage * 0.1))
            // FIX: Use a continuous animation curve to prevent "Time 0.0" sample errors.
            // Instead of disabling animation during drag (which resets the clock), 
            // we use a very fast "interactive" spring that mimics direct tracking.
            .animation(
                isDragging ? .interactiveSpring(response: 0.1, dampingFraction: 0.8) : .spring(response: 0.4, dampingFraction: 0.7),
                value: dragOffset
            )
        }
        .frame(width: 320, height: 520)
        .frame(maxWidth: .infinity)
        .onAppear {
            resetHintTimer()
        }
        .onChange(of: word.hanzi) { _ in
            // Reset all state when word changes
            dragOffset = 0
            isDragging = false
            showAnswer = false
            resetHintTimer()
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    // User touched card - cancel hint immediately
                    if showHint { withAnimation { showHint = false } }
                    hintTask?.cancel() 
                    
                    isDragging = true
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    isDragging = false
                    
                    // Trigger action if swiped far enough (threshold: 100 points)
                    if dragOffset > 100 {
                        // Swiped right - "Got it"
                        dragOffset = 400
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            onGotIt()
                        }
                    } else if dragOffset < -100 {
                        // Swiped left - "Need to review"
                        dragOffset = -400
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            onNeedToReview()
                        }
                    } else {
                        // Didn't swipe far enough, snap back
                        dragOffset = 0
                        resetHintTimer() // Resume timer if released back to center
                    }
                }
        )
    }
}

#Preview {
    FlashcardQuestionView(
        word: Word(
            hanzi: "你",
            pinyin: "nǐ",
            english: ["you"],
            difficulty: 1
        ),
        isNewWord: true,
        onGotIt: {},
        onNeedToReview: {}
    )
}

