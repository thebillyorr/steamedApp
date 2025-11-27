//
//  PracticeRootView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import SwiftUI

struct PracticeRootView: View {
    @State private var activeDeck: Topic = DataService.allTopics.first ?? Topic(name: "Beginner 1", filename: "beginner_1")
    @State private var startPractice = false
    @State private var showDeckSelection = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ActiveDeckView(
                    topic: activeDeck,
                    onShowDeckSelection: { showDeckSelection = true },
                    onStartPractice: { startPractice = true }
                )
            }
            .navigationTitle("Practice")
            .sheet(isPresented: $showDeckSelection) {
                DeckSelectionView(currentDeck: activeDeck) { selectedDeck in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            activeDeck = selectedDeck
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $startPractice) {
                PracticeSessionView(topic: activeDeck)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SetActiveDeck"))) { notification in
                if let topic = notification.object as? Topic {
                    activeDeck = topic
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SetActiveDeckAndNavigate"))) { notification in
                if let topic = notification.object as? Topic {
                    // Switch to Practice tab
                    NotificationCenter.default.post(name: NSNotification.Name("SwitchToPracticeTab"), object: nil)
                    
                    // Set deck with animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            activeDeck = topic
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PracticeRootView()
}


