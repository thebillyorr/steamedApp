//
//  DetailedStoryRow.swift
//  ChineseApp
//
//  Created by Billy Orr on 2026-01-06.
//

import SwiftUI

struct DetailedStoryRow: View {
    let story: StoryMetadata
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.yellow.opacity(0.15) : Color.steamedBlue.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: isCompleted ? "checkmark.seal.fill" : "book.closed.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isCompleted ? .yellow : .steamedDarkBlue)
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 6) {
                Text(story.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let subtitle = story.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Pills Row
                HStack(spacing: 6) {
                    // HSK Badge
                    Text("HSK \(story.difficulty)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(getBadgeColor(level: story.difficulty))
                        .clipShape(Capsule())
                    // Topic Tags (multiple)
                    ForEach(story.topic, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(Capsule())
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
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
