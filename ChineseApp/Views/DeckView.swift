import SwiftUI

struct DeckView: View {
    let topic: Topic
    @ObservedObject private var progressStore = ProgressStore.shared

    var body: some View {
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
            }
        }
        .navigationTitle(topic.name)
    }
}

#Preview {
    DeckView(topic: Topic(name: "HSK 1 Part 1", filename: "hsk1_part1"))
}
