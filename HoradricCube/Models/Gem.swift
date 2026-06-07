import Foundation
import SwiftData

@Model
final class Gem {
    var type: GemType
    var grade: GemGrade
    var reason: String          // 获得这颗宝石的原因
    var createdAt: Date

    init(type: GemType, grade: GemGrade, reason: String, createdAt: Date = .now) {
        self.type = type
        self.grade = grade
        self.reason = reason
        self.createdAt = createdAt
    }
}
