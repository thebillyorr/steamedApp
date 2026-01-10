//
//  ChineseAppApp.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import SwiftUI
import SwiftData

@main
struct ChineseAppApp: App {
    let container: ModelContainer
    
    init() {
        // Ensure Application Support directory exists to prevent CoreData "Failed to stat path" logs on fresh install
        let fileManager = FileManager.default
        if let supportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
             // Try creating it; if it fails or exists, we proceed anyway.
             // This silence the CoreData error about missing parent directory.
             try? fileManager.createDirectory(at: supportDir, withIntermediateDirectories: true)
        }
        
        do {
            container = try ModelContainer(for: WordProgress.self)
            ProgressManager.shared.setContainer(container)
            BookmarkManager.shared.setContainer(container) // Wire up BookmarkManager
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}

struct RootView: View {
    @State private var showSplash = true
    @AppStorage("appTheme") private var appTheme: String = "System"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @Environment(\.colorScheme) private var systemColorScheme
    
    var preferredColorScheme: ColorScheme? {
        switch appTheme {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil // Let system decide
        }
    }
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView(showSplash: $showSplash)
                    .transition(.opacity)
                    .zIndex(2)
            } else if !hasCompletedOnboarding {
                OnboardingView(isOnboardingCompleted: $hasCompletedOnboarding)
                    .transition(.opacity)
                    .zIndex(1)
            } else {
                ContentView()
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
        .preferredColorScheme(preferredColorScheme)
    }
}
