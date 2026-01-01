//
//  DeckMasteryTile.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-13.
//

import SwiftUI

struct DeckCardView: View {
    let topic: Topic
    let masteryProgress: Double
    let isDeckMastered: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Icon
                Image(systemName: topic.icon)
                    .font(.system(size: 30))
                    .foregroundColor(.primary)
                
                // Mastery Ring around icon
                if !isDeckMastered {
                    Circle()
                        .stroke(Color.gray.opacity(0.1), lineWidth: 3)
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .trim(from: 0, to: masteryProgress)
                        .stroke(Color.blue.opacity(0.8), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 70, height: 70)
                } else {
                    // Completed Ring (Blue Theme)
                    Circle()
                        .stroke(Color.steamedGradient, lineWidth: 3)
                        .frame(width: 70, height: 70)
                }
                
                // Completed Badge
                if isDeckMastered {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Circle().fill(Color.steamedDarkBlue))
                        .offset(x: 24, y: -24)
                        .shadow(radius: 1)
                }
            }
            .frame(height: 80)
            
            Text(topic.name)
                .font(.system(size: 15, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .foregroundColor(.primary)
                .frame(height: 40, alignment: .top)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ZStack {
        Color(.systemGray6)
        HStack {
            DeckCardView(
                topic: Topic(name: "Aquarium", filename: "Aquarium", icon: "fish"),
                masteryProgress: 0.75,
                isDeckMastered: false
            )
            DeckCardView(
                topic: Topic(name: "Camping", filename: "Camping", icon: "tent"),
                masteryProgress: 1.0,
                isDeckMastered: true
            )
        }
        .padding()
    }
}

