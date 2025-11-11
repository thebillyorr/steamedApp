//
//  PracticeSessionView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-07.
//

import SwiftUI

struct PracticeSessionView: View {
    let topic: Topic
    @State private var words: [Word] = []
    @State private var currentIndex: Int = 0
    @State private var seenCounts: [String: Int] = [:] // hanzi -> times seen this session
    @State private var showAnswer = false

    // session items: word index + question type determined by journey
    private struct SessionItem: Identifiable {
        let id = UUID()
        let wordIndex: Int
        let questionType: QuestionType
    }
    @State private var sessionItems: [SessionItem] = []
    @State private var showSummary = false
    @State private var sessionMastered: [String] = []
    @State private var showExitConfirm = false
    @State private var journey: MasteryJourney = DataService.loadMasteryJourney()
    @Environment(\.dismiss) private var dismiss

    // fixed session length
    private let fixedSessionLength: Int = 15
    private let maxRepetitionsPerWord: Int = 3

    // computed current question type (safe if sessionItems empty)
    private var currentQuestionType: QuestionType {
        guard !sessionItems.isEmpty, currentIndex < sessionItems.count else { return .flashcard }
        return sessionItems[currentIndex].questionType
    }
    
    private var isQuiz: Bool {
        return currentQuestionType == .multipleChoice
    }

