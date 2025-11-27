//
//  ThemeManager.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-26.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme? = .light
    
    private let themeKey = "appTheme"
    
    static let shared = ThemeManager()
    
    init() {
        // Load theme preference from UserDefaults
        let savedTheme = UserDefaults.standard.string(forKey: themeKey) ?? "Light"
        updateTheme(savedTheme)
    }
    
    func setTheme(_ theme: String) {
        UserDefaults.standard.set(theme, forKey: themeKey)
        updateTheme(theme)
    }
    
    private func updateTheme(_ theme: String) {
        DispatchQueue.main.async {
            switch theme {
            case "Light":
                self.colorScheme = .light
            case "Dark":
                self.colorScheme = .dark
            default:
                self.colorScheme = .light
            }
        }
    }
    
    func getCurrentTheme() -> String {
        return UserDefaults.standard.string(forKey: themeKey) ?? "Light"
    }
}
