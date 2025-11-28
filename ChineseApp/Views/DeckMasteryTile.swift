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
    let isDeckMastered: Bool     // All words in deck mastered?
    
    var body: some View {
        VStack(spacing: 14) {
            // Mastery ring (centered)
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 4)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: masteryProgress)
                    .stroke(
                        isDeckMastered ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: masteryProgress)
                
                // Center icon based on state
                VStack(spacing: 3) {
                    if isDeckMastered {
                        // All words mastered - green star
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                    } else {
                        // In progress - show percentage
                        Text("\(Int(masteryProgress * 100))%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .frame(width: 60, height: 60)
            
            // Topic name
            Text(topic.name)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundColor(.primary)
        }
        .frame(width: 140, height: 140)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
        .shadow(
            color: isDeckMastered ? Color.green.opacity(0.15) : (masteryProgress >= 1.0 ? Color.green.opacity(0.1) : Color.clear),
            radius: 4,
            x: 0,
            y: 2
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        // State 1: In progress (25%)
        DeckMasteryTile(
            topic: Topic(name: "Beginner 1", filename: "beginner_1"),
            masteryProgress: 0.25,
            isDeckMastered: false
        )
        
        // State 2: Ready for exam (100% words, not exam passed)
        DeckMasteryTile(
            topic: Topic(name: "Beginner 2", filename: "beginner_2"),
            masteryProgress: 1.0,
            isDeckMastered: false
        )
        
        // State 3: Exam passed (mastered)
        DeckMasteryTile(
            topic: Topic(name: "Beginner 3", filename: "beginner_3"),
            masteryProgress: 1.0,
            isDeckMastered: true
        )
    }
    .padding()
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

