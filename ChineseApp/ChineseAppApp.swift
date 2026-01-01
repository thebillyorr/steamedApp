//
//  ChineseAppApp.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import SwiftUI

@main
struct ChineseAppApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var showSplash = true
    @AppStorage("appTheme") private var appTheme: String = "System"
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
                    .zIndex(1)
            } else {
                ContentView()
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .preferredColorScheme(preferredColorScheme)
    }
}
