//
//  ChineseAppApp.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import SwiftUI

@main
struct ChineseAppApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
