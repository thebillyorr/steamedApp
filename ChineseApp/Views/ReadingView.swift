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
    @State private var selectedTab: Int = 0 // 0: Library, 1: Bookshelf
    
    // Alert State
    @State private var showUncompleteAlert = false
    @State private var storyIdToUncomplete: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Control
            Picker("View", selection: $selectedTab) {
                Text("Library").tag(0)
                Text("Bookshelf").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color(.systemBackground))
            
            if let library = library, !library.stories.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Filter stories based on tab
                        let filteredStories = library.stories.filter { story in
                            let isCompleted = storyProgress.isCompleted(storyId: story.storyId)
                            return selectedTab == 0 ? !isCompleted : isCompleted
                        }
                        
                        if filteredStories.isEmpty {
                            EmptyStateView(tab: selectedTab)
                        } else {
                            // Group by difficulty
                            let grouped = Dictionary(grouping: filteredStories) { $0.difficulty }
                            let sortedKeys = grouped.keys.sorted()
                            
                            ForEach(sortedKeys, id: \.self) { level in
                                SectionHeader(level: level)
                                
                                ForEach(grouped[level] ?? []) { metadata in
                                    StoryCardView(
                                        metadata: metadata,
                                        isCompleted: storyProgress.isCompleted(storyId: metadata.storyId),
                                        onToggleCompletion: {
                                            let isCompleted = storyProgress.isCompleted(storyId: metadata.storyId)
                                            if isCompleted {
                                                // If currently completed, show confirmation before uncompleting
                                                storyIdToUncomplete = metadata.storyId
                                                showUncompleteAlert = true
                                            } else {
                                                // If not completed, just complete it immediately
                                                withAnimation {
                                                    storyProgress.toggleCompletion(storyId: metadata.storyId)
                                                }
                                            }
                                        },
                                        onTap: {
                                            if let story = StoryService.shared.loadStory(storyId: metadata.storyId) {
                                                selectedStory = story
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 80) // Extra padding for bottom tab bar
                }
                .background(Color(.systemGroupedBackground))
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            library = StoryService.shared.loadLibrary()
        }
        .alert("Remove from Bookshelf?", isPresented: $showUncompleteAlert) {
            Button("Remove", role: .destructive) {
                if let id = storyIdToUncomplete {
                    withAnimation {
                        storyProgress.toggleCompletion(storyId: id)
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                storyIdToUncomplete = nil
            }
        } message: {
            Text("This story will be moved back to your Library as unread.")
        }
    }
}

// MARK: - Helper Views

struct SectionHeader: View {
    let level: Int
    var body: some View {
        HStack {
            Text("HSK Level \(level)")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

struct EmptyStateView: View {
    let tab: Int
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: tab == 0 ? "checkmark.circle" : "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(tab == 0 ? "All Caught Up!" : "Your Bookshelf is Empty")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(tab == 0 ? "Check your bookshelf for completed stories." : "Finish a story to see it here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Story Card View

struct StoryCardView: View {
    let metadata: StoryMetadata
    let isCompleted: Bool
    let onToggleCompletion: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 16) {
                // Left: Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(metadata.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let subtitle = metadata.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    // HSK Badge
                    Text("HSK \(metadata.difficulty)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.steamedDarkBlue)
                        )
                }
                
                Spacer()
                
                // Right: Action Button (Mark Read/Unread)
                Button(action: onToggleCompletion) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 28))
                        .foregroundColor(isCompleted ? .green : .gray.opacity(0.3))
                        .contentShape(Circle()) // Ensure tap target is solid
                }
                .buttonStyle(PlainButtonStyle()) // Important to not trigger the parent button
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground)) // Better for dark mode
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
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
