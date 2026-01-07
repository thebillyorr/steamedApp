//
//  CompactDeckCard.swift
//  ChineseApp
//
//  Created by Billy Orr on 2026-01-06.
//

import SwiftUI

struct CompactDeckCard: View {
    let topic: Topic
    let masteryProgress: Double
    let isDeckMastered: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Updated Icon area with cleaner look
            HStack {
                ZStack {
                    Circle()
                        .fill(isDeckMastered ? Color.yellow.opacity(0.15) : Color.steamedBlue.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    if isDeckMastered {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.yellow)
                    } else {
                        Image(systemName: topic.icon)
                            .font(.system(size: 20))
                            .foregroundColor(.steamedDarkBlue)
                    }
                }
                
                Spacer()
                
                // Mini Percentage Pill
                if masteryProgress > 0 && !isDeckMastered {
                    Text("\(Int(masteryProgress * 100))%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.steamedDarkBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.steamedBlue.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            // Title & Subtitle Group
            VStack(alignment: .leading, spacing: 4) {
                Text(topic.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Progress Bar
                if !isDeckMastered {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 4)
                            
                            Capsule()
                                .fill(Color.steamedDarkBlue)
                                .frame(width: max(0, geo.size.width * masteryProgress), height: 4)
                        }
                    }
                    .frame(height: 4)
                } else {
                    Text("Complete")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .frame(width: 150, height: 160)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}
