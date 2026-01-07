//
//  PrivacyPolicyView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2026-01-02.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Last updated: January 2, 2026")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 16)
                
                // TL;DR Box
                VStack(alignment: .leading, spacing: 12) {
                    Label("TL;DR", systemImage: "info.circle.fill")
                        .font(.headline)
                        .foregroundColor(.steamedDarkBlue)
                    
                    Text("Steamed doesn't collect any personal data. Your learning progress is stored locally on your device only. We don't have servers tracking you. It's just you, Steamed, and your device.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(Color.steamedBlue.opacity(0.15))
                .cornerRadius(12)
                
                // Sections
                Group {
                    PrivacySection(
                        number: "1",
                        title: "Overview",
                        content: "Welcome to Steamed. We are committed to protecting your privacy. This Privacy Policy explains how we handle data when you use the Steamed app and website. The short version: we don't collect personal data. Your language learning journey stays on your device."
                    )
                    
                    PrivacySection(
                        number: "2",
                        title: "Data Collection",
                        content: """
                        Steamed does not collect, store, or transmit any personal information. Here's what this means:
                        
                        • No Account Required: You don't need to sign up, log in, or create an account to use Steamed.
                        • No Tracking: We don't track your reading activity, vocabulary progress, or any usage data.
                        • No Personal Information: We don't ask for your name, email, location, age, or any identifying information.
                        • No Analytics: We don't use analytics services to monitor app usage.
                        • No Third-Party Data Sharing: Since we don't collect data, we have nothing to share with third parties.
                        """
                    )
                    
                    PrivacySection(
                        number: "3",
                        title: "Local Storage",
                        content: "All your learning data (bookmarked words, reading progress, practice history) is stored locally on your device using your device's native cache/storage. This data never leaves your device and is never transmitted to any servers. You have complete control over this data—it's deleted if you uninstall the app."
                    )
                    
                    PrivacySection(
                        number: "4",
                        title: "No Internet Requirement",
                        content: "Steamed doesn't require an internet connection to function (except for initial app download). Once installed, you can use the app offline. No data is ever synced to the cloud."
                    )
                    
                    PrivacySection(
                        number: "5",
                        title: "Cookies and Similar Technologies",
                        content: "The Steamed website does not use cookies or similar tracking technologies. We don't track visitors or use analytics on our website."
                    )
                    
                    PrivacySection(
                        number: "6",
                        title: "Security",
                        content: "Since we don't collect or store personal data on our servers, there's minimal risk of data breaches on our end. Your data security depends entirely on your device's security, which is managed by your operating system (iOS, Android, etc.)."
                    )
                    
                    PrivacySection(
                        number: "7",
                        title: "Children's Privacy",
                        content: "Steamed is suitable for users of all ages. Since we don't collect any data, we don't have special protections for children—because we don't collect anyone's data. Parents can be confident that their children's learning activity remains private to their device."
                    )
                    
                    PrivacySection(
                        number: "8",
                        title: "Changes to This Privacy Policy",
                        content: "We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated \"last updated\" date. Since we don't collect data, privacy changes will likely be minimal."
                    )
                    
                    PrivacySection(
                        number: "9",
                        title: "Contact Us",
                        content: "If you have any questions about this Privacy Policy or our privacy practices, please contact us at hello@steamed.app"
                    )
                }
                
                // Footer padding
                Color.clear.frame(height: 20)
            }
            .padding(24)
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

struct PrivacySection: View {
    let number: String
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(number). \(title)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
