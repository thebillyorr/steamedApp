//
//  StorySwimlaneSection.swift
//  ChineseApp
//
//  Created by Billy Orr on 2026-01-06.
//

import SwiftUI

struct StorySwimlaneSection: View {
    let title: String
    let stories: [StoryMetadata]
    let storyProgress: StoryProgressManager
    let onSelect: (StoryMetadata) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Horizontal Swimlane
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(stories) { story in
                        Button {
                            onSelect(story)
                        } label: {
                            CompactStoryCard(
                                story: story,
                                isCompleted: storyProgress.isCompleted(storyId: story.storyId)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Add leading padding to first item only
                        .padding(.leading, story.id == stories.first?.id ? 16 : 0)
                        // Add trailing padding to last item only
                        .padding(.trailing, story.id == stories.last?.id ? 16 : 0)
                    }
                }
            }
        }
    }
}
