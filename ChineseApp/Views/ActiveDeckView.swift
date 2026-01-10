//
//  ActiveDeckView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-22.
//

import SwiftUI

struct ActiveDeckView: View {
    let topic: Topic
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var deckMasteryManager = DeckMasteryManager.shared
    let onShowDeckSelection: () -> Void
    let onStartPractice: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        // PERF: Load words once per render instead of 6 times
        let words = DataService.loadWords(for: topic)
        let masteryValue = calculateDeckMastery(words: words)
        
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Main Practice Card
                    VStack(spacing: 32) {
                        // Header: Deck Info & Switch
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CURRENT DECK")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                    .tracking(1)
                                
                                Button(action: onShowDeckSelection) {
                                    HStack(spacing: 8) {
                                        Text(topic.name)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)
                                        
                                        Image(systemName: "chevron.down.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.steamedBlue)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Spacer()
                            
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(Color.steamedBlue.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                
                                if topic.icon == "Logo" {
                                    Image("Logo")
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(Color.steamedGradient)
                                } else {
                                    Image(systemName: topic.icon)
                                        .font(.system(size: 30))
                                        .foregroundStyle(Color.steamedGradient)
                                }
                            }
                        }
                        
                        // Progress Circle
                        // For My Basket (dynamic deck), only rely on current word status, not historical mastery
                        let isDeckMastered = (topic.filename == "bookmarks_deck" ? false : deckMasteryManager.isDeckMastered(filename: topic.filename)) || isAllWordsMastered(words: words)
                        
                        ZStack {
                            // Background circle
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 15)
                                .frame(width: 200, height: 200)
                            
                            // Progress ring
                            Circle()
                                .trim(from: 0, to: masteryValue / 100)
                                .stroke(
                                    isDeckMastered ? 
                                    LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                    Color.steamedGradient,
                                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 200, height: 200)
                                .animation(.easeInOut(duration: 0.6), value: masteryValue)
                            
                            // Inner content
                            VStack(spacing: 4) {
                                if isDeckMastered {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.orange)
                                        .padding(.bottom, 8)
                                    Text("Mastered")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("\(Int(masteryValue))%")
                                        .font(.system(size: 56, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text("Mastery")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 12)
                        
                        // Stats Grid
                        HStack(spacing: 16) {
                            DeckStatCard(
                                label: "Mastered",
                                value: "\(getMasteredWordCount(words: words))",
                                icon: "star.fill"
                            )
                            
                            DeckStatCard(
                                label: "Learning",
                                value: "\(getInProgressWordCount(words: words))",
                                icon: "book.fill"
                            )
                            
                            DeckStatCard(
                                label: "New",
                                value: "\(getNotStartedWordCount(words: words))",
                                icon: "sparkles"
                            )
                        }
                        
                        // Start Button
                        Button(action: onStartPractice) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Session")
                            }
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.steamedGradient)
                            .cornerRadius(20)
                            .shadow(color: Color.steamedDarkBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(24)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(32)
                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
        }
    }
    
    private func calculateDeckMastery(words: [Word]) -> Double {
        guard !words.isEmpty else { return 0 }
        
        let totalProgress = words.reduce(0) { total, word in
            total + progressStore.getProgress(for: word.hanzi)
        }
        
        let percentage = (totalProgress / Double(words.count)) * 100
        return min(percentage, 100)
    }
    
    // (getWordCount removed, unused)
    
    private func getMasteredWordCount(words: [Word]) -> Int {
        words.filter { 
            progressStore.getProgress(for: $0.hanzi) >= 1.0 
        }.count
    }
    
    private func getInProgressWordCount(words: [Word]) -> Int {
        words.filter { 
            let progress = progressStore.getProgress(for: $0.hanzi)
            return progress > 0 && progress < 1.0
        }.count
    }
    
    private func getNotStartedWordCount(words: [Word]) -> Int {
        words.filter { 
            progressStore.getProgress(for: $0.hanzi) == 0
        }.count
    }
    
    private func isAllWordsMastered(words: [Word]) -> Bool {
        guard !words.isEmpty else { return false }
        return words.allSatisfy { progressStore.getProgress(for: $0.hanzi) >= 1.0 }
    }
}

struct DeckStatCard: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.steamedGradient)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
    }
}

#Preview {
    ActiveDeckView(
        topic: DataService.allTopics[0],
        onShowDeckSelection: { },
        onStartPractice: { }
    )
}



