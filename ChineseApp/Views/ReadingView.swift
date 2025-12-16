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
                                .foregroundColor(.green)
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
                    onSelectionChanged: { wordId in
                        selectedWordId = wordId
                        if let id = wordId {
                            selectedWord = StoryService.shared.getWord(wordId: id)
                        } else {
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
        VStack {
            HStack {
                // Tooltip first
                if let word = selectedWord {
                    HStack(spacing: 12) {
                        // Chinese character on left
                        Text(word.hanzi)
                            .font(.system(size: 22, weight: .bold))
                        
                        // English and Pinyin on right
                        VStack(alignment: .leading, spacing: 2) {
                            Text(word.english.joined(separator: ", "))
                                .font(.system(size: 12, weight: .semibold))
                                .lineLimit(1)
                            
                            Text(word.pinyin)
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        // Bookmark Button
                        BookmarkButton(wordID: word.id)
                            .padding(.leading, 8)
                    }
                }

                Spacer()

                // Center controls: font toggle + completed status styled cohesively
                HStack(spacing: 10) {
                    // Font size segmented control
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
                            // Outer pill
                            Capsule()
                                .fill(Color(.systemGray6))

                            // Selected half highlight
                            GeometryReader { geo in
                                let halfWidth = geo.size.width / 2

                                Capsule()
                                    .fill(Color.blue)
                                    .frame(
                                        width: halfWidth,
                                        alignment: .leading
                                    )
                                    .offset(x: fontSize == 26 ? 0 : halfWidth)
                            }
                        }
                    )
                    .clipShape(Capsule())
                    .overlay(
                        // Ensure text is readable over blue/gray background
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

                    // Completed pill
                    Button(action: onToggleCompleted) {
                        HStack(spacing: 6) {
                            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            Text(isCompleted ? "Completed" : "Mark Complete")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .frame(height: 32)
                        .background(isCompleted ? Color.green.opacity(0.15) : Color(.systemGray6))
                        .foregroundColor(isCompleted ? .green : .primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview

#Preview {
    ReadingView()
}
