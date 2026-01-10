//
//  PracticeRootView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import SwiftUI

struct PracticeRootView: View {
    @State private var activeDeck: Topic = Self.loadLastDeck()
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
            .onChange(of: activeDeck) { _, newDeck in
                UserDefaults.standard.set(newDeck.filename, forKey: "lastPracticeDeckFilename")
            }
        }
    }
    
    private static func loadLastDeck() -> Topic {
        if let savedName = UserDefaults.standard.string(forKey: "lastPracticeDeckFilename"),
           let found = DataService.allTopics.first(where: { $0.filename == savedName }) {
            return found
        }
        // Default to the first one (usually Bookmarks or Core 1) if nothing saved
        return DataService.allTopics.first ?? Topic(name: "Aquarium", filename: "Aquarium", icon: "fish")
    }
}

#Preview {
    PracticeRootView()
}


