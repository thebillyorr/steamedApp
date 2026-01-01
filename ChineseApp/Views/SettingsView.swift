//
//  SettingsView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-13.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profileManager = UserProfileManager.shared
    @State private var selectedTheme: String = UserDefaults.standard.string(forKey: "appTheme") ?? "System"
    
    // Profile State
    @State private var fullName: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Profile Section
                Section(header: Text("Profile")) {
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            ZStack {
                                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                } else if let data = profileManager.userProfile.profileImageData,
                                          let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                } else {
                                    Circle()
                                        .fill(Color(hex: profileManager.userProfile.profileColor))
                                        .frame(width: 80, height: 80)
                                        .shadow(radius: 4)
                                    
                                    Text(profileManager.userProfile.initials)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                // Edit overlay
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                                    .offset(x: 25, y: 25)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        
                        HStack(spacing: 8) {
                            TextField("Full Name", text: $fullName)
                                .multilineTextAlignment(.center)
                                .textContentType(.name)
                                .font(.headline)
                            
                            Image(systemName: "pencil")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 40)
                    }
                }

                // MARK: - App Preferences
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedTheme) {
                        Text("Use System Setting").tag("System")
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                    .onChange(of: selectedTheme) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "appTheme")
                        saveProfileChanges()
                        dismiss()
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
                        saveProfileChanges()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            selectedTheme = UserDefaults.standard.string(forKey: "appTheme") ?? "System"
            fullName = profileManager.userProfile.fullName
            selectedImageData = profileManager.userProfile.profileImageData
        }
        .onChange(of: selectedItem) { newItem in
            guard let newItem = newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        selectedImageData = data
                    }
                }
            }
        }
    }
    
    private func saveProfileChanges() {
        profileManager.updateProfile(fullName: fullName, profileImageData: selectedImageData)
    }
}

#Preview {
    SettingsView()
}

