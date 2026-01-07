//
//  TermsOfServiceView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2026-01-02.
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Terms of Service")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Last updated: January 2, 2026")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 16)
                
                // Sections
                Group {
                    TermsSection(
                        number: "1",
                        title: "Acceptance of Terms",
                        content: "By downloading, installing, or using the Steamed app and/or visiting the Steamed website, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use Steamed."
                    )
                    
                    TermsSection(
                        number: "2",
                        title: "License Grant",
                        content: """
                        Steamed grants you a limited, non-exclusive, non-transferable license to download and use the Steamed app on your personal device for educational purposes only. You may not:
                        
                        • Copy, modify, or distribute the app or its content
                        • Use Steamed for commercial purposes
                        • Attempt to reverse-engineer, decompile, or discover the source code
                        • Use automated tools or scrapers to extract content
                        • Use Steamed to create derivative products or services
                        """
                    )
                    
                    TermsSection(
                        number: "3",
                        title: "User Responsibilities",
                        content: """
                        You are responsible for:
                        
                        • Maintaining the security of your device
                        • Using Steamed in compliance with all applicable laws
                        • Not engaging in any illegal or harmful activities through the app
                        • Respecting intellectual property rights of content provided in Steamed
                        """
                    )
                    
                    TermsSection(
                        number: "4",
                        title: "Content and Intellectual Property",
                        content: "All content in Steamed, including texts, articles, vocabulary, translations, and design elements, is owned by steamed.app or licensed from third parties. You may use this content solely for personal educational purposes. Unauthorized reproduction, distribution, or modification is prohibited."
                    )
                    
                    TermsSection(
                        number: "5",
                        title: "Warranty Disclaimer",
                        content: """
                        Steamed is provided "as-is" and "as-available" without warranties of any kind. We disclaim all express and implied warranties, including fitness for a particular purpose, merchantability, and non-infringement. We do not guarantee that:
                        
                        • Steamed will be error-free or uninterrupted
                        • Defects will be corrected
                        • Content is accurate or complete
                        • The app will meet your specific learning goals
                        """
                    )
                    
                    TermsSection(
                        number: "6",
                        title: "Limitation of Liability",
                        content: "To the maximum extent permitted by law, steamed.app and its developers shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of Steamed, even if we've been advised of the possibility of such damages."
                    )
                    
                    TermsSection(
                        number: "7",
                        title: "Modifications and Discontinuation",
                        content: "We reserve the right to modify, update, or discontinue Steamed at any time. We may also update these Terms of Service. Continued use of Steamed after changes constitutes your acceptance of the updated terms."
                    )
                    
                    TermsSection(
                        number: "8",
                        title: "Acceptable Use Policy",
                        content: """
                        You agree not to use Steamed to:
                        
                        • Violate any applicable laws or regulations
                        • Engage in harassment, abuse, or threatening behavior
                        • Distribute malware, viruses, or harmful code
                        • Attempt unauthorized access to Steamed systems or other users' devices
                        """
                    )
                    
                    TermsSection(
                        number: "9",
                        title: "Third-Party Links",
                        content: "The Steamed website may contain links to third-party websites. We are not responsible for the content, accuracy, or practices of external sites. Your use of third-party services is governed by their terms of service."
                    )
                    
                    TermsSection(
                        number: "10",
                        title: "Severability",
                        content: "If any portion of these Terms is found to be invalid or unenforceable, the remaining provisions shall remain in effect."
                    )
                    
                    TermsSection(
                        number: "11",
                        title: "Contact for Questions",
                        content: "If you have questions about these Terms of Service, please contact us at hello@steamed.app"
                    )
                }
                
                // Footer padding
                Color.clear.frame(height: 20)
            }
            .padding(24)
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

struct TermsSection: View {
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
        TermsOfServiceView()
    }
}
