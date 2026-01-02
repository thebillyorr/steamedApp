//
//  ProfileView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-13.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @ObservedObject private var profileManager = UserProfileManager.shared
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var deckMasteryManager = DeckMasteryManager.shared
    @ObservedObject private var storyProgress = StoryProgressManager.shared
    
    @AppStorage("appTheme") private var selectedTheme: String = "System"
    @State private var showEditProfile = false
    @State private var currentStreak = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Profile Header
                        VStack(spacing: 16) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(Color(.secondarySystemGroupedBackground))
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                
                                if let data = profileManager.userProfile.profileImageData,
                                   let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 90, height: 90)
                                        .clipShape(Circle())
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: profileManager.userProfile.profileColor))
                                            .frame(width: 90, height: 90)
                                        
                                        Text(profileManager.userProfile.initials)
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                // Edit Badge
                                Button(action: { showEditProfile = true }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.steamedDarkBlue)
                                        .background(Circle().fill(Color.white))
                                }
                                .offset(x: 35, y: 35)
                            }
                            
                            // Name & Join Date
                            VStack(spacing: 4) {
                                Text(profileManager.userProfile.fullName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("Member since 2025")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Stats Grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("STATISTICS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            // Streak Card (Full Width)
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(currentStreak)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text("Day Streak")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(Color.steamedGradient)
                            }
                            .padding(20)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                StatCard(
                                    title: "Words Mastered",
                                    value: getTotalWordsMastered(),
                                    icon: "star.fill",
                                    color: .steamedDarkBlue
                                )
                                
                                StatCard(
                                    title: "Stories Read",
                                    value: storyProgress.totalCompleted(),
                                    icon: "book.closed.fill",
                                    color: .steamedDarkBlue
                                )
                                
                                StatCard(
                                    title: "Decks Mastered",
                                    value: getDecksmastered(),
                                    icon: "checkmark.seal.fill",
                                    color: .steamedDarkBlue
                                )
                                
                                StatCard(
                                    title: "Sessions",
                                    value: getTotalSessions(),
                                    icon: "clock.fill",
                                    color: .steamedDarkBlue
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - Settings Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PREFERENCES")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 0) {
                                // Theme Picker
                                HStack {
                                    HStack(spacing: 12) {
                                        Image(systemName: "moon.stars.fill")
                                            .foregroundColor(.steamedDarkBlue)
                                            .font(.system(size: 18))
                                        Text("App Theme")
                                            .font(.body)
                                    }
                                    
                                    Spacer()
                                    
                                    Picker("Theme", selection: $selectedTheme) {
                                        Text("System").tag("System")
                                        Text("Light").tag("Light")
                                        Text("Dark").tag("Dark")
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.secondary)
                                }
                                .padding(16)
                                
                                Divider().padding(.leading, 46)
                                
                                // Support Link
                                NavigationLink(destination: Text("Contact Support").navigationTitle("Support")) {
                                    HStack {
                                        HStack(spacing: 12) {
                                            Image(systemName: "envelope.fill")
                                                .foregroundColor(.steamedDarkBlue)
                                                .font(.system(size: 18))
                                            Text("Contact Support")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.secondary.opacity(0.5))
                                    }
                                    .padding(16)
                                }
                                
                                Divider().padding(.leading, 46)
                                
                                // Privacy Policy
                                NavigationLink(destination: Text("Privacy Policy").navigationTitle("Privacy Policy")) {
                                    HStack {
                                        HStack(spacing: 12) {
                                            Image(systemName: "hand.raised.fill")
                                                .foregroundColor(.steamedDarkBlue)
                                                .font(.system(size: 18))
                                            Text("Privacy Policy")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.secondary.opacity(0.5))
                                    }
                                    .padding(16)
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        }
                        .padding(.horizontal, 16)
                        
                        // Version Info
                        Text("Steamed v1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditProfile) {
                EditProfileSheet()
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
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profileManager = UserProfileManager.shared
    
    @State private var fullName: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                ZStack {
                                    if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else if let data = profileManager.userProfile.profileImageData,
                                              let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(Color(hex: profileManager.userProfile.profileColor))
                                            .frame(width: 100, height: 100)
                                        
                                        Text(profileManager.userProfile.initials)
                                            .font(.system(size: 40, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    // Camera Overlay
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                    }
                                    .frame(width: 100, height: 100)
                                }
                            }
                            .buttonStyle(.plain)
                            
                            Text("Tap to change photo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $fullName)
                        .textContentType(.name)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                }
            }
            .onAppear {
                fullName = profileManager.userProfile.fullName
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        profileManager.updateProfile(
            fullName: fullName,
            profileImageData: selectedImageData
        )
    }
}
