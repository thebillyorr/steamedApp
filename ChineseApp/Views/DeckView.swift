import SwiftUI

struct DeckView: View {
    let topic: Topic
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var deckMasteryManager = DeckMasteryManager.shared
    @State private var showFinalExam = false

    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: []) {
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

                            // mastery bar
                            let progress = progressStore.getProgress(for: word.hanzi)
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .tint(progress >= 1.0 ? .green : .accentColor)
                                .frame(width: 120, height: 6)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)

                        Divider()
                    }
                    
                    // Final Exam Button
                    VStack(spacing: 12) {
                        if deckMasteryManager.isDeckMastered(filename: topic.filename) {
                            // Deck is mastered - show locked state
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.green)
                                Text("Mastery Locked")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                        } else {
                            // Not mastered yet - show exam button
                            let allWordsMastered = isAllWordsMastered(topic: topic)
                            
                            Button(action: { showFinalExam = true }) {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text("Final Exam")
                                }
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(allWordsMastered ? Color.blue : Color.gray)
                                .cornerRadius(10)
                            }
                            .disabled(!allWordsMastered)
                            .opacity(allWordsMastered ? 1.0 : 0.6)
                            
                            if !allWordsMastered {
                                Text("Master all words to unlock final exam")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            
            // Navigation sheet
            .sheet(isPresented: $showFinalExam) {
                FinalExamView(topic: topic)
            }
        }
        .navigationTitle(topic.name)
    }
    
    private func isAllWordsMastered(topic: Topic) -> Bool {
        let words = DataService.loadWords(for: topic)
        return words.allSatisfy { progressStore.getProgress(for: $0.hanzi) >= 1.0 }
    }
}

#Preview {
    DeckView(topic: Topic(name: "HSK 1 Part 1", filename: "hsk1_part1"))
}
