//
//  SettingsView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-13.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - App Settings (Future)
                Section(header: Text("App Preferences")) {
                    Toggle("Notifications", isOn: .constant(true))
                    Toggle("Sound Effects", isOn: .constant(true))
                    Picker("Theme", selection: .constant("System")) {
                        Text("System").tag("System")
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                }
                
                // MARK: - Learning Stats
                Section(header: Text("Learning Stats")) {
                    HStack {
                        Text("Total Words Practiced")
                        Spacer()
                        Text("\(getTotalWordsPracticed())")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Words Mastered")
                        Spacer()
                        Text("\(getTotalWordsMastered())")
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    HStack {
                        Text("Total Sessions")
                        Spacer()
                        Text("\(getTotalSessions())")
                            .fontWeight(.semibold)
                    }
                }
                
                // MARK: - Danger Zone
                Section(header: Text("Danger Zone").foregroundColor(.red)) {
                    Button("Reset All Progress", role: .destructive) {
                        resetProgress()
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
    }
    
    private func getTotalWordsPracticed() -> Int {
        let progress = ProgressManager.loadProgress()
        return progress.count
    }
    
    private func getTotalWordsMastered() -> Int {
        let progress = ProgressManager.loadProgress()
        return progress.filter { $0.value >= 1.0 }.count
    }
    
    private func getTotalSessions() -> Int {
        let sessionCounts = ProgressManager.loadSessionCounts()
        return sessionCounts.values.reduce(0, +)
    }
    
    private func resetProgress() {
        let alert = UIAlertController(title: "Reset All Progress?", message: "This action cannot be undone. All your progress will be permanently deleted.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            ProgressManager.resetAll()
            ProgressStore.shared.resetAll()
        })
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}

#Preview {
    SettingsView()
}
