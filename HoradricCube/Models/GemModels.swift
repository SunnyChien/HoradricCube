import Foundation
import SwiftUI

// MARK: - 宝石类型（8个成长维度）
enum GemType: String, Codable, CaseIterable, Identifiable {
    case sports = "体育"
    case art = "艺术"
    case experience = "阅历"
    case language = "语言"
    case math = "数字"
    case resilience = "坚韧"
    case life = "生活"
    case creativity = "创意"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .sports: return "figure.run"
        case .art: return "paintbrush"
        case .experience: return "globe.americas"
        case .language: return "book"
        case .math: return "number"
        case .resilience: return "flame"
        case .life: return "house"
        case .creativity: return "lightbulb"
        }
    }

    var color: Color {
        switch self {
        case .sports: return .red
        case .art: return .purple
        case .experience: return .blue
        case .language: return .green
        case .math: return .orange
        case .resilience: return .yellow
        case .life: return .brown
        case .creativity: return .pink
        }
    }

    var gemName: String {
        rawValue + "宝石"
    }
}

// MARK: - 宝石等级（参考暗黑破坏神）
enum GemGrade: Int, Codable, CaseIterable, Identifiable {
    case chipped = 1      // 碎片
    case flawed = 2       // 裂隙
    case normal = 3       // 普通
    case flawless = 4     // 无暇
    case perfect = 5      // 完美

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .chipped: return "碎片"
        case .flawed: return "裂隙"
        case .normal: return "普通"
        case .flawless: return "无暇"
        case .perfect: return "完美"
        }
    }

    var symbol: String {
        switch self {
        case .chipped: return "◇"
        case .flawed: return "◆"
        case .normal: return "❖"
        case .flawless: return "✦"
        case .perfect: return "★"
        }
    }

    /// 合成所需同级宝石数量（暗黑规则：3合1）
    static let mergeCount = 3

    /// 升级后的等级，nil 表示已最高
    var nextGrade: GemGrade? {
        GemGrade(rawValue: rawValue + 1)
    }
}
