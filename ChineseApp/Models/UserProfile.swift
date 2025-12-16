//
//  UserProfile.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-13.
//

import Foundation

struct UserProfile: Codable {
    // Core identity
    var username: String
    var fullName: String
    var profileColor: String  // HEX color for profile picture background
    
    // Optional profile image stored as Data
    var profileImageData: Data?
    
    init(
        username: String = "Learner",
        fullName: String = "Language Student",
        profileColor: String = "#4A90E2",
        profileImageData: Data? = nil
    ) {
        self.username = username
        self.fullName = fullName
        self.profileColor = profileColor
        self.profileImageData = profileImageData
    }
    
    // Compute initials for profile picture
    var initials: String {
        let components = fullName.split(separator: " ")
        if components.count >= 2 {
            let first = String(components[0].prefix(1)).uppercased()
            let last = String(components[1].prefix(1)).uppercased()
            return first + last
        } else if !fullName.isEmpty {
            return String(fullName.prefix(1)).uppercased()
        }
        return "?"
    }
}
