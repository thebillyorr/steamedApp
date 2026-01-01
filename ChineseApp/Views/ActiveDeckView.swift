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
        VStack(spacing: 16) {
            // Header
            Text("Active Deck")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
            
            // Tappable tall card deck
            Button(action: onStartPractice) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(minHeight: 12)
                    
                    // Deck title (centered)
                    Text(topic.name)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                        .transition(.opacity)
                    
                    Spacer()
                        .frame(minHeight: 24)
                    
                    // Mastery ring (centered)
                    let masteryValue = calculateDeckMastery()
                    let isDeckMastered = deckMasteryManager.isDeckMastered(filename: topic.filename) || isAllWordsMastered()
                    
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color(.systemGray6), lineWidth: 10)
                        
                        // Progress ring
                        Circle()
                            .trim(from: 0, to: masteryValue / 100)
                            .stroke(
                                Color.steamedGradient,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.6), value: masteryValue)
                        
                        // Inner content
                        VStack(spacing: 8) {
                            if isDeckMastered {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.steamedDarkBlue)
                                Text("Mastered")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.steamedDarkBlue)
                            } else {
                                Text("\(Int(masteryValue))%")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Mastery")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: 140)
                    
                    Spacer()
                        .frame(minHeight: 24)
                    
                    // Stats grid (3 columns, centered)
                    HStack(spacing: 12) {
                        DeckStatCard(
                            label: "Mastered",
                            value: "\(getMasteredWordCount())",
                            icon: "checkmark.circle.fill",
                            color: .steamedDarkBlue
                        )
                        .transition(.opacity)
                        .id("mastered-\(topic.id)")
                        
                        DeckStatCard(
                            label: "In Progress",
                            value: "\(getInProgressWordCount())",
                            icon: "circle.dashed",
                            color: .orange
                        )
                        .transition(.opacity)
                        .id("inprogress-\(topic.id)")
                        
                        DeckStatCard(
                            label: "Not Started",
                            value: "\(getNotStartedWordCount())",
                            icon: "circle",
                            color: .gray
                        )
                        .transition(.opacity)
                        .id("notstarted-\(topic.id)")
                    }
                    .id("stats-\(topic.id)")
                    
                    Spacer()
                        .frame(minHeight: 12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .foregroundColor(.primary)
            }
            .frame(height: 480)
            .padding(.horizontal, 24)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .offset(y: isHovered ? -8 : 0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            // Card deck shadows (layered effect)
            .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 12)
            .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 20)
            .onHover { hovering in
                isHovered = hovering
            }
            
            // Change deck option (below card)
            Button(action: onShowDeckSelection) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 12))
                    Text("Tap to change deck")
                        .font(.caption)
                }
                .foregroundColor(.blue)
                .opacity(0.7)
            }
            
            Spacer()
        }
        .padding(.vertical, 24)
    }
    
    private func calculateDeckMastery() -> Double {
        let words = DataService.loadWords(for: topic)
        guard !words.isEmpty else { return 0 }
        
        let totalProgress = words.reduce(0) { total, word in
            total + progressStore.getProgress(for: word.hanzi)
        }
        
        let percentage = (totalProgress / Double(words.count)) * 100
        return min(percentage, 100)
    }
    
    private func getWordCount() -> Int {
        DataService.loadWords(for: topic).count
    }
    
    private func getMasteredWordCount() -> Int {
        DataService.loadWords(for: topic).filter { 
            progressStore.getProgress(for: $0.hanzi) >= 1.0 
        }.count
    }
    
    private func getInProgressWordCount() -> Int {
        DataService.loadWords(for: topic).filter { 
            let progress = progressStore.getProgress(for: $0.hanzi)
            return progress > 0 && progress < 1.0
        }.count
    }
    
    private func getNotStartedWordCount() -> Int {
        DataService.loadWords(for: topic).filter { 
            progressStore.getProgress(for: $0.hanzi) == 0
        }.count
    }
    
    private func isAllWordsMastered() -> Bool {
        let words = DataService.loadWords(for: topic)
        guard !words.isEmpty else { return false }
        return words.allSatisfy { progressStore.getProgress(for: $0.hanzi) >= 1.0 }
    }
}

struct DeckStatCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ActiveDeckView(
        topic: DataService.allTopics[0],
        onShowDeckSelection: { },
        onStartPractice: { }
    )
}



