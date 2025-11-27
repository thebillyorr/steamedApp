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
    @ObservedObject private var deckMasteryManager = DeckMasteryManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
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
                            Text("Profile")
                                .font(.title)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: { showSettings = true }) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(width: 44, height: 44)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // MARK: - Profile Card
                        ZStack(alignment: .topTrailing) {
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
                                    Text(profileManager.userProfile.fullName)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Text("@\(profileManager.userProfile.username)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.bottom, 12)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Edit Profile Pencil Icon
                            Button(action: { showEditProfile = true }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            .padding(.top, 12)
                            .padding(.trailing, 12)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        // MARK: - Badges & Achievements
                        VStack(spacing: 12) {
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
                        
                        // MARK: - Stats Section
                        VStack(spacing: 12) {
                            Text("Your Progress")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            // Top row: Words Practiced, Mastered, Sessions
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Words Practiced",
                                    value: getTotalWordsPracticed(),
                                    icon: "book.fill",
                                    color: .gray
                                )
                                
                                StatCard(
                                    title: "Mastered",
                                    value: getTotalWordsMastered(),
                                    icon: "star.fill",
                                    color: .gray
                                )
                                
                                StatCard(
                                    title: "Sessions",
                                    value: getTotalSessions(),
                                    icon: "play.circle.fill",
                                    color: .gray
                                )
                            }
                            .padding(.horizontal, 16)
                            
                            // Bottom row: Decks Mastered, Best Streak (placeholder), Accuracy (placeholder)
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Decks Mastered",
                                    value: getDecksmastered(),
                                    icon: "checkmark.seal.fill",
                                    color: .gray
                                )
                                
                                StatCard(
                                    title: "Best Streak",
                                    value: 0,
                                    icon: "flame.fill",
                                    color: .gray,
                                    isPlaceholder: true
                                )
                                
                                StatCard(
                                    title: "Accuracy",
                                    value: 0,
                                    icon: "target",
                                    color: .gray,
                                    isPlaceholder: true
                                )
                            }
                            .padding(.horizontal, 16)
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
    
    private func getDecksmastered() -> Int {
        let allTopics = DataService.allTopics
        return allTopics.filter { deckMasteryManager.isDeckMastered(filename: $0.filename) }.count
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
    var isPlaceholder: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
                .opacity(isPlaceholder ? 0.4 : 1.0)
            
            if isPlaceholder {
                Text("—")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .opacity(0.5)
            } else {
                Text(String(value))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .opacity(isPlaceholder ? 0.5 : 1.0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .opacity(isPlaceholder ? 0.6 : 1.0)
    }
}

// MARK: - Badge Coin Component
struct BadgeCoinView: View {
    let badge: TopicBadge
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Main coin face
                ZStack {
                    // Front metallic face with iridescent gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(red: 0.95, green: 0.95, blue: 0.97), location: 0.0),
                                    .init(color: Color(red: 0.92, green: 0.88, blue: 0.98), location: 0.25),
                                    .init(color: Color(red: 0.88, green: 0.93, blue: 0.98), location: 0.5),
                                    .init(color: Color(red: 0.95, green: 0.93, blue: 0.85), location: 0.75),
                                    .init(color: Color(red: 0.93, green: 0.93, blue: 0.95), location: 1.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    // Subtle glossy overlay
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .frame(width: 70, height: 70)
                        .offset(y: -3)
                    
                    // Roman numeral
                    Text(badge.romanNumeral)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.42))
                        .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 0.5)
                }
                .frame(width: 80, height: 80)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
            }
            .frame(width: 88, height: 88)
            
            Text(badge.category)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
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
