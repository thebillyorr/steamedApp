//
//  DeckMasteryTile.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-13.
//

import SwiftUI

struct DeckMasteryTile: View {
    let topic: Topic
    let masteryProgress: Double  // 0.0 to 1.0
    let isDeckMastered: Bool     // Has user passed the final exam?
    
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .shadow(
                    color: isDeckMastered ? Color.yellow.opacity(0.3) : (masteryProgress >= 1.0 ? Color.blue.opacity(0.2) : Color.clear),
                    radius: isDeckMastered ? 8 : (masteryProgress >= 1.0 ? 4 : 0)
                )
            
            VStack(spacing: 12) {
                Spacer()
                
                // Mastery Indicator
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    // Progress ring (only shown if not fully mastered by exam)
                    if !isDeckMastered {
                        Circle()
                            .trim(from: 0, to: masteryProgress)
                            .stroke(
                                masteryProgress >= 1.0 ? Color.blue : Color.accentColor,
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.5), value: masteryProgress)
                    }
                    
                    // Center icon based on state
                    if isDeckMastered {
                        // STATE 2: Exam passed - filled gold star
                        Image(systemName: "star.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.yellow)
                            .scaleEffect(1.15)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDeckMastered)
                    } else if masteryProgress >= 1.0 {
                        // STATE 1: 100% word mastery - pulsing unlock icon
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .scaleEffect(isPulsing ? 1.15 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
                            .onAppear {
                                isPulsing = true
                            }
                    } else {
                        // Progress percentage
                        Text(String(format: "%.0f%%", masteryProgress * 100))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Topic name
                Text(topic.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
        }
        .frame(width: 140, height: 140)
    }
    
    // MARK: - Computed Colors
    
    private var backgroundColor: Color {
        if isDeckMastered {
            return Color.yellow.opacity(0.15)
        } else if masteryProgress >= 1.0 {
            return Color.blue.opacity(0.08)
        }
        return Color(.secondarySystemBackground)
    }
    
    private var borderColor: Color {
        if isDeckMastered {
            return Color.yellow
        } else if masteryProgress >= 1.0 {
            return Color.blue.opacity(0.5)
        }
        return Color(.separator)
    }
    
    private var borderWidth: CGFloat {
        if isDeckMastered {
            return 2.5
        } else if masteryProgress >= 1.0 {
            return 1.5
        }
        return 1
    }
}

#Preview {
    HStack(spacing: 16) {
        // State 0: No mastery
        DeckMasteryTile(
            topic: Topic(name: "Beginner 1", filename: "beginner_1"),
            masteryProgress: 0.0,
            isDeckMastered: false
        )
        
        // State A: 100% word mastery, not exam passed
        DeckMasteryTile(
            topic: Topic(name: "Beginner 2", filename: "beginner_2"),
            masteryProgress: 1.0,
            isDeckMastered: false
        )
        
        // State B: Exam passed (fully mastered)
        DeckMasteryTile(
            topic: Topic(name: "Beginner 3", filename: "beginner_3"),
            masteryProgress: 1.0,
            isDeckMastered: true
        )
    }
    .padding()
}

