//
//  ProfileView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-13.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var profileManager = UserProfileManager.shared
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var badgeManager = TopicBadgeManager.shared
    @State private var showSettings = false
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Header with Settings
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Profile")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                Text("Chinese Learner")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            Button(action: { showSettings = true }) {
                                Image(systemName: "gear")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .frame(width: 44, height: 44)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // MARK: - Profile Card
                        VStack(spacing: 16) {
                            // Profile Picture Circle
                            ZStack {
                                Circle()
                                    .fill(colorFromHex(profileManager.userProfile.profileColor))
                                    .frame(width: 120, height: 120)
                                    .shadow(radius: 8)
                                
                                Text(profileManager.userProfile.initials)
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 12)
                            
                            // Username and Name
                            VStack(spacing: 4) {
                                Text("@\(profileManager.userProfile.username)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(profileManager.userProfile.fullName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Edit Profile Button
                            Button(action: { showEditProfile = true }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Profile")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        // MARK: - Stats Section
                        VStack(spacing: 12) {
                            Text("Your Progress")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Words Practiced",
                                    value: getTotalWordsPracticed(),
                                    icon: "book.fill",
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "Mastered",
                                    value: getTotalWordsMastered(),
                                    icon: "star.fill",
                                    color: .green
                                )
                                
                                StatCard(
                                    title: "Sessions",
                                    value: getTotalSessions(),
                                    icon: "play.circle.fill",
                                    color: .orange
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // MARK: - Mastery Overview
                        VStack(spacing: 12) {
                            Text("Mastery Overview")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                let masteryPercentage = calculateMasteryPercentage()
                                
                                // Progress bar
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Overall Mastery")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Text("\(Int(masteryPercentage))%")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            // Background
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(.systemGray5))
                                            
                                            // Progress
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [.blue, .cyan]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: geometry.size.width * masteryPercentage / 100)
                                        }
                                    }
                                    .frame(height: 12)
                                }
                                .padding(16)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // MARK: - Badges & Achievements
                        VStack(spacing: 12) {
                            Text("Badges & Achievements")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            let earnedBadges = badgeManager.getAllEarnedBadges()
                            
                            if earnedBadges.isEmpty {
                                VStack(spacing: 12) {
                                    Text("No badges yet 🏅")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Complete entire topics to earn badges")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(24)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                            } else {
                                // Display earned badges in a grid
                                VStack(spacing: 16) {
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                        ForEach(earnedBadges, id: \.category) { badge in
                                            BadgeCoinView(badge: badge)
                                        }
                                    }
                                    .padding(20)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        
                        // MARK: - Friends Section Placeholder
                        VStack(spacing: 12) {
                            Text("Friends")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                Text("Coming Soon! 👥")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Add friends and compare progress")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(24)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Helper Functions
    
    private func getTotalWordsPracticed() -> Int {
        progressStore.progress.count
    }
    
    private func getTotalWordsMastered() -> Int {
        progressStore.progress.filter { $0.value >= 1.0 }.count
    }
    
    private func getTotalSessions() -> Int {
        let sessionCounts = ProgressManager.loadSessionCounts()
        return sessionCounts.values.reduce(0, +)
    }
    
    private func calculateMasteryPercentage() -> Double {
        let progress = progressStore.progress
        guard !progress.isEmpty else { return 0 }
        
        // If all words are at 1.0, return exactly 100%
        if progress.values.allSatisfy({ $0 >= 0.99 }) {
            return 100.0
        }
        
        let totalProgress = progress.values.reduce(0, +)
        let percentage = (totalProgress / Double(progress.count)) * 100
        
        // Round to nearest integer to avoid floating point artifacts
        return round(percentage)
    }
    
    private func colorFromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let rgb = Int(hex, radix: 16) ?? 0xFF6B6B
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(String(value))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [color.opacity(0.1), color.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .borderLine(color: color.opacity(0.3), width: 1)
        .cornerRadius(12)
    }
}

// MARK: - Badge Coin Component
struct BadgeCoinView: View {
    let badge: TopicBadge
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: badge.badgeColor).opacity(0.2),
                                Color(hex: badge.badgeColor).opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                // Badge coin
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: badge.badgeColor),
                                Color(hex: badge.badgeColor).opacity(0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .shadow(radius: 6)
                
                // Inner circle (3D effect)
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.black.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 90, height: 90)
                
                // Roman numeral
                Text(badge.romanNumeral)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(badge.category)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Border Line Extension
extension View {
    func borderLine(color: Color = Color.black, width: CGFloat = 1) -> some View {
        self.border(color, width: width)
    }
}

#Preview {
    ProfileView()
}
