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
    @State private var quizOptions: [String] = []
    @State private var quizCorrectChoice: String = ""
    @State private var constructionOptions: [String] = []
    @State private var constructionSelectedCharacters: [String] = []
    @State private var pinyinOptions: [String] = []
    @State private var pinyinCorrectChoice: String = ""
    
    // Quiz state for current question
    @State private var selectedAnswer: String?
    @State private var isAnswered = false
    @State private var feedbackState: QuizFeedbackState = .neutral

    // session items: word index + question type determined by journey
    private struct SessionItem: Identifiable {
        let id = UUID()
        let wordIndex: Int
        let questionType: QuestionType
    }
    @State private var sessionItems: [SessionItem] = []
    @State private var showSummary = false
    @State private var sessionMastered: [String] = []
    @State private var sessionStartingProgress: [String: Double] = [:]  // Track progress at session start
    @State private var showExitConfirm = false
    @State private var journey: MasteryJourney = DataService.loadMasteryJourney()
    @Environment(\.dismiss) private var dismiss

    // fixed session length
    private let fixedSessionLength: Int = 15
    private let maxRepetitionsPerWord: Int = 6

    // computed current question type (safe if sessionItems empty)
    private var currentQuestionType: QuestionType {
        guard !sessionItems.isEmpty, currentIndex < sessionItems.count else { return .flashcard }
        return sessionItems[currentIndex].questionType
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
                            let currentWord = words[sessionItems[currentIndex].wordIndex]
                            
                            switch currentQuestionType {
                            case .flashcard:
                                let wordProgress = ProgressStore.shared.getProgress(for: currentWord.hanzi)
                                FlashcardQuestionView(
                                    word: currentWord,
                                    isNewWord: wordProgress == 0.0
                                )
                                
                            case .multipleChoice:
                                MultipleChoiceQuestionView(
                                    word: currentWord,
                                    options: quizOptions,
                                    correctChoice: quizCorrectChoice,
                                    onAnswered: { correct in
                                        advanceWord(correct: correct)
                                        // Reset quiz state for next question
                                        selectedAnswer = nil
                                        isAnswered = false
                                        feedbackState = .neutral
                                    },
                                    selectedAnswer: selectedAnswer,
                                    isAnswered: isAnswered,
                                    feedbackState: feedbackState,
                                    onOptionSelected: { option, correct in
                                        selectedAnswer = option
                                        isAnswered = true
                                        feedbackState = correct ? .correct : .incorrect
                                    }
                                )
                                
                            case .construction:
                                ConstructionQuestionView(
                                    word: currentWord,
                                    availableCharacters: constructionOptions,
                                    onSubmit: { correct in
                                        advanceWord(correct: correct)
                                        // Reset construction state for next question
                                        constructionSelectedCharacters = []
                                        isAnswered = false
                                        feedbackState = .neutral
                                    },
                                    selectedCharacters: constructionSelectedCharacters,
                                    isAnswered: isAnswered,
                                    feedbackState: feedbackState,
                                    onCharacterToggled: { char in
                                        if constructionSelectedCharacters.contains(char) {
                                            constructionSelectedCharacters.removeAll { $0 == char }
                                        } else {
                                            constructionSelectedCharacters.append(char)
                                        }
                                    },
                                    onSubmitted: {
                                        isAnswered = true
                                        let constructedWord = constructionSelectedCharacters.joined()
                                        let correct = (constructedWord == currentWord.hanzi)
                                        feedbackState = correct ? .correct : .incorrect
                                    }
                                )
                                
                            case .pinyin:
                                PinyinQuestionView(
                                    word: currentWord,
                                    options: pinyinOptions,
                                    correctChoice: pinyinCorrectChoice,
                                    onAnswered: { correct in
                                        advanceWord(correct: correct)
                                        // Reset quiz state for next question
                                        selectedAnswer = nil
                                        isAnswered = false
                                        feedbackState = .neutral
                                    },
                                    selectedAnswer: selectedAnswer,
                                    isAnswered: isAnswered,
                                    feedbackState: feedbackState,
                                    onOptionSelected: { option, correct in
                                        selectedAnswer = option
                                        isAnswered = true
                                        feedbackState = correct ? .correct : .incorrect
                                    }
                                )
                                
                            default:
                                Text("Question type not implemented")
                            }

                            if currentQuestionType == .flashcard {
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
                    sessionItems.removeAll()
                    
                    guard !words.isEmpty else { return }
                    
                    // Capture starting progress for all words
                    sessionStartingProgress = [:]
                    for word in words {
                        sessionStartingProgress[word.hanzi] = ProgressStore.shared.getProgress(for: word.hanzi)
                    }

                    // Get unlocked word indices based on session count
                    let unlockedIndices = DataService.getUnlockedWordIndices(for: topic.filename, totalWords: words.count)
                    
                    if unlockedIndices.isEmpty {
                        // No words unlocked yet (shouldn't happen with first 5 always available)
                        showSummary = true
                        return
                    }

                    // Separate unlocked words into mastered and unmastered pools
                    let unmasteredIndices = unlockedIndices.filter { ProgressStore.shared.getProgress(for: words[$0].hanzi) < 1.0 }
                    let masteredIndices = unlockedIndices.filter { ProgressStore.shared.getProgress(for: words[$0].hanzi) >= 1.0 }
                    
                    // Randomly select words from unlocked pool using 95/5 split (95% unmastered, 5% maintenance)
                    var selectedIndices: [Int] = []
                    var repetitionCount: [Int: Int] = [:]
                    
                    while selectedIndices.count < fixedSessionLength {
                        let useMaintenanceWord = Double.random(in: 0..<1.0) < 0.05 && !masteredIndices.isEmpty
                        let pool = useMaintenanceWord ? masteredIndices : unmasteredIndices
                        
                        guard !pool.isEmpty else {
                            // If one pool is empty, fall back to the other
                            let fallbackPool = useMaintenanceWord ? unmasteredIndices : masteredIndices
                            guard !fallbackPool.isEmpty else { break }  // Can't continue if both empty
                            
                            let randomIndex = fallbackPool.randomElement()!
                            let repsForThisWord = repetitionCount[randomIndex, default: 0]
                            let isLastWord = !selectedIndices.isEmpty && selectedIndices.last == randomIndex
                            
                            if repsForThisWord < maxRepetitionsPerWord && !isLastWord {
                                selectedIndices.append(randomIndex)
                                repetitionCount[randomIndex, default: 0] += 1
                            }
                            continue
                        }
                        
                        let randomIndex = pool.randomElement()!
                        let repsForThisWord = repetitionCount[randomIndex, default: 0]
                        
                        // Check if we can add this word:
                        // 1. Hasn't hit max repetitions
                        // 2. Not the same as the last selected word (prevent back-to-back)
                        let isLastWord = !selectedIndices.isEmpty && selectedIndices.last == randomIndex
                        
                        if repsForThisWord < maxRepetitionsPerWord && !isLastWord {
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
                    
                    // Generate initial quiz options if first question is a quiz
                    if !sessionItems.isEmpty {
                        if sessionItems[0].questionType == .multipleChoice {
                            let (options, correctChoice) = makeOptions(correct: words[sessionItems[0].wordIndex])
                            quizOptions = options
                            quizCorrectChoice = correctChoice
                        } else if sessionItems[0].questionType == .construction {
                            constructionOptions = makeConstructionOptions(correct: words[sessionItems[0].wordIndex])
                        } else if sessionItems[0].questionType == .pinyin {
                            let (options, correctChoice) = makePinyinOptions(correct: words[sessionItems[0].wordIndex])
                            pinyinOptions = options
                            pinyinCorrectChoice = correctChoice
                        }
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


    // simplest quiz: show hanzi, pick english
    private func makeOptions(correct: Word) -> (options: [String], correctChoice: String) {
        // choose one of the correct word's meanings at random
        let correctChoice = correct.english.randomElement() ?? ""

        // take up to 3 other random meanings from different words as distractors
        // only select from words in the current topic, and exclude meanings that match the correct answer
        var others: [String] = []
        let candidateWords = words
            .filter { $0.hanzi != correct.hanzi } // exclude the correct word itself
            .filter { word in
                // FILTER: Exclude words that have ANY overlap in English meanings
                let correctSet = Set(correct.english.map { $0.lowercased() })
                let wordSet = Set(word.english.map { $0.lowercased() })
                return correctSet.intersection(wordSet).isEmpty // Only keep words with NO overlap
            }
            .shuffled()
        
        for w in candidateWords {
            // filter out meanings that match the correct answer to avoid duplicates
            let validMeanings = w.english.filter { $0.lowercased() != correctChoice.lowercased() }
            
            if let m = validMeanings.randomElement() {
                others.append(m)
            }
            if others.count >= 3 { break }
        }

        let opts = ([correctChoice] + others).shuffled()
        return (opts, correctChoice)
    }

    // Create 6 character options for construction question
    private func makeConstructionOptions(correct: Word) -> [String] {
        // Extract individual characters from the correct word
        let correctCharacters = Array(correct.hanzi).map { String($0) }
        
        // Collect all characters from other words as potential distractors
        var distractorCharacters: [String] = []
        let otherWords = words.filter { $0.hanzi != correct.hanzi }
        
        for word in otherWords {
            let chars = Array(word.hanzi).map { String($0) }
            distractorCharacters.append(contentsOf: chars)
        }
        
        // Shuffle and remove duplicates
        distractorCharacters = Array(Set(distractorCharacters)).shuffled()
        
        // Build options: include all correct characters, then fill with distractors
        var options = correctCharacters
        let neededCount = 6 - options.count
        
        if neededCount > 0 {
            // Add random distractors, excluding any that match correct characters
            let validDistracters = distractorCharacters.filter { !options.contains($0) }
            let selectedDistracters = Array(validDistracters.prefix(neededCount))
            options.append(contentsOf: selectedDistracters)
        }
        
        // If still not enough (all words are single character?), just shuffle what we have
        while options.count < 6 {
            if let extra = distractorCharacters.randomElement() {
                if !options.contains(extra) {
                    options.append(extra)
                }
            } else {
                break
            }
        }
        
        return options.shuffled()
    }

    // Create pinyin options with mandatory wrong-tone distractor
    private func makePinyinOptions(correct: Word) -> (options: [String], correctChoice: String) {
        let correctChoice = correct.pinyin
        
        var options: [String] = [correctChoice]
        
        // Try to add a wrong-tone variant as a mandatory distractor (100% for now)
        if let wrongToneVariant = PinyinToneHelper.getDifferentToneVariant(from: correctChoice) {
            options.append(wrongToneVariant)
        }
        
        // Add other pinyin from different words as distractors
        let otherWords = words.filter { $0.hanzi != correct.hanzi }
        for word in otherWords.shuffled() {
            // Don't add duplicate meanings
            if !options.contains(word.pinyin) {
                options.append(word.pinyin)
            }
            if options.count >= 4 { break }
        }
        
        // If we still need more options, fill with more tone variants
        while options.count < 4 {
            let allVariants = PinyinToneHelper.generateAllToneVariants(from: correctChoice)
            if let variant = allVariants.first(where: { !options.contains($0) }) {
                options.append(variant)
            } else {
                break
            }
        }
        
        return (options.shuffled(), correctChoice)
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

        ProgressStore.shared.addProgress(for: word.hanzi, delta: appliedDelta, in: topic.filename)
        let progress = ProgressStore.shared.getProgress(for: word.hanzi)
        let startingProgress = sessionStartingProgress[word.hanzi] ?? 0.0
        
        // Only add to sessionMastered if it JUST became mastered during this session
        // (was < 1.0 at session start, now >= 1.0)
        if progress >= 1.0 && startingProgress < 1.0 {
            if !sessionMastered.contains(word.hanzi) {
                sessionMastered.append(word.hanzi)
            }
        }

        // advance to next session item
        currentIndex += 1
        if currentIndex >= sessionItems.count {
            // Record session completion for word release gate
            ProgressManager.recordSessionCompletion(for: topic.filename)
            showSummary = true
            return
        }
        
        // Reset all question state for next question
        selectedAnswer = nil
        constructionSelectedCharacters = []
        isAnswered = false
        feedbackState = .neutral
        
        // Generate new question's options IMMEDIATELY if next question is a quiz, construction, or pinyin
        // This ensures options are ready BEFORE the view re-renders
        if !sessionItems.isEmpty && currentIndex < sessionItems.count {
            if sessionItems[currentIndex].questionType == .multipleChoice {
                let (options, correctChoice) = makeOptions(correct: words[sessionItems[currentIndex].wordIndex])
                quizOptions = options
                quizCorrectChoice = correctChoice
            } else if sessionItems[currentIndex].questionType == .construction {
                constructionOptions = makeConstructionOptions(correct: words[sessionItems[currentIndex].wordIndex])
            } else if sessionItems[currentIndex].questionType == .pinyin {
                let (options, correctChoice) = makePinyinOptions(correct: words[sessionItems[currentIndex].wordIndex])
                pinyinOptions = options
                pinyinCorrectChoice = correctChoice
            }
        }
    }
}
