//
//  ContentView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                PracticeRootView()
                    .tabItem {
                        Label("Practice", systemImage: "rectangle.stack.badge.play")
                    }
                    .tag(0)
                
                DictionaryView()
                    .tabItem {
                        Label("Dictionary", systemImage: "book")
                    }
                    .tag(1)
                
                ReadingView()
                    .tabItem {
                        Label("Library", systemImage: "book.pages")
                    }
                    .tag(2)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
                    .tag(3)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToPracticeTab"))) { _ in
                selectedTab = 0
            }
        }
    }
}

#Preview {
    ContentView()
}


