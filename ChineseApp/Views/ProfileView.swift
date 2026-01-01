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
    @ObservedObject private var deckMasteryManager = DeckMasteryManager.shared
    @ObservedObject private var storyProgress = StoryProgressManager.shared
    @State private var showSettings = false
    @State private var currentStreak = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header Row (Avatar + Info + Settings)
                    HStack(alignment: .center, spacing: 16) {
                        // Avatar
                        ZStack {
                                if let data = profileManager.userProfile.profileImageData,
                                   let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                } else {
                                    Circle()
                                        .fill(colorFromHex(profileManager.userProfile.profileColor))
                                        .frame(width: 80, height: 80)
                                        .shadow(radius: 4)

                                    Text(profileManager.userProfile.initials)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }

                            // Name
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profileManager.userProfile.fullName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }

                            Spacer()

                            // Settings icon
                            Button(action: { showSettings = true }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(width: 36, height: 36)
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // MARK: - Progress Tiles Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Progress")
                                .font(.headline)
                                .padding(.horizontal, 4)

                            VStack(spacing: 12) {
                                // Top row: Words Practiced, Mastered, Sessions
                                HStack(spacing: 12) {
                                    StatCard(
                                        title: "Words Practiced",
                                        value: getTotalWordsPracticed(),
                                        icon: "book.fill",
                                        color: .steamedDarkBlue
                                    )

                                    StatCard(
                                        title: "Mastered",
                                        value: getTotalWordsMastered(),
                                        icon: "star.fill",
                                        color: .steamedDarkBlue
                                    )

                                    StatCard(
                                        title: "Sessions",
                                        value: getTotalSessions(),
                                        icon: "play.circle.fill",
                                        color: .steamedDarkBlue
                                    )
                                }

                                // Bottom row: Decks Mastered, Best Streak, Stories
                                HStack(spacing: 12) {
                                    StatCard(
                                        title: "Decks Mastered",
                                        value: getDecksmastered(),
                                        icon: "checkmark.seal.fill",
                                        color: .steamedDarkBlue
                                    )

                                    StatCard(
                                        title: "Best Streak",
                                        value: currentStreak,
                                        icon: "flame.fill",
                                        color: .steamedDarkBlue
                                    )

                                    StatCard(
                                        title: "Stories",
                                        value: storyProgress.totalCompleted(),
                                        icon: "book.closed.fill",
                                        color: .steamedDarkBlue
                                    )
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
                        .padding(.horizontal, 16)

                        Spacer()
                            .frame(height: 12)
                    }
                    .padding(.vertical, 16)
                }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear {
                currentStreak = ProgressManager.getStreakCount()
            }
        }
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
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(isPlaceholder ? 0.6 : 1.0)
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
