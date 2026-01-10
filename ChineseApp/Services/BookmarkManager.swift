import Foundation
import Combine
import SwiftData

final class BookmarkManager: ObservableObject {
    static let shared = BookmarkManager()
    
    @Published private(set) var bookmarkedWordIDs: Set<String> = []
    
    private var container: ModelContainer?
    
    // Allow setting container (called from App init)
    func setContainer(_ container: ModelContainer) {
        self.container = container
        Task { @MainActor in
            loadBookmarks()
        }
    }
    
    private init() {
        // Initial empty state until container is set
    }
    
    func isBookmarked(wordID: String) -> Bool {
        return bookmarkedWordIDs.contains(wordID)
    }
    
    @MainActor
    func toggleBookmark(for wordID: String) {
        guard let container = container else { return }
        let context = container.mainContext
        
        // 1. Update In-Memory Cache (for instant UI feedback)
        if bookmarkedWordIDs.contains(wordID) {
            bookmarkedWordIDs.remove(wordID)
        } else {
            bookmarkedWordIDs.insert(wordID)
        }
        
        // 2. Update Database
        do {
            let descriptor = FetchDescriptor<WordProgress>(predicate: #Predicate { $0.hanzi == wordID })
            let results = try context.fetch(descriptor)
            
            if let existing = results.first {
                existing.isBookmarked = bookmarkedWordIDs.contains(wordID)
            } else {
                // If bookmarking a word not yet practiced, create simple entry
                let newEntry = WordProgress(
                    hanzi: wordID,
                    mastery: 0.0,
                    isBookmarked: true
                )
                context.insert(newEntry)
            }
            try context.save()
        } catch {
            print("❌ Failed to toggle bookmark in DB: \(error)")
        }
    }
    
    @MainActor
    private func loadBookmarks() {
        guard let container = container else { return }
        let context = container.mainContext
        
        do {
            let descriptor = FetchDescriptor<WordProgress>(predicate: #Predicate { $0.isBookmarked == true })
            let results = try context.fetch(descriptor)
            self.bookmarkedWordIDs = Set(results.map { $0.hanzi })
        } catch {
            print("❌ Failed to load bookmarks: \(error)")
        }
    }
}
