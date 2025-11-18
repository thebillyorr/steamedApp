//
//  ProgressStore.swift
//  ChineseApp
//
//  Created by assistant on 2025-11-07.
//

import Foundation
import Combine

final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published private(set) var progress: [String: Double] = [:]

    private init() {
        progress = ProgressManager.loadProgress()
    }

    func addProgress(for hanzi: String, delta: Double, in deckFilename: String? = nil) {
        ProgressManager.addProgress(for: hanzi, delta: delta, in: deckFilename)
        // reload published value
        progress = ProgressManager.loadProgress()
    }

    func getProgress(for hanzi: String) -> Double {
        progress[hanzi] ?? 0
    }

    func resetAll() {
        ProgressManager.resetAll()
        progress = [:]
    }
}
