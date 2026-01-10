import Foundation
import SwiftData

@Model
class WordProgress {
    @Attribute(.unique) var hanzi: String
    var mastery: Double
    var lastPracticed: Date
    var isBookmarked: Bool = false
    
    init(hanzi: String, mastery: Double, lastPracticed: Date = Date(), isBookmarked: Bool = false) {
        self.hanzi = hanzi
        self.mastery = mastery
        self.lastPracticed = lastPracticed
        self.isBookmarked = isBookmarked
    }
}
