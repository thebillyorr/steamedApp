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
    
    private init() {
        self.userProfile = UserProfileManager.loadProfile()
    }
    
    func updateProfile(username: String? = nil, fullName: String? = nil, profileColor: String? = nil) {
        if let username = username {
            userProfile.username = username
        }
        if let fullName = fullName {
            userProfile.fullName = fullName
        }
        if let profileColor = profileColor {
            userProfile.profileColor = profileColor
        }
        saveProfile()
    }
    
    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
            // Trigger published update
            self.userProfile = userProfile
        }
    }
    
    private static func loadProfile() -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return decoded
        }
        // Return default profile on first launch
        return UserProfile()
    }
}
