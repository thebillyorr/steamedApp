//
//  TopicBadgeManager.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-15.
//

import Foundation

/// Legacy badge manager.
///
/// Badges and topic-level completion are no longer part of the product,
/// so this type is kept only as a stub for now in case we want to
/// reintroduce a similar feature later. It currently does nothing.
final class TopicBadgeManager {
    static let shared = TopicBadgeManager()
    
    private init() {}
}
