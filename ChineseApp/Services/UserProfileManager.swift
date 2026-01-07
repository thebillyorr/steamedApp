//
//  UserProfileManager.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-13.
//

import Foundation
import Combine

final class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()
    
    @Published private(set) var userProfile: UserProfile
    
    private let profileKey = "userProfile"
    private let imageFileName = "profile_image.data"
    
    private init() {
        self.userProfile = UserProfileManager.loadProfile()
    }
    
    func updateProfile(
        username: String? = nil,
        fullName: String? = nil,
        profileColor: String? = nil,
        profileImageData: Data? = nil
    ) {
        if let username = username {
            userProfile.username = username
        }
        if let fullName = fullName {
            userProfile.fullName = fullName
        }
        if let profileColor = profileColor {
            userProfile.profileColor = profileColor
        }
        if let profileImageData = profileImageData {
            userProfile.profileImageData = profileImageData
        }
        saveProfile()
    }
    
    private func saveProfile() {
        // 1. Handle Image Storage (File System)
        if let data = userProfile.profileImageData {
            saveImageToDisk(data)
        } else {
            deleteImageFromDisk()
        }
        
        // 2. Handle Text Metadata (UserDefaults)
        // detailed copy to avoid saving massive image data into UserDefaults
        var copyToSave = userProfile
        copyToSave.profileImageData = nil
        
        if let encoded = try? JSONEncoder().encode(copyToSave) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
            // Trigger published update for UI
            self.userProfile = userProfile // keeps the image data in memory
        }
    }
    
    // MARK: - Disk I/O Helpers
    
    private func getImageURL() -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsDirectory.appendingPathComponent(imageFileName)
    }
    
    private func saveImageToDisk(_ data: Data) {
        guard let url = getImageURL() else { return }
        try? data.write(to: url)
    }
    
    private func deleteImageFromDisk() {
        guard let url = getImageURL() else { return }
        try? FileManager.default.removeItem(at: url)
    }
    
    private static func loadImageFromDisk() -> Data? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let url = documentsDirectory.appendingPathComponent("profile_image.data")
        return try? Data(contentsOf: url)
    }
    
    private static func loadProfile() -> UserProfile {
        // 1. Try to load metadata from UserDefaults
        var profile: UserProfile
        
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        } else {
            profile = UserProfile()
        }
        
        // 2. If valid image in UserDefaults (legacy migration), save to disk
        if profile.profileImageData != nil {
            // We found data in the JSON. This is "Legacy" mode.
            // We should immediately move it to disk to clean up.
            // But we can't write to disk in a static context easily without duplicating logic or making helpers static.
            // For now, we return it as is. The NEXT save will clean it up.
            return profile
        }
        
        // 3. Otherwise, try loading from disk
        if let diskData = loadImageFromDisk() {
            profile.profileImageData = diskData
        }
        
        return profile
    }
}
