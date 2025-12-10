import Foundation
import Combine

/// Tracks which stories have been completed by the user.
/// Backed by UserDefaults so it behaves similarly to ProgressManager.
final class StoryProgressManager: ObservableObject {
    static let shared = StoryProgressManager()
    private let completedStoriesKey = "completedStories"

    /// Published set of completed story IDs (e.g. "s001").
    @Published private(set) var completedStoryIds: Set<String>

    private init() {
        let saved = UserDefaults.standard.array(forKey: completedStoriesKey) as? [String] ?? []
        self.completedStoryIds = Set(saved)
    }

    private func persist() {
        UserDefaults.standard.set(Array(completedStoryIds), forKey: completedStoriesKey)
    }

    func isCompleted(storyId: String) -> Bool {
        completedStoryIds.contains(storyId)
    }

    func toggleCompletion(storyId: String) {
        if completedStoryIds.contains(storyId) {
            completedStoryIds.remove(storyId)
        } else {
            completedStoryIds.insert(storyId)
        }
        persist()
    }

    /// Convenience for profile stats
    func totalCompleted() -> Int {
        completedStoryIds.count
    }
}
