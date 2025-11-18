//
//  ContentView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import SwiftUI

struct ContentView: View {
    @State private var showTestMenu = false
    
    var body: some View {
        ZStack {
            TabView {
                PracticeRootView()
                    .tabItem {
                        Label("Practice", systemImage: "rectangle.stack.badge.play")
                    }
                
                DictionaryView()
                    .tabItem {
                        Label("Dictionary", systemImage: "book")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
            }
            
            // Test menu button (top right)
            VStack {
                HStack {
                    Spacer()
                    Button(action: { showTestMenu.toggle() }) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(8)
                            .opacity(0.4)
                    }
                }
                .padding()
                Spacer()
            }
            .zIndex(100)
            
            // Test menu sheet
            .sheet(isPresented: $showTestMenu) {
                TestMenuView()
            }
        }
    }
}

struct TestMenuView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Test Suite") {
                    Button("Run Tests", action: runTests)
                        .foregroundColor(.blue)
                }
                
                Section("Info") {
                    Text("Edit the runTests() function in ContentView.swift to customize test commands")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("🔧 Test Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func runTests() {
        // ===== EDIT YOUR TEST COMMANDS HERE =====
        ProgressManager.setDeckMastered(filename: "intermediate_2")
        //ProgressManager.setWordMastered("前")
        //DeckMasteryManager.shared.resetDeck(filename: "beginner_8")
        print("✅ Test completed!")
        // ===== END TEST COMMANDS =====
    }
}

#Preview {
    ContentView()
}


