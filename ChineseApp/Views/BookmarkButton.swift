//
//  BookmarkButton.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-22.
//

import SwiftUI

struct BookmarkButton: View {
    let wordID: String
    var size: CGFloat = 20
    @ObservedObject private var bookmarkManager = BookmarkManager.shared
    @State private var showConfirmation = false
    
    var body: some View {
        Button(action: {
            if bookmarkManager.isBookmarked(wordID: wordID) {
                showConfirmation = true
            } else {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    bookmarkManager.toggleBookmark(for: wordID)
                }
            }
        }) {
            Image(systemName: bookmarkManager.isBookmarked(wordID: wordID) ? "bookmark.fill" : "bookmark")
                .foregroundColor(bookmarkManager.isBookmarked(wordID: wordID) ? .steamedDarkBlue : .gray.opacity(0.5))
                .font(.system(size: size))
                .animation(nil, value: bookmarkManager.isBookmarked(wordID: wordID))
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Remove from My Bookmarks?", isPresented: $showConfirmation) {
            Button("Remove", role: .destructive) {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    bookmarkManager.toggleBookmark(for: wordID)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove this word from your bookmarks?")
        }
    }
}
