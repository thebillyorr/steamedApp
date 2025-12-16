//
//  EditProfileView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-13.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profileManager = UserProfileManager.shared
    @State private var fullName: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Full Name", text: $fullName)
                        .textContentType(.name)
                }
                
                Section(footer: Text("Profile Photo")) {
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            ZStack {
                                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .shadow(radius: 8)
                                } else if let data = profileManager.userProfile.profileImageData,
                                          let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .shadow(radius: 8)
                                } else {
                                    Circle()
                                        .fill(colorFromHex(profileManager.userProfile.profileColor))
                                        .frame(width: 100, height: 100)
                                        .shadow(radius: 8)
                                    
                                    Text(profileManager.userProfile.initials)
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        }
                        .buttonStyle(.plain)
                        
                        Text("Tap the circle above to choose a photo from your library.")
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
                    .disabled(fullName.isEmpty)
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
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
    
    private func saveChanges() {
        if !fullName.isEmpty {
            profileManager.updateProfile(
                fullName: fullName,
                profileImageData: selectedImageData
            )
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
