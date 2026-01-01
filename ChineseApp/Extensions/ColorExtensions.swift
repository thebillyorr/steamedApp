//
//  ColorExtensions.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-15.
//

import SwiftUI

extension Color {
    /// Initialize color from hex string (e.g., "#FF6B6B")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let rgb = Int(hex, radix: 16) ?? 0xFF6B6B
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
    
    // MARK: - Steamed Theme Colors
    static let steamedBlue = Color(red: 0.6, green: 0.85, blue: 0.95) // Pastel Light Blue
    static let steamedDarkBlue = Color(red: 0.3, green: 0.5, blue: 0.7) // Darker blue
    
    static let steamedGradient = LinearGradient(
        gradient: Gradient(colors: [.steamedBlue, .steamedDarkBlue]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
