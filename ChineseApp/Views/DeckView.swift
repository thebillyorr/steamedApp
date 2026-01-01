import SwiftUI

struct DeckView: View {
    let topic: Topic
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var bookmarkManager = BookmarkManager.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: []) {
                    // Add to Practice Queue Button (at top)
                    VStack(spacing: 12) {
                        Button(action: addToPracticeQueue) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Practice This Deck")
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(16)
                    
                    let words = DataService.loadWords(for: topic)
                    ForEach(words) { word in
                        HStack(spacing: 12) {
                            Text(word.hanzi)
                                .font(.title2)
                                .frame(width: 64)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(word.pinyin)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(word.english.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                            
                            // Bookmark Button
                            BookmarkButton(wordID: word.id)

                            // mastery indicator
                            let progress = progressStore.getProgress(for: word.hanzi)
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(progress >= 1.0 ? Color.green : Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                            }
                            .frame(width: 24, height: 24)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)

                        Divider()
                    }
                }
            }
        }
        .navigationTitle(topic.name)
    }
    
    private func isAllWordsMastered(topic: Topic) -> Bool {
        let words = DataService.loadWords(for: topic)
        return words.allSatisfy { progressStore.getProgress(for: $0.hanzi) >= 1.0 }
    }
    
    private func addToPracticeQueue() {
        // Post notification to set active deck and navigate
        NotificationCenter.default.post(name: NSNotification.Name("SetActiveDeckAndNavigate"), object: topic)
        dismiss()
    }
}

struct BookmarkButton: View {
    let wordID: String
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
            Image(systemName: bookmarkManager.isBookmarked(wordID: wordID) ? "star.fill" : "star")
                .foregroundColor(bookmarkManager.isBookmarked(wordID: wordID) ? .yellow : .gray)
                .font(.system(size: 20))
                .animation(nil, value: bookmarkManager.isBookmarked(wordID: wordID))
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Remove from Favorites?", isPresented: $showConfirmation) {
            Button("Remove", role: .destructive) {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    bookmarkManager.toggleBookmark(for: wordID)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove this word from your favorites?")
        }
    }
}

#Preview {
    DeckView(topic: Topic(name: "HSK 1 Part 1", filename: "hsk1_part1"))
}
