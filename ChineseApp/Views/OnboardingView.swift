
//
//  OnboardingView.swift
//  ChineseApp
//
//  Created by Billy Orr on 2026-01-06.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingCompleted: Bool
    @State private var currentPage = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background Color Logic
            // Light Mode -> White (.systemBackground)
            // Dark Mode -> Dark Grey (.secondarySystemBackground)
            Color(colorScheme == .dark ? .secondarySystemBackground : .systemBackground)
                .ignoresSafeArea()
            
            VStack {
                // Tab View for Slides
                TabView(selection: $currentPage) {
                    // Page 0: Welcome / Logo
                    OnboardingPage(
                        image: "Logo",
                        imageType: .assetIcon,
                        title: "Welcome to Steamed",
                        description: "We're so glad you've decided to begin this journey! Let's get you fluent effortlessly.",
                        color: .steamedDarkBlue,
                        pageIndex: 0
                    )
                    .tag(0)
                    
                    // Page 1: Practice
                    OnboardingPage(
                        image: "1",
                        imageType: .screenshot,
                        title: "Practice Page",
                        description: "This is the practice page where you can build mastery by quizzing yourself using various word decks.",
                        color: .steamedBlue,
                        pageIndex: 1
                    )
                    .tag(1)
                    
                    // Page 2: Dictionary
                    OnboardingPage(
                        image: "2",
                        imageType: .screenshot,
                        title: "Dictionary Page",
                        description: "Browse all your decks here. Most importantly, use the Bookmarks deck to save and review words you encounter during your reading sessions.",
                        color: .steamedBlue,
                        pageIndex: 2
                    )
                    .tag(2)
                    
                    // Page 3: Library
                    OnboardingPage(
                        image: "3",
                        imageType: .screenshot,
                        title: "Library Page",
                        description: "Access a vast library of stories and reading passages. Filter by topic or difficulty to find the perfect content for your level.",
                        color: .steamedBlue,
                        pageIndex: 3
                    )
                    .tag(3)
                    
                    // Page 4: Reading
                    OnboardingPage(
                        image: "4",
                        imageType: .screenshot,
                        title: "Interactive Reading",
                        description: "In-app reading with the ability to tap on any word and reveal a tooltip with its definition, pinyin, and usage examples.",
                        color: .steamedBlue,
                        pageIndex: 4
                    )
                    .tag(4)

                    // Page 5: Ready to Start
                    OnboardingPage(
                        image: "Logo",
                        imageType: .assetIcon,
                        title: "Are you ready?",
                        description: "Your journey to fluency starts now. Let's get started!",
                        color: .steamedDarkBlue,
                        pageIndex: 5
                    )
                    .tag(5)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom Controls
                VStack(spacing: 20) {
                    // Custom Page Indicators
                    HStack(spacing: 8) {
                        ForEach(0..<6) { index in
                            Circle()
                                .fill(currentPage == index ? Color.steamedDarkBlue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Action Button
                    Button(action: {
                        withAnimation {
                            isOnboardingCompleted = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.steamedDarkBlue)
                            .cornerRadius(25)
                            .shadow(color: Color.steamedDarkBlue.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, 40)
                    .opacity(currentPage == 5 ? 1 : 0)
                    .disabled(currentPage != 5)
                }
                .padding(.bottom, 20) // Reduced padding to lower the "breadcrumb" area
            }
        }
    }
}

enum OnboardingImageType {
    case systemIcon
    case assetIcon
    case screenshot
}

struct OnboardingPage: View {
    let image: String
    let imageType: OnboardingImageType
    let title: String
    let description: String
    let color: Color
    let pageIndex: Int
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating = false
    
    var resolvedImageName: String {
        switch imageType {
        case .screenshot:
            let prefix = colorScheme == .dark ? "dark-" : "light-"
            return prefix + image
        default:
            return image
        }
    }
    
    var body: some View {
        VStack(spacing: 20) { // Reduced spacing between Image and Text block
            Spacer()
            
            // Image / Icon
            ZStack {
                switch imageType {
                case .systemIcon:
                    // Animated Circle Background for Icons
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                    
                    Image(systemName: resolvedImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(color)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .rotationEffect(pageIndex == 1 && isAnimating ? .degrees(10) : .degrees(0))
                        
                case .assetIcon:
                    // Just the logo asset
                     Image(resolvedImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .cornerRadius(40)
                        .shadow(color: color.opacity(0.3), radius: 15, x: 0, y: 10)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)

                case .screenshot:
                    // Screenshot Mode - Larger, Cleaner, Minimal Styling
                    Image(resolvedImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 650) 
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .scaleEffect(isAnimating ? 1.01 : 1.0)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            VStack(spacing: 12) { // Reduced internal text spacing
                Text(title)
                    .font(.system(size: 28, weight: .bold)) // Slightly smaller title to save space
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24) // Reduced padding to allow text to be wider -> fewer lines
                    .lineSpacing(2) // Reduced line spacing
                    .fixedSize(horizontal: false, vertical: true) // Allow text to expand vertically but not squish image
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isOnboardingCompleted: .constant(false))
}
