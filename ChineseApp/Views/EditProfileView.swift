//
//  EditProfileView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-13.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profileManager = UserProfileManager.shared
    @State private var username: String = ""
    @State private var fullName: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    HStack {
                        Text("@")
                            .foregroundColor(.secondary)
                        TextField("username", text: $username)
                            .textContentType(.username)
                    }
                    
                    TextField("Full Name", text: $fullName)
                        .textContentType(.name)
                }
                
                Section(footer: Text("Profile Photo")) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(colorFromHex(profileManager.userProfile.profileColor))
                                .frame(width: 100, height: 100)
                            
                            Text(profileManager.userProfile.initials)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        
                        Text("Profile photo upload coming soon!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(username.isEmpty || fullName.isEmpty)
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            username = profileManager.userProfile.username
            fullName = profileManager.userProfile.fullName
        }
    }
    
    private func saveChanges() {
        if !username.isEmpty && !fullName.isEmpty {
            profileManager.updateProfile(username: username, fullName: fullName)
            dismiss()
        }
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

#Preview {
    EditProfileView()
}
