//
//  UserProfile.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-13.
//

import Foundation

struct UserProfile: Codable {
    var username: String
    var fullName: String
    var profileColor: String  // HEX color for profile picture background
    
    init(username: String = "Learner", fullName: String = "Language Student", profileColor: String = "#FF6B6B") {
        self.username = username
        self.fullName = fullName
        self.profileColor = profileColor
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
