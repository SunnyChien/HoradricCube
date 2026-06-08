import Foundation
import SwiftData

/// 合成来源记录
struct GemSource: Codable {
    let reason: String
    let createdAt: Date
    let photoData: Data?

    init(reason: String, createdAt: Date, photoData: Data? = nil) {
        self.reason = reason
        self.createdAt = createdAt
        self.photoData = photoData
    }
}

@Model
final class Gem {
    var type: GemType
    var grade: GemGrade
    var reason: String
    var photoData: Data?
    var createdAt: Date
    /// 合成来源，nil 表示直接获得，非空表示由这些宝石合成而来
    var sources: [GemSource]?

    init(type: GemType, grade: GemGrade, reason: String, photoData: Data? = nil, createdAt: Date = .now, sources: [GemSource]? = nil) {
        self.type = type
        self.grade = grade
        self.reason = reason
        self.photoData = photoData
        self.createdAt = createdAt
        self.sources = sources
    }
}
