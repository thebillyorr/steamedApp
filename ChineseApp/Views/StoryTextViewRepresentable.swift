import SwiftUI
import UIKit

// MARK: - Story Text View Representable

struct StoryTextViewRepresentable: UIViewRepresentable {
    let tokens: [StoryToken]
    let fontSize: CGFloat
    let selectedWordId: String?
    let onSelectionChanged: (String?, Int?) -> Void
    
    // Debug logging toggle (disabled in production)
    static let logEnabled: Bool = false
    static func debugLog(_ message: String) {
        // No-op when logging is disabled
        if logEnabled { print("[StoryText] \(message)") }
    }
    
    // Custom attribute key for word IDs and token index
    static let wordIdAttribute = NSAttributedString.Key("wordId")
    static let tokenIndexAttribute = NSAttributedString.Key("tokenIndex")
    
    // Spacing control: uniform kerning applied to the ENTIRE text.
    // Set to a small positive value (e.g., 0.8) for visible uniform spacing; 0 for none.
    static let uniformKern: CGFloat = 0.0
    
    func makeUIView(context: Context) -> UITextView {
        let textView = CustomStoryTextView()
        Self.debugLog("makeUIView: creating CustomStoryTextView")
        
        // Configure as read-only display
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        // CRITICAL: Enable text wrapping
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.heightTracksTextView = false
        
    // Add a plain tap gesture to avoid multi-tap quirks
    let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
    tapGesture.numberOfTapsRequired = 1
    tapGesture.cancelsTouchesInView = true
    tapGesture.delaysTouchesEnded = false
    tapGesture.delegate = context.coordinator
    textView.addGestureRecognizer(tapGesture)
        
        Self.debugLog("makeUIView: configured textView")
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
    // Build attributed string from tokens (including newline support)
    Self.debugLog("updateUIView: fontSize=\(fontSize), selectedWordId=\(String(describing: selectedWordId)), selectedTokenIndex=\(String(describing: context.coordinator.selectedTokenIndex))")
    let attributedString = Self.buildAttributedString(
            from: tokens,
            fontSize: fontSize,
            selectedWordId: selectedWordId,
            selectedTokenIndex: context.coordinator.selectedTokenIndex
        )
        textView.attributedText = attributedString
        
        // Font styling
        textView.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        textView.textColor = .label
        
        // CRITICAL: Invalidate intrinsic content size so SwiftUI recalculates layout
        textView.invalidateIntrinsicContentSize()
        
        // Update coordinator callbacks
        context.coordinator.onSelectionChanged = onSelectionChanged
        context.coordinator.textView = textView
        context.coordinator.tokens = tokens
        // Keep coordinator in sync with current selection for toggle logic
        context.coordinator.selectedWordId = selectedWordId
        Self.debugLog("updateUIView: applied attributedText length=\(textView.attributedText?.length ?? 0)")
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize? {
        // Return nil to use UITextView's intrinsic content size
        return nil
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSelectionChanged: onSelectionChanged, tokens: tokens)
    }
    
    private static func buildAttributedString(from tokens: [StoryToken], fontSize: CGFloat, selectedWordId: String?, selectedTokenIndex: Int?) -> NSAttributedString {
        let mutableString = NSMutableAttributedString()

        for (index, token) in tokens.enumerated() {
            // Normalize token text: strip leading/trailing spaces; skip pure-space tokens
            var tokenText = token.text
            if tokenText == "..." {
                // Remove unintended ellipsis tokens entirely
                debugLog("buildAttributedString: removed ellipsis token at index=\(index)")
                continue
            }

            // Remove explicit spaces to keep spacing consistent between all characters
            let trimmed = tokenText.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            tokenText = trimmed

            let tokenAttr = NSMutableAttributedString(string: tokenText)

            // Set base font for all tokens
            tokenAttr.addAttribute(
                .font,
                value: UIFont.systemFont(ofSize: fontSize, weight: .regular),
                range: NSRange(location: 0, length: tokenText.count)
            )

            // Always add token index attribute
            tokenAttr.addAttribute(
                Self.tokenIndexAttribute,
                value: index,
                range: NSRange(location: 0, length: tokenText.count)
            )

            // If this token has a word ID, attach the custom attribute
            // (Skip for newline-only tokens)
            if let wordId = token.id, !tokenText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                tokenAttr.addAttribute(
                    Self.wordIdAttribute,
                    value: wordId,
                    range: NSRange(location: 0, length: tokenText.count)
                )

                // Highlight only the tapped token (by index), not all occurrences
                if let selectedIndex = selectedTokenIndex, selectedIndex == index {
                    let lightBlue = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.3)
                    tokenAttr.addAttribute(
                        .backgroundColor,
                        value: lightBlue,
                        range: NSRange(location: 0, length: tokenText.count)
                    )
                }
            }

            mutableString.append(tokenAttr)

