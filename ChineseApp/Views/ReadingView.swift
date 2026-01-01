import SwiftUI

struct ReadingView: View {
    @State private var library: StoryLibrary?
    @State private var selectedStory: Story?
    @State private var selectedWord: Word?
    @State private var fontSize: CGFloat = 26
    @ObservedObject private var storyProgress = StoryProgressManager.shared
    
    var body: some View {
        NavigationStack {
            if let selectedStory = selectedStory {
                StoryReaderView(
                    story: selectedStory,
                    selectedWord: $selectedWord,
                    fontSize: $fontSize
                )
                .navigationTitle(selectedStory.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.selectedStory = nil
                            selectedWord = nil
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Stories")
                            }
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    ReadingNavigationBar(
                        fontSize: $fontSize,
                        selectedWord: $selectedWord,
                        isCompleted: storyProgress.isCompleted(storyId: selectedStory.storyId),
                        onToggleCompleted: {
                            storyProgress.toggleCompletion(storyId: selectedStory.storyId)
                        }
                    )
                }
                .toolbar(.hidden, for: .tabBar)
            } else {
                StoryListView(selectedStory: $selectedStory, isReadingStory: .constant(false))
                    .navigationTitle("Library")
                    .navigationBarTitleDisplayMode(.large)
            }
        }
        .onAppear {
            library = StoryService.shared.loadLibrary()
        }
    }
}

// MARK: - Story List View

