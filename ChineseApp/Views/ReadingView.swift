import SwiftUI

struct ReadingView: View {
    @State private var library: StoryLibrary?
    @State private var selectedStory: Story?
    @State private var selectedWord: Word?
    @AppStorage("readingFontSize") private var fontSize: Double = 26.0
    
    // Persistent Filter State (Hoisted from StoryListView)
    @State private var searchText = ""
    @State private var selectedFilters: Set<String> = []
    
    @State private var showReportOverlay = false
    
    @ObservedObject private var storyProgress = StoryProgressManager.shared
    
    var body: some View {
        NavigationStack {
            if let selectedStory = selectedStory {
                StoryReaderView(
                    story: selectedStory,
                    selectedWord: $selectedWord,
                    fontSize: Binding(get: { CGFloat(fontSize) }, set: { fontSize = Double($0) })
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
                        fontSize: Binding(get: { CGFloat(fontSize) }, set: { fontSize = Double($0) }),
                        selectedWord: $selectedWord,
                        isCompleted: storyProgress.isCompleted(storyId: selectedStory.storyId),
                        onToggleCompleted: {
                            storyProgress.toggleCompletion(storyId: selectedStory.storyId)
                        },
                        onReport: {
                            showReportOverlay = true
                        }
                    )
                }
                .overlay {
                    if showReportOverlay {
                        ReportIssueOverlay(onClose: { showReportOverlay = false })
                    }
                }
                .toolbar(.hidden, for: .tabBar)
            } else {
                StoryListView(
                    selectedStory: $selectedStory,
                    isReadingStory: .constant(false),
                    searchText: $searchText,
                    selectedFilters: $selectedFilters
                )
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
    
    // Search & Filter State Binding
    @Binding var searchText: String
    @Binding var selectedFilters: Set<String>
    
    @State private var library: StoryLibrary?
    @ObservedObject private var storyProgress = StoryProgressManager.shared
    
    // Alert State
    @State private var showUncompleteAlert = false
    @State private var storyIdToUncomplete: String?
    
    // Static allowed topics and HSK levels
    static let hskFilters = ["HSK 3", "HSK 4", "HSK 5", "HSK 6"]
    static let topicFilters = ["New Arrivals", "Fable", "Informational", "Story"]
    static let filters: [String] = ["Completed"] + hskFilters + topicFilters
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar Area
            VStack(spacing: 12) {
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search title, English...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                
                // Filter Chips with Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // "All" Chip (Special logic: active if set is empty)
                        FilterChip(title: "All", isSelected: selectedFilters.isEmpty) {
                            withAnimation {
                                selectedFilters.removeAll()
                            }
                        }
                        
                        // Completion Status
                        FilterChip(title: "Completed", isSelected: selectedFilters.contains("Completed")) {
                            withAnimation {
                                if selectedFilters.contains("Completed") {
                                    selectedFilters.remove("Completed")
                                } else {
                                    selectedFilters.insert("Completed")
                                }
                            }
                        }
                        
                        Divider()
                            .frame(height: 20)
                            .padding(.horizontal, 4)
                        
                        // HSK Levels
                        ForEach(Self.hskFilters, id: \.self) { filter in
                            FilterChip(title: filter, isSelected: selectedFilters.contains(filter)) {
                                withAnimation {
                                    if selectedFilters.contains(filter) {
                                        selectedFilters.remove(filter)
                                    } else {
                                        selectedFilters.insert(filter)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                            .frame(height: 20)
                            .padding(.horizontal, 4)
                        
                        // Topics
                        ForEach(Self.topicFilters, id: \.self) { filter in
                            FilterChip(title: filter, isSelected: selectedFilters.contains(filter)) {
                                withAnimation {
                                    if selectedFilters.contains(filter) {
                                        selectedFilters.remove(filter)
                                    } else {
                                        selectedFilters.insert(filter)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 8)
            }
            .padding(.top, 8)
            .background(Color(.systemBackground))
            
            // Content
            if let library = library, !library.stories.isEmpty {
                ScrollView {
                    if isSearchingOrFiltering {
                        // Search Results List (Clean Vertical List)
                        LazyVStack(spacing: 12) {
                            let results = filterStories(library.stories).sorted { a, b in
                                // 1. Completion Status (Uncompleted first)
                                let aComp = storyProgress.isCompleted(storyId: a.storyId)
                                let bComp = storyProgress.isCompleted(storyId: b.storyId)
                                if aComp != bComp {
                                    return !aComp && bComp
                                }
                                
                                // 2. HSK Level (Ascending) e.g., HSK 3 before HSK 4
                                if a.difficulty != b.difficulty {
                                    return a.difficulty < b.difficulty
                                }
                                
                                // 3. ID (Ascending) - Fallback
                                return a.storyId < b.storyId
                            }
                            
                            if results.isEmpty {
                                ContentUnavailableView.search
                                    .padding(.top, 40)
                            } else {
                                ForEach(results) { story in
                                    Button {
                                        loadAndSelectStory(metadata: story)
                                    } label: {
                                        DetailedStoryRow(
                                            story: story,
                                            isCompleted: storyProgress.isCompleted(storyId: story.storyId)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(16)
                    } else {
                        // Swimlanes (Explore Mode)
                        VStack(spacing: 32) {
                            // 1. New Arrivals (Stories tagged with "New Arrivals")
                            let newArrivals = library.stories.filter { story in
                                story.topic.contains("New Arrivals")
                            }.sorted { a, b in
                                let aComp = storyProgress.isCompleted(storyId: a.storyId)
                                let bComp = storyProgress.isCompleted(storyId: b.storyId)
                                if aComp == bComp {
                                    return a.storyId > b.storyId
                                }
                                return !aComp && bComp
                            }
                            
                            if !newArrivals.isEmpty {
                                StorySwimlaneSection(
                                    title: "New Arrivals",
                                    stories: newArrivals,
                                    storyProgress: storyProgress
                                ) { story in
                                    loadAndSelectStory(metadata: story)
                                }
                            }
                            
                            // 2. HSK Levels
                            buildSwimlane(for: "HSK 3 Stories", level: 3, allStories: library.stories)
                            buildSwimlane(for: "HSK 4 Stories", level: 4, allStories: library.stories)
                            buildSwimlane(for: "HSK 5 Stories", level: 5, allStories: library.stories)
                            buildSwimlane(for: "HSK 6 Stories", level: 6, allStories: library.stories)
                            
                        }
                        .padding(.vertical, 16)
                    }
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
    }
    
    // MARK: - Logic Helpers
    
    private var isSearchingOrFiltering: Bool {
        !searchText.isEmpty || !selectedFilters.isEmpty
    }
    
    private func filterStories(_ stories: [StoryMetadata]) -> [StoryMetadata] {
        stories.filter { story in
            // 1. Check Filter Chips (Multi-select OR logic for levels, AND logic for Completed)
            var matchesFilter = true
            if !selectedFilters.isEmpty {
                // Separate levels, status, and topics
                let levelFilters = selectedFilters.filter { $0.hasPrefix("HSK") }
                let statusFilters = selectedFilters.filter { $0 == "Completed" }
                let topicFilters = selectedFilters.filter { Self.topicFilters.contains($0) }

                // If any levels selected, story must match at least one (OR logic)
                if !levelFilters.isEmpty {
                    let matchesLevel = levelFilters.contains { filter in
                        switch filter {
                        case "HSK 3": return story.difficulty == 3
                        case "HSK 4": return story.difficulty == 4
                        case "HSK 5": return story.difficulty == 5
                        case "HSK 6": return story.difficulty == 6
                        default: return false
                        }
                    }
                    if !matchesLevel { matchesFilter = false }
                }

                // If any topic selected, story must match at least one (OR logic)
                if matchesFilter && !topicFilters.isEmpty {
                    let matchesTopic = story.topic.contains { storyTopic in
                        topicFilters.contains(storyTopic)
                    }
                    if !matchesTopic {
                        matchesFilter = false
                    }
                }

                // If "Completed" is selected, story MUST be completed (AND logic)
                if matchesFilter && !statusFilters.isEmpty {
                    if !storyProgress.isCompleted(storyId: story.storyId) {
                        matchesFilter = false
                    }
                }
            }
            
            // 2. Check Search Text
            let matchesSearch: Bool
            if searchText.isEmpty {
                matchesSearch = true
            } else {
                let query = searchText.lowercased()
                let titleMatch = story.title.lowercased().contains(query)
                let subtitleMatch = story.subtitle?.lowercased().contains(query) ?? false
                matchesSearch = titleMatch || subtitleMatch
            }
            
            return matchesFilter && matchesSearch
        }
    }
    
    @ViewBuilder
    private func buildSwimlane(for title: String, level: Int, allStories: [StoryMetadata]) -> some View {
        let stories = allStories.filter {
            return $0.difficulty == level
        }.sorted { a, b in
            let aComp = storyProgress.isCompleted(storyId: a.storyId)
            let bComp = storyProgress.isCompleted(storyId: b.storyId)
            if aComp == bComp {
                // If completion status is same, sort by date/ID (using storyId as proxy for added date if formatted s001, s002)
                return a.storyId > b.storyId
            }
            return !aComp && bComp
        }
        
        if !stories.isEmpty {
            StorySwimlaneSection(
                title: title,
                stories: stories,
                storyProgress: storyProgress
            ) { story in
                loadAndSelectStory(metadata: story)
            }
        }
    }
    
    private func loadAndSelectStory(metadata: StoryMetadata) {
        if let fullStory = StoryService.shared.loadStory(storyId: metadata.storyId) {
            self.selectedStory = fullStory
            self.isReadingStory = true
        }
    }
}

// MARK: - Filter Chip Component

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.steamedDarkBlue : Color(.systemGray5))
                .cornerRadius(20)
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
                                .fill(Color.steamedGradient)
                        )
                }
                
                Spacer()
                
                // Right: Action Button (Mark Read/Unread)
                Button(action: onToggleCompletion) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 28))
                        .foregroundStyle(isCompleted ? AnyShapeStyle(Color.steamedGradient) : AnyShapeStyle(Color.gray.opacity(0.3)))
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
                // Story Header
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(story.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    // Subtitle
                    if let subtitle = story.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Tags Row
                    HStack(spacing: 8) {
                        // HSK Badge
                        Text("HSK \(story.difficulty)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(getBadgeColor(level: story.difficulty))
                            .clipShape(Capsule())
                        
                        // Topic Tags
                        ForEach(story.topic, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, fontSize >= 34 ? 8 : 16)
                .padding(.top, 8)
                .padding(.bottom, 4)
                
                // Divider
                Divider()
                    .padding(.horizontal, fontSize >= 34 ? 8 : 16)
                
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
    
    private func getBadgeColor(level: Int) -> Color {
        switch level {
        case 1, 2: return .green
        case 3: return .blue
        case 4: return .orange
        case 5, 6: return .red
        default: return .gray
        }
    }
}

// MARK: - Reading Navigation Bar

struct ReadingNavigationBar: View {
    @Binding var fontSize: CGFloat
    @Binding var selectedWord: Word?
    let isCompleted: Bool
    let onToggleCompleted: () -> Void
    let onReport: () -> Void
    
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
                            .frame(minWidth: 60, minHeight: 60)
                            .padding(.horizontal, 8)
                            .background(Color.steamedBlue.opacity(0.15))
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            // Pinyin
                            Text(word.pinyin)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.steamedDarkBlue)
                            
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
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Controls Section (Always visible)
            HStack(spacing: 20) {
                // Font Size Controls
                HStack(spacing: 0) {
                    Button {
                        withAnimation { fontSize = 26 }
                    } label: {
                        Text("A")
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 44, height: 36)
                            .foregroundColor(fontSize < 34 ? .white : .primary)
                            .background(fontSize < 34 ? Color.steamedDarkBlue : Color.clear)
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                        .frame(height: 20)
                    
                    Button {
                        withAnimation { fontSize = 40 }
                    } label: {
                        Text("A")
                            .font(.system(size: 22, weight: .bold))
                            .frame(width: 44, height: 36)
                            .foregroundColor(fontSize >= 34 ? .white : .primary)
                            .background(fontSize >= 34 ? Color.steamedDarkBlue : Color.clear)
                    }
                    .buttonStyle(.plain)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
                
                Spacer()
                
                // Report Issue Button
                Button(action: onReport) {
                    Image(systemName: "flag")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                        .overlay(
                             Circle()
                                 .stroke(Color(.separator), lineWidth: 0.5)
                         )
                }
                
                // Mark Complete Button
                Button(action: {
                    // Disable animation for this state change
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        onToggleCompleted()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18))
                        Text("Complete")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 36)
                    .foregroundColor(isCompleted ? .white : .primary)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(Color.clear) // Transparent background when not completed (adapts to theme)
                            Capsule()
                                .fill(Color.steamedGoldGradient)
                                .opacity(isCompleted ? 1 : 0)
                        }
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color(.separator), lineWidth: isCompleted ? 0 : 0.5)
                    )
                }
                .buttonStyle(.plain)
                .animation(nil, value: isCompleted)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.separator))
                    .opacity(0.5),
                alignment: .top
            )
        }
    }
}

// MARK: - Preview

#Preview {
    ReadingView()
}
