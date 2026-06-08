import SwiftUI
import SwiftData

/// 宝石详情页：查看获取时间、原因、成果照片、合成来源、分解
struct GemDetailView: View {
    @Bindable var gem: Gem
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDecomposeConfirm = false

    private var photoImage: Image? {
        guard let data = gem.photoData, let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }

    /// 是否为合成宝石（可分解）
    private var canDecompose: Bool {
        gem.sources != nil && !gem.sources!.isEmpty
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f3460")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // 宝石图标
                    GemIcon(type: gem.type, grade: gem.grade, size: 100)

                    Text("\(gem.type.gemName) · \(gem.grade.displayName)")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    // 获取时间
                    infoRow(icon: "calendar", title: "获取时间", value: formattedDate)

                    // 获得原因
                    VStack(alignment: .leading, spacing: 8) {
                        Label("获得原因", systemImage: "text.quote")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(gem.reason)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // 成果照片
                    if let photoImage {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("成果展示", systemImage: "photo")
                                .font(.headline)
                                .foregroundStyle(.white)
                            photoImage
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 8)
                        }
                    }

                    // 合成来源
                    if let sources = gem.sources, !sources.isEmpty {
                        sourceSection(sources)
                    }

                    // 分解按钮
                    if canDecompose {
                        decomposeButton
                    }
                }
                .padding()
            }
        }
        .navigationTitle("宝石详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("确认分解？", isPresented: $showDecomposeConfirm) {
            Button("取消", role: .cancel) {}
            Button("分解", role: .destructive) {
                decompose()
            }
        } message: {
            Text("这颗宝石将分解为\(gem.sources?.count ?? 0)颗原始宝石，宝石本身将被销毁。")
        }
    }

    // MARK: - 分解按钮
    private var decomposeButton: some View {
        Button {
            showDecomposeConfirm = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("分解宝石")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.red.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 合成来源
    private func sourceSection(_ sources: [GemSource]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("合成来源", systemImage: "arrow.triangle.merge")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(Array(sources.enumerated()), id: \.offset) { index, source in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("来源 \(index + 1)")
                            .font(.subheadline.bold())
                            .foregroundStyle(gem.type.color)
                        Spacer()
                        Text(source.createdAt, style: .date)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Text(source.reason)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))

                    if let data = source.photoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - 分解逻辑
    private func decompose() {
        guard let sources = gem.sources, !sources.isEmpty else { return }

        // 还原源宝石
        for source in sources {
            let restoredGem = Gem(
                type: gem.type,
                grade: GemGrade(rawValue: gem.grade.rawValue - 1) ?? .chipped,
                reason: source.reason,
                photoData: source.photoData,
                createdAt: source.createdAt
            )
            modelContext.insert(restoredGem)
        }

        // 删除合成宝石
        modelContext.delete(gem)
        dismiss()
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: gem.createdAt)
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
