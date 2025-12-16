import Foundation
import Combine

final class BookmarkManager: ObservableObject {
    static let shared = BookmarkManager()
    
    @Published private(set) var bookmarkedWordIDs: Set<String> = []
    
    private let bookmarksKey = "bookmarkedWordIDs"
    
    private init() {
        loadBookmarks()
    }
    
    func isBookmarked(wordID: String) -> Bool {
        return bookmarkedWordIDs.contains(wordID)
    }
    
    func toggleBookmark(for wordID: String) {
        if bookmarkedWordIDs.contains(wordID) {
            bookmarkedWordIDs.remove(wordID)
        } else {
            bookmarkedWordIDs.insert(wordID)
        }
        saveBookmarks()
    }
    
    private func loadBookmarks() {
        if let data = UserDefaults.standard.data(forKey: bookmarksKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.bookmarkedWordIDs = decoded
        }
    }
    
    private func saveBookmarks() {
        if let encoded = try? JSONEncoder().encode(bookmarkedWordIDs) {
            UserDefaults.standard.set(encoded, forKey: bookmarksKey)
        }
    }
}
