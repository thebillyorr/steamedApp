import SwiftUI

struct BookmarkedDeckView: View {
    @ObservedObject private var bookmarkManager = BookmarkManager.shared
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var deckMasteryManager = DeckMasteryManager.shared
    
    // Create a virtual topic for the bookmarks with a stable ID
    let bookmarkTopic = Topic(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "My Bookmarks",
        filename: "bookmarks_deck",
        icon: "Logo"
    )
    
    var body: some View {
        let bookmarkedWords = DataService.loadWords(for: bookmarkTopic)
        let mastery = calculateMastery(words: bookmarkedWords)
        let wordCount = bookmarkedWords.count
        let masteredCount = bookmarkedWords.filter { progressStore.getProgress(for: $0.hanzi) >= 1.0 }.count
        
        NavigationLink(value: bookmarkTopic) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Bookmarks")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Your collection of saved words")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    // Logo Icon
                    Image("Logo")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("\(Int(mastery * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Mastery")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    VStack(alignment: .leading) {
                        Text("\(masteredCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Mastered")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Play button icon
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(Color.white)
                            .frame(width: geo.size.width * mastery, height: 6)
                    }
                }
                .frame(height: 6)
            }
            .padding(20)
            .background(
                Color.steamedGradient
            )
            .cornerRadius(20)
            .shadow(color: Color.steamedDarkBlue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
    
    private func calculateMastery(words: [Word]) -> Double {
        guard !words.isEmpty else { return 0.0 }
        let totalMastery = words.reduce(0.0) { sum, word in
            sum + progressStore.getProgress(for: word.hanzi)
        }
        return totalMastery / Double(words.count)
    }
}
