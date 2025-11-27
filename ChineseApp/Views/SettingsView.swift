//
//  SettingsView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-13.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var selectedTheme: String = UserDefaults.standard.string(forKey: "appTheme") ?? "Light"
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - App Preferences
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedTheme) {
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                    .onChange(of: selectedTheme) { newValue in
                        themeManager.setTheme(newValue)
                    }
                }
                
                // MARK: - Support & Info (Placeholders)
                Section(header: Text("Support")) {
                    NavigationLink(destination: Text("Contact Us").navigationTitle("Contact Us")) {
                        HStack {
                            Image(systemName: "envelope")
                            Text("Contact Us")
                        }
                    }
                    NavigationLink(destination: Text("Terms & Conditions").navigationTitle("Terms & Conditions")) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Terms & Conditions")
                        }
                    }
                    NavigationLink(destination: Text("Privacy Policy").navigationTitle("Privacy Policy")) {
                        HStack {
                            Image(systemName: "hand.raised")
                            Text("Privacy Policy")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            selectedTheme = themeManager.getCurrentTheme()
        }
    }
}

#Preview {
    SettingsView()
}

