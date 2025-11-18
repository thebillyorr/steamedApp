//
//  FinalExamView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2025-11-15.
//

import SwiftUI

struct FinalExamView: View {
    let topic: Topic
    @Environment(\.dismiss) private var dismiss
    @State private var showExamSession = false
    @State private var showTopicCompletion = false
    
    var body: some View {
        VStack(spacing: 20) {
            if showExamSession {
                FinalExamSessionView(
                    topic: topic,
                    showExamSession: $showExamSession,
                    showTopicCompletion: $showTopicCompletion
                )
            } else {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("🎯")
                            .font(.system(size: 64))
                        
                        Text("Final Exam")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Master \(topic.name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ExamInfoRow(icon: "questionmark.circle", label: "Questions", value: "10")
                        ExamInfoRow(icon: "star.fill", label: "Difficulty", value: "Mixed")
                        ExamInfoRow(icon: "checkmark.circle.fill", label: "Pass Rate", value: "100%")
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button(action: { showExamSession = true }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Begin Final Exam")
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(24)
            }
        }
        .fullScreenCover(isPresented: $showTopicCompletion) {
            if let category = DataService.topicsByCategory.first(where: { $0.topics.contains(where: { $0.filename == topic.filename }) })?.category {
                TopicCompletionCongrats(topicCategory: category) {
                    // When celebration is complete, close both screens
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Exam Session

struct FinalExamSessionView: View {
    let topic: Topic
    @Binding var showExamSession: Bool
    @Binding var showTopicCompletion: Bool
    
    @State private var questionIndex = 0
    @State private var questions: [ExamQuestion] = []
    @State private var showSummary = false
    
    var body: some View {
        if showSummary {
            ExamSummaryView(
                topic: topic,
                showExamSession: $showExamSession,
                showTopicCompletion: $showTopicCompletion
            )
        } else if !questions.isEmpty && questionIndex < questions.count {
            VStack {
                // Progress bar
                VStack(spacing: 8) {
                    HStack {
                        Text("Question \(questionIndex + 1) of \(questions.count)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(String(format: "%.0f%%", Double(questionIndex) / Double(questions.count) * 100))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * CGFloat(questionIndex) / CGFloat(questions.count))
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Question
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        let question = questions[questionIndex]
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What does this mean?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(question.word.hanzi)
                                .font(.system(size: 32, weight: .bold))
                            
                            Text(question.word.pinyin)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        VStack(spacing: 12) {
                            ForEach(question.options, id: \.self) { option in
                                Button(action: {
                                    // Move to next question (everyone passes for now)
                                    questionIndex += 1
                                    if questionIndex >= questions.count {
                                        showSummary = true
                                    }
                                }) {
                                    HStack {
                                        Text(option)
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(16)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
        } else {
            ProgressView()
                .onAppear {
                    questions = generateExamQuestions(for: topic)
                }
        }
    }
    
    private func generateExamQuestions(for topic: Topic) -> [ExamQuestion] {
        let words = DataService.loadWords(for: topic)
        let shuffled = words.shuffled()
        
        // Take up to 10 words
        return shuffled.prefix(10).map { word in
            // Generate 4 options (correct + 3 distractors)
            let correctOption = word.english.randomElement() ?? ""
            var options = [correctOption]
            
            let otherWords = words.filter { $0.hanzi != word.hanzi }
            for distractor in otherWords.shuffled().prefix(3) {
                if let option = distractor.english.randomElement() {
                    options.append(option)
                }
            }
            
            return ExamQuestion(word: word, options: options.shuffled())
        }
    }
}

// MARK: - Exam Summary

struct ExamSummaryView: View {
    let topic: Topic
    @Binding var showExamSession: Bool
    @Binding var showTopicCompletion: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("✅")
                    .font(.system(size: 64))
                
                Text("Exam Passed!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(topic.name) is now mastered")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                // Master the deck
                DeckMasteryManager.shared.masterDeck(filename: topic.filename)
                
                // Check if topic is complete
                if let category = DataService.topicsByCategory.first(where: { $0.topics.contains(where: { $0.filename == topic.filename }) })?.category {
                    TopicBadgeManager.shared.checkAndAwardTopicBadge(category: category)
                    
                    if TopicBadgeManager.shared.hasBadge(for: category) {
                        // Show celebration screen first, don't dismiss yet
                        showTopicCompletion = true
                        return  // Exit here, don't dismiss
                    }
                }
                
                // Only dismiss if no topic completion
                dismiss()
            }) {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(24)
        }
    }
}

// MARK: - Components

struct ExamInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Data Structure

struct ExamQuestion {
    let word: Word
    let options: [String]
}

#Preview {
    FinalExamView(topic: Topic(name: "Beginner 1", filename: "beginner_1"))
}
