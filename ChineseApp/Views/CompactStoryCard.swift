//
//  CompactStoryCard.swift
//  ChineseApp
//
//  Created by Billy Orr on 2026-01-06.
//

import SwiftUI

struct CompactStoryCard: View {
    let story: StoryMetadata
    let isCompleted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon / Visual Area
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.yellow.opacity(0.15) : Color.steamedBlue.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                if isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.yellow)
                } else {
                    Image(systemName: "book.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.steamedDarkBlue)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Title & Subtitle Group
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let subtitle = story.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(16)
        .frame(width: 150, height: 160)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCompleted ? Color.yellow.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
    
    private func getBadgeColor(level: Int) -> Color {
        switch level {
        case 1, 2: return .green
        case 3: return .blue
        case 4: return .orange
        case 5, 6: return .red
        default: return .gray
        }
    }
}
