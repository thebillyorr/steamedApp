import SwiftUI

struct DeckView: View {
    let topic: Topic
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var bookmarkManager = BookmarkManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    DeckHeaderView(topic: topic, onPractice: addToPracticeQueue)
                    
                    // Word List
                    LazyVStack(spacing: 12) {
                        let words = DataService.loadWords(for: topic)
                        ForEach(words) { word in
                            WordCard(word: word)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle(topic.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addToPracticeQueue() {
        // Post notification to set active deck and navigate
        NotificationCenter.default.post(name: NSNotification.Name("SetActiveDeckAndNavigate"), object: topic)
        dismiss()
    }
}

struct DeckHeaderView: View {
    let topic: Topic
    let onPractice: () -> Void
    @ObservedObject private var progressStore = ProgressStore.shared
    
    var body: some View {
        let words = DataService.loadWords(for: topic)
        let totalWords = words.count
        let masteredCount = words.filter { progressStore.getProgress(for: $0.hanzi) >= 1.0 }.count
        let progress = totalWords > 0 ? Double(masteredCount) / Double(totalWords) : 0.0
        
        VStack(spacing: 20) {
            // Icon and Stats
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.steamedBlue.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    if topic.icon == "Logo" {
                        Image("Logo")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.steamedDarkBlue)
                    } else {
                        Image(systemName: topic.icon)
                            .font(.system(size: 36))
                            .foregroundColor(.steamedDarkBlue)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Deck Progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(masteredCount)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        Text("/ \(totalWords)")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.steamedBlue, .steamedDarkBlue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            
            // Practice Button
            Button(action: onPractice) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Practice Deck")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.steamedBlue, .steamedDarkBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.steamedDarkBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct WordCard: View {
    let word: Word
    @ObservedObject private var progressStore = ProgressStore.shared
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main Row (Always Visible)
            HStack(alignment: .center, spacing: 12) {
                // Hanzi
                Text(word.hanzi)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.primary)
                
                // Pinyin
                Text(word.pinyin)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.steamedDarkBlue)
                
                // Truncated English (Only visible when collapsed)
                if !isExpanded {
                    Text(word.english.joined(separator: ", "))
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Favorite Button (Replaces the old progress ring)
                BookmarkButton(wordID: word.id)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle()) // Make the whole row tappable
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }
            
            // Expanded Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                    
                    // Full English Definition
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DEFINITION")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text(word.english.joined(separator: ", "))
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Mastery Bar
                    let progress = progressStore.getProgress(for: word.hanzi)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("MASTERY")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(progress * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(progress >= 1.0 ? .orange : .steamedDarkBlue)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 8)
                                
                                Capsule()
                                    .fill(
                                        progress >= 1.0 ?
                                        LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing) :
                                        LinearGradient(colors: [.steamedBlue, .steamedDarkBlue], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .frame(width: geo.size.width * progress, height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.opacity)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
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
            Image(systemName: bookmarkManager.isBookmarked(wordID: wordID) ? "bookmark.fill" : "bookmark")
                .foregroundColor(bookmarkManager.isBookmarked(wordID: wordID) ? .steamedDarkBlue : .gray.opacity(0.5))
                .font(.system(size: 20))
                .animation(nil, value: bookmarkManager.isBookmarked(wordID: wordID))
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Remove from My Basket?", isPresented: $showConfirmation) {
            Button("Remove", role: .destructive) {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    bookmarkManager.toggleBookmark(for: wordID)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove this word from your basket?")
        }
    }
}

#Preview {
    DeckView(topic: Topic(name: "HSK 1 Part 1", filename: "hsk1_part1"))
}
