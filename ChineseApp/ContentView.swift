//
//  ContentView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import SwiftUI

struct ContentView: View {
    @State private var showTestMenu = false
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
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToPracticeTab"))) { _ in
                selectedTab = 0
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
        //ProgressManager.setDeckMastered(filename: "intermediate_2")
        // ProgressManager.resetDeck(filename: "beginner_8")
        ProgressManager.resetWord("可以")
        // ProgressManager.setWordMastered("是否")
        // ProgressManager.setWordMastered("可以")
        // ProgressManager.setWordMastered("要")
        // ProgressManager.setWordMastered("应该")
        // ProgressManager.setWordMastered("什么")
        // ProgressManager.setWordMastered("怎么")
        // ProgressManager.setWordMastered("为什么")
        // ProgressManager.setWordMastered("怎么样")
        // ProgressManager.setWordMastered("可能")
        // ProgressManager.setWordMastered("得")
        // ProgressManager.setWordMastered("就要")
        // ProgressManager.setWordMastered("必须")
        //DeckMasteryManager.shared.resetDeck(filename: "beginner_8")
        print("✅ Test completed!")
        // ===== END TEST COMMANDS =====
    }
}

#Preview {
    ContentView()
}