struct StoryListView: View {
    @Binding var selectedStory: Story?
    @Binding var isReadingStory: Bool
    @State private var library: StoryLibrary?
    @ObservedObject private var storyProgress = StoryProgressManager.shared
    @State private var expandedDifficulties: Set<Int> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let library = library, !library.stories.isEmpty {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 12) {
                        // Group stories by difficulty (level)
                        let grouped = Dictionary(grouping: library.stories) { $0.difficulty }
                        let sortedKeys = grouped.keys.sorted()

                        ForEach(sortedKeys, id: \ .self) { level in
                            let storiesForLevel = grouped[level] ?? []

                            // Section header with expand/collapse toggle
                            Button {
                                if expandedDifficulties.contains(level) {
                                    expandedDifficulties.remove(level)
                                } else {
                                    expandedDifficulties.insert(level)
                                }
                            } label: {
                                HStack {
                                    Text("Level \(level)")
                                        .font(.system(size: 18, weight: .semibold))
                                    Spacer()
                                    Image(systemName: expandedDifficulties.contains(level) ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 4)
                            }
                            .buttonStyle(.plain)

                            if expandedDifficulties.contains(level) {
                                VStack(spacing: 12) {
                                    ForEach(storiesForLevel) { metadata in
                                        StoryCardView(
                                            metadata: metadata,
                                            isCompleted: storyProgress.isCompleted(storyId: metadata.storyId)
                                        ) {
                                            if let story = StoryService.shared.loadStory(storyId: metadata.storyId) {
                                                selectedStory = story
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            } else {
                VStack(alignment: .center, spacing: 8) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No stories available yet")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            library = StoryService.shared.loadLibrary()
            if let stories = library?.stories {
                // Expand all existing difficulty levels by default
                let levels = Set(stories.map { $0.difficulty })
                expandedDifficulties = levels
            }
        }
    }
}

// MARK: - Story Card View

struct StoryCardView: View {
    let metadata: StoryMetadata
    let isCompleted: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    // Title + subtitle on the left
                    VStack(alignment: .leading, spacing: 3) {
                        Text(metadata.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(2)

                        if let subtitle = metadata.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }

                    Spacer()

                    // Level indicator with star/lock anchored near the bottom-right
                    VStack(alignment: .trailing, spacing: 4) {
                        Label("Level \(metadata.difficulty)", systemImage: "chart.bar.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        Spacer(minLength: 4)

                        if isCompleted {
                            Image(systemName: "star.fill")
                                .foregroundColor(.steamedDarkBlue)
                        } else if metadata.locked {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    .frame(minHeight: 40, alignment: .bottomTrailing)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Story Reader View

struct StoryReaderView: View {
    let story: Story
    @Binding var selectedWord: Word?
    @Binding var fontSize: CGFloat
    // Keep track of the currently selected wordId for highlighting
    @State private var selectedWordId: String?
    @ObservedObject private var storyProgress = StoryProgressManager.shared
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 16) {
                // Simple text view that lays out like a book page
                StoryTextViewRepresentable(
                    tokens: story.tokens,
                    fontSize: fontSize,
                    selectedWordId: selectedWordId,
                    onSelectionChanged: { wordId, tokenIndex in
                        selectedWordId = wordId
                        if let id = wordId {
                            var word = StoryService.shared.getWord(wordId: id)
                            
                            // Special handling for Character Name (w05005)
                            // If the token is a character name placeholder, use the actual token text as the hanzi
                            if id == "w05005", let index = tokenIndex, index < story.tokens.count {
                                let tokenText = story.tokens[index].text
                                if let originalWord = word {
                                    word = Word(
                                        hanzi: tokenText,
                                        pinyin: originalWord.pinyin,
                                        english: originalWord.english,
                                        difficulty: originalWord.difficulty,
                                        customId: id
                                    )
                                }
                            }
                            
                            selectedWord = word
                        } else if selectedWord != nil {
                            selectedWord = nil
                        }
                    }
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, fontSize >= 34 ? 8 : 16)

                Spacer(minLength: 0)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

// MARK: - Reading Navigation Bar

struct ReadingNavigationBar: View {
    @Binding var fontSize: CGFloat
    @Binding var selectedWord: Word?
    let isCompleted: Bool
    let onToggleCompleted: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Tooltip Section (Only visible when word selected)
            if let word = selectedWord {
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 16) {
                        // Chinese character
                        Text(word.hanzi)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            // Pinyin
                            Text(word.pinyin)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            // English Definitions (Allowed to wrap)
                            Text(word.english.joined(separator: ", "))
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                        }
                        
                        Spacer()
                        
                        // Bookmark Button
                        BookmarkButton(wordID: word.id)
                    }
                    .padding(16)
                    
                    Divider()
                }
                .background(Color(.systemBackground))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Controls Section (Always visible)
            HStack {
                // Font Size Controls
                HStack(spacing: 0) {
                    Button {
                        fontSize = 26
                    } label: {
                        Text("A-")
                            .font(.system(size: 13, weight: .semibold))
                            .frame(width: 40, height: 32)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        fontSize = 40
                    } label: {
                        Text("A+")
                            .font(.system(size: 19, weight: .semibold))
                            .frame(width: 40, height: 32)
                    }
                    .buttonStyle(.plain)
                }
                .foregroundColor(.primary)
                .background(
                    ZStack {
                        Capsule().fill(Color(.systemGray6))
                        GeometryReader { geo in
                            let halfWidth = geo.size.width / 2
                            Capsule()
                                .fill(Color.blue)
                                .frame(width: halfWidth, alignment: .leading)
                                .offset(x: fontSize == 26 ? 0 : halfWidth)
                        }
                    }
                )
                .clipShape(Capsule())
                .overlay(
                    HStack(spacing: 0) {
                        Text("A-")
                            .font(.system(size: 13, weight: .semibold))
                            .frame(width: 40, height: 32)
                            .foregroundColor(fontSize == 26 ? .white : .primary)
                        Text("A+")
                            .font(.system(size: 19, weight: .semibold))
                            .frame(width: 40, height: 32)
                            .foregroundColor(fontSize == 40 ? .white : .primary)
                    }
                    .allowsHitTesting(false)
                )
                .frame(height: 32)
                
                Spacer()
                
                // Mark Complete Button
                Button(action: onToggleCompleted) {
                    HStack(spacing: 6) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        Text(isCompleted ? "Completed" : "Mark Complete")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isCompleted ? Color.steamedBlue.opacity(0.3) : Color(.systemGray6))
                    .foregroundColor(isCompleted ? .steamedDarkBlue : .primary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(Color(.systemBackground))
        }
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -4)
    }
}

// MARK: - Preview

#Preview {
    ReadingView()
}