    var body: some View {
        VStack {
            if showSummary {
                // --- Summary screen ---
                VStack(spacing: 20) {
                    Text("🎉 Session Complete 🎉")
                        .font(.title2)
                        .padding(.top, 40)
                    // fixed-length session (15 questions)

                    if sessionMastered.isEmpty {
                        Text("No words were mastered during this session.")
                            .foregroundColor(.secondary)
                            .padding(.bottom, 12)
                    } else {
                        Text("Words mastered:")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(sessionMastered, id: \.self) { hanzi in
                                if let w = words.first(where: { $0.hanzi == hanzi }) {
                                    HStack {
                                        Text(w.hanzi)
                                            .font(.title3)
                                        VStack(alignment: .leading) {
                                            Text(w.pinyin)
                                                .foregroundColor(.secondary)
                                                .font(.subheadline)
                                            Text(w.english.joined(separator: ", "))
                                                .foregroundColor(.secondary)
                                                .font(.subheadline)
                                        }
                                    }
                                } else {
                                    Text(hanzi)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    Button("Done") {
                        // dismiss back to PracticeRootView
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                // --- Main practice session ---
                VStack(spacing: 20) {
                    // inline top bar with explicit back chevron (shown because this view is presented full-screen)
                    HStack {
                        Button {
                            showExitConfirm = true
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                    .padding(.horizontal)
                    if words.isEmpty {
                        Text("Loading...")
                    } else {
                        Text(topic.name)
                            .font(.headline)

                        // Progress bar for the fixed session (15 items)
                        if !sessionItems.isEmpty {
                            ProgressView(value: Double(currentIndex), total: Double(sessionItems.count))
                                .progressViewStyle(LinearProgressViewStyle())
                                .tint(Color.accentColor)
                                .frame(width: 320, height: 8)
                                .padding(.vertical, 8)
                        } else {
                            // session still preparing
                            Text("Preparing session...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        if !sessionItems.isEmpty {
                            if isQuiz {
                                quizView
                            } else {
                                flashcardView
                            }

                            if !isQuiz {
                                HStack(spacing: 16) {
                                    Button("Need to review") {
                                        advanceWord(correct: false)
                                    }
                                    .buttonStyle(.bordered)
                                    .padding(.horizontal, 6)

                                    Button("Got it") {
                                        advanceWord(correct: true)
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                .transition(.opacity)
                                .padding(.top, 6)
                            }
                        }
                    }
                }
                .padding()
                .onAppear {
                    words = DataService.loadWords(for: topic)
                    journey = DataService.loadMasteryJourney()
                    currentIndex = 0
                    seenCounts.removeAll()
                    sessionItems.removeAll()
                    
                    guard !words.isEmpty else { return }

                    // Get unlocked word indices based on session count
                    let unlockedIndices = DataService.getUnlockedWordIndices(for: topic.filename, totalWords: words.count)
                    
                    if unlockedIndices.isEmpty {
                        // No words unlocked yet (shouldn't happen with first 5 always available)
                        showSummary = true
                        return
                    }

                    // Randomly select words from unlocked pool (with repetition cap)
                    var selectedIndices: [Int] = []
                    var repetitionCount: [Int: Int] = [:]
                    
                    while selectedIndices.count < fixedSessionLength {
                        // Pick a random unlocked word
                        let randomIndex = unlockedIndices.randomElement()!
                        let repsForThisWord = repetitionCount[randomIndex, default: 0]
                        
                        // Check if we can add this word (hasn't hit max repetitions)
                        if repsForThisWord < maxRepetitionsPerWord {
                            selectedIndices.append(randomIndex)
                            repetitionCount[randomIndex, default: 0] += 1
                        }
                    }

                    // Build session items with journey-based question types
                    for wordIndex in selectedIndices {
                        let word = words[wordIndex]
                        let questionType = DataService.getQuestionType(for: word.hanzi, journey: journey)
                        let item = SessionItem(wordIndex: wordIndex, questionType: questionType)
                        sessionItems.append(item)
                    }
                }
                // navigationBar modifiers are left in place if view is used inside a NavigationStack
                .alert("Exit session?", isPresented: $showExitConfirm) {
                    Button("Exit", role: .destructive) {
                        // dismiss back to PracticeRootView
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to exit the practice session? Progress will be lost.")
                }
            }
        }
    }


    private var flashcardView: some View {
        let item = sessionItems[currentIndex]
        let word = words[item.wordIndex]

        return ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 6)

            // Content
            VStack(spacing: 8) {
                Text(word.hanzi)
                    .font(.system(size: 40, weight: .semibold, design: .default))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                if showAnswer {
                    VStack(spacing: 6) {
                        Text(word.pinyin)
                            .foregroundColor(.secondary)
                            .font(.headline)
                        Text(word.english.joined(separator: ", "))
                            .font(.title3)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(24)
        }
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                showAnswer.toggle()
            }
        }
        .frame(width: 320, height: 520)
        .frame(maxWidth: .infinity)
    }

    // simplest quiz: show hanzi, pick english
    private var quizView: some View {
        let item = sessionItems[currentIndex]
        let word = words[item.wordIndex]
        let (options, correctChoice) = makeOptions(correct: word)

        return VStack(spacing: 12) {
            Text(word.hanzi)
                .font(.system(size: 48))
            Text("Choose the meaning:")
            ForEach(options, id: \.self) { option in
                Button(option) {
                    let correct = (option == correctChoice)
                    advanceWord(correct: correct)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func makeOptions(correct: Word) -> (options: [String], correctChoice: String) {
        // choose one of the correct word's meanings at random
        let correctChoice = correct.english.randomElement() ?? ""

        // take up to 3 other random meanings from different words as distractors
        var others: [String] = []
        let shuffled = words.filter { $0.hanzi != correct.hanzi }.shuffled()
        for w in shuffled.prefix(6) { // sample a few and pick random meanings to reduce duplicates
            if let m = w.english.randomElement() {
                others.append(m)
            }
            if others.count >= 3 { break }
        }

        var opts = ([correctChoice] + others).shuffled()
        return (opts, correctChoice)
    }

    // compute delta (0.0 - 1.0) awarded for a correct response based on word level and question type
    private func deltaFor(word: Word, questionType: QuestionType) -> Double {
        // Points scale: flashcard level1=10, level5=5; quiz level1=30, level5=15
        let flash1 = 10.0
        let flash5 = 5.0
        let quiz1 = 30.0
        let quiz5 = 15.0

        let level = Double(max(1, min(5, word.level)))
        let isQuiz = (questionType == .multipleChoice)
        if isQuiz {
            let step = (quiz1 - quiz5) / 4.0
            let pts = quiz1 - (level - 1.0) * step
            return pts / 100.0
        } else {
            let step = (flash1 - flash5) / 4.0
            let pts = flash1 - (level - 1.0) * step
            return pts / 100.0
        }
    }

    private func advanceWord(correct: Bool) {
        showAnswer = false

        // determine current word from session item
        guard !sessionItems.isEmpty, currentIndex < sessionItems.count else { return }
        let item = sessionItems[currentIndex]
        let word = words[item.wordIndex]

        // determine delta based on correctness and question type
        let fullDelta = deltaFor(word: word, questionType: item.questionType)
        let appliedDelta: Double
        if correct {
            appliedDelta = fullDelta
        } else {
            // wrong answers reduce mastery: quiz -> -1/2, flashcard -> -1/4
            appliedDelta = item.questionType == .multipleChoice ? (-fullDelta / 2.0) : (-fullDelta / 4.0)
        }

        ProgressStore.shared.addProgress(for: word.hanzi, delta: appliedDelta)
        let progress = ProgressStore.shared.getProgress(for: word.hanzi)
        if progress >= 1.0 {
            if !sessionMastered.contains(word.hanzi) {
                sessionMastered.append(word.hanzi)
            }
        } else {
            // if progress dropped below mastery during this session, remove from sessionMastered
            if let idx = sessionMastered.firstIndex(of: word.hanzi) {
                sessionMastered.remove(at: idx)
            }
        }

        // update seen count for this word
        var count = seenCounts[word.hanzi, default: 0]
        count += 1
        seenCounts[word.hanzi] = count

        // advance to next session item
        currentIndex += 1
        if currentIndex >= sessionItems.count {
            // Record session completion for word release gate
            ProgressManager.recordSessionCompletion(for: topic.filename)
            showSummary = true
            return
        }
    }
}


#Preview {
    PracticeSessionView(topic: Topic(name: "HSK 1 Part 1", filename: "hsk1_part1"))
}
