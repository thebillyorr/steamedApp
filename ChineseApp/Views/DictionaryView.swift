//
//  DictionaryView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import SwiftUI

struct DictionaryView: View {
    let categories = DataService.topicsByCategory
    @ObservedObject private var progressStore = ProgressStore.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(categories, id: \.category) { category, topics in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(topics) { topic in
                                        NavigationLink(value: topic) {
                                            VStack {
                                                Spacer()
                                                Text(topic.name)
                                                    .font(.headline)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.horizontal, 8)
                                                Spacer()
                                            }
                                            .frame(width: 140, height: 140)
                                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator)))
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
            }
            .navigationTitle("Dictionary")
            .navigationDestination(for: Topic.self) { topic in
                DeckView(topic: topic)
            }
        }
    }
}

#Preview {
    DictionaryView()
}
