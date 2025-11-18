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
}
