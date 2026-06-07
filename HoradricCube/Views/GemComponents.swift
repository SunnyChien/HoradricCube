import SwiftUI

/// 宝石图标组件，用于在各页面统一展示宝石外观
struct GemIcon: View {
    let type: GemType
    let grade: GemGrade
    let size: CGFloat

    init(type: GemType, grade: GemGrade, size: CGFloat = 44) {
        self.type = type
        self.grade = grade
        self.size = size
    }

    var body: some View {
        ZStack {
            // 宝石底色光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [type.color.opacity(0.6), type.color.opacity(0.15)],
                        center: .center,
                        startRadius: size * 0.1,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)

            // 宝石符号
            Text(grade.symbol)
                .font(.system(size: size * 0.5, weight: .bold))
                .foregroundStyle(type.color)
                .shadow(color: type.color.opacity(0.5), radius: 2)
        }
    }
}

/// 宝石卡片，展示一颗宝石的简要信息
struct GemCard: View {
    let gem: Gem

    var body: some View {
        HStack(spacing: 12) {
            GemIcon(type: gem.type, grade: gem.grade, size: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(gem.type.gemName) · \(gem.grade.displayName)")
                    .font(.headline)
                Text(gem.reason)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Text(gem.createdAt, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
