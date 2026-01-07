//
//  SupportView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-15.
//

import SwiftUI

struct SupportView: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.steamedGradient)
                            .padding(24)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
                            )
                        
                        Text("Connect with Us")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Have questions, feedback, or just want to say hi? We'd love to hear from you!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .lineSpacing(4)
                    }
                    .padding(.top, 40)
                    
                    // Links Section
                    VStack(spacing: 16) {
                        SupportLinkRow(
                            icon: "globe",
                            title: "Visit our Website",
                            subtitle: "www.steamed.app",
                            url: URL(string: "https://www.steamed.app")!
                        )
                        
                        SupportLinkRow(
                            icon: "camera.fill",
                            title: "Follow on Instagram",
                            subtitle: "@steamed.app",
                            url: URL(string: "https://instagram.com/steamed.app")!
                        )
                        
                        SupportLinkRow(
                            icon: "envelope.fill",
                            title: "Email Us",
                            subtitle: "hello@steamed.app",
                            url: URL(string: "mailto:hello@steamed.app")!
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Steamed App")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text("Made with ❤️ for language learners")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SupportLinkRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let url: URL
    
    var body: some View {
        Link(destination: url) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.steamedBlue.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(.steamedDarkBlue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.3))
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    NavigationView {
        SupportView()
    }
}