            // Do NOT append any separators; we want every character to have the same spacing.
        }

        // Apply uniform kerning to the entire string so spacing between all characters is identical
        if mutableString.length > 0 {
            mutableString.addAttribute(
                .kern,
                value: StoryTextViewRepresentable.uniformKern,
                range: NSRange(location: 0, length: mutableString.length)
            )
        }

        return mutableString
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onSelectionChanged: ((String?, Int?) -> Void)?
        var textView: UITextView?
        var tokens: [StoryToken]
    var selectedWordId: String?
    var selectedTokenIndex: Int?
        
        init(onSelectionChanged: @escaping (String?, Int?) -> Void, tokens: [StoryToken]) {
            self.onSelectionChanged = onSelectionChanged
            self.tokens = tokens
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let textView = textView else { return }
            // Get tap location in text view coordinates
            let tapPoint = gesture.location(in: textView)
            StoryTextViewRepresentable.debugLog("handleTap: tap at point=\(tapPoint), state=\(gesture.state.rawValue)")
            // Convert tap point to character index
            guard let charIndex = getCharacterIndex(at: tapPoint, in: textView) else {
                // Tap was on empty space - only deselect if something is selected
                StoryTextViewRepresentable.debugLog("handleTap: no character at point -> maybe deselect")
                if selectedWordId != nil {
                    applySelection(nil, tokenIndex: nil)
                }
                return
            }
            // Get attributes at that character index
            let attributes = textView.attributedText?.attributes(at: charIndex, effectiveRange: nil) ?? [:]
            // Check if this character has a word ID
            if let wordId = attributes[StoryTextViewRepresentable.wordIdAttribute] as? String {
                let tokenIndex = attributes[StoryTextViewRepresentable.tokenIndexAttribute] as? Int
                StoryTextViewRepresentable.debugLog("handleTap: charIndex=\(charIndex), attrs wordId=\(wordId), tokenIndex=\(String(describing: tokenIndex)), current sel wordId=\(selectedWordId ?? "nil"), selIndex=\(String(describing: selectedTokenIndex))")
                // Toggle: if tapping the currently selected word, deselect immediately
                if wordId == selectedWordId {
                    StoryTextViewRepresentable.debugLog("handleTap: toggling OFF selection")
                    applySelection(nil, tokenIndex: nil)
                } else {
                    StoryTextViewRepresentable.debugLog("handleTap: selecting wordId=\(wordId) at tokenIndex=\(String(describing: tokenIndex))")
                    applySelection(wordId, tokenIndex: tokenIndex)
                }
            } else {
                // Tap was on punctuation/space - only deselect if something is selected
                StoryTextViewRepresentable.debugLog("handleTap: tapped non-word character -> maybe deselect")
                if selectedWordId != nil {
                    applySelection(nil, tokenIndex: nil)
                }
            }
        }

        /// Apply selection locally (rebuild attributed string to reflect highlight) and notify SwiftUI
        private func applySelection(_ newWordId: String?, tokenIndex: Int?) {
            selectedWordId = newWordId
            selectedTokenIndex = tokenIndex
            onSelectionChanged?(newWordId, tokenIndex)
            StoryTextViewRepresentable.debugLog("applySelection: newWordId=\(newWordId ?? "nil"), tokenIndex=\(String(describing: tokenIndex))")
            guard let textView = textView else { return }
            // Rebuild attributed text with new selection to update highlight immediately
            let fontSize = textView.font?.pointSize ?? 22
            textView.attributedText = StoryTextViewRepresentable.buildAttributedString(
                from: tokens,
                fontSize: fontSize,
                selectedWordId: selectedWordId,
                selectedTokenIndex: selectedTokenIndex
            )
            textView.invalidateIntrinsicContentSize()
            StoryTextViewRepresentable.debugLog("applySelection: updated attributedText length=\(textView.attributedText?.length ?? 0)")
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // Allow SwiftUI gestures to work alongside our gesture
            return true
        }
        
        private func getCharacterIndex(at point: CGPoint, in textView: UITextView) -> Int? {
            let layoutManager = textView.layoutManager
            let textContainer = textView.textContainer
            
            // Adjust tap point to account for text container inset
            let adjustedPoint = CGPoint(
                x: point.x - textView.textContainerInset.left,
                y: point.y - textView.textContainerInset.top
            )
            
            // Get the character index from the layout manager
            let characterIndex = layoutManager.characterIndex(
                for: adjustedPoint,
                in: textContainer,
                fractionOfDistanceBetweenInsertionPoints: nil
            )
            
            // Ensure the index is valid
            guard characterIndex < textView.attributedText?.length ?? 0 else {
                return nil
            }
            
            return characterIndex
        }
    }
}

// MARK: - Passthrough Tap Gesture Recognizer

// Removed custom PassthroughTapGestureRecognizer in favor of plain UITapGestureRecognizer

// MARK: - Custom Story Text View
class CustomStoryTextView: UITextView {
    override var intrinsicContentSize: CGSize {
        // Calculate the size needed for the attributed text
        let textSize = sizeThatFits(CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: UIView.noIntrinsicMetric, height: max(textSize.height, 0))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Invalidate intrinsic content size whenever layout changes
        invalidateIntrinsicContentSize()
    }
}
