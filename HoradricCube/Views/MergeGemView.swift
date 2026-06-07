import SwiftUI
import SwiftData

/// 宝石合成页面：3颗同级宝石合成1颗高一级宝石
struct MergeGemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var gems: [Gem]

    @State private var selectedType: GemType = .sports
    @State private var selectedGrade: GemGrade = .chipped
    @State private var mergeSuccess = false

    /// 当前选中类型和等级的宝石数量
    private var availableCount: Int {
        gems.filter { $0.type == selectedType && $0.grade == selectedGrade }.count
    }

    /// 是否可以合成
    private var canMerge: Bool {
        availableCount >= GemGrade.mergeCount && selectedGrade.nextGrade != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    // 合成示意图
                    mergeDiagram

                    // 选择类型
                    typeSelector

                    // 选择等级
                    gradeSelector

                    // 合成按钮
                    mergeButton
                }
                .padding()
            }
            .navigationTitle("宝石合成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("合成成功！", isPresented: $mergeSuccess) {
                Button("太棒了！") {}
            } message: {
                Text("3颗\(selectedGrade.displayName)\(selectedType.gemName)合成了1颗\(selectedGrade.nextGrade?.displayName ?? "")\(selectedType.gemName)！")
            }
        }
    }

    // MARK: - 合成示意图
    private var mergeDiagram: some View {
        HStack(spacing: 16) {
            // 3颗源宝石
            ForEach(0..<3, id: \.self) { _ in
                GemIcon(type: selectedType, grade: selectedGrade, size: 44)
            }

            Image(systemName: "arrow.right")
                .font(.title2)
                .foregroundStyle(.white)

            // 合成结果
            if let nextGrade = selectedGrade.nextGrade {
                GemIcon(type: selectedType, grade: nextGrade, size: 56)
            } else {
                Text("已满级")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 类型选择
    private var typeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择宝石类型")
                .font(.headline)
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GemType.allCases) { type in
                        Button {
                            withAnimation { selectedType = type }
                        } label: {
                            VStack(spacing: 4) {
                                GemIcon(type: type, grade: .chipped, size: 28)
                                Text(type.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(selectedType == type ? .white : .white.opacity(0.5))
                            }
                            .padding(8)
                            .background(selectedType == type ? type.color.opacity(0.3) : Color.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(selectedType == type ? type.color : Color.clear, lineWidth: 1.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - 等级选择
    private var gradeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择宝石等级")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                ForEach(GemGrade.allCases) { grade in
                    Button {
                        withAnimation { selectedGrade = grade }
                    } label: {
                        VStack(spacing: 4) {
                            Text(grade.symbol)
                                .font(.title3)
                                .foregroundStyle(selectedGrade == grade ? selectedType.color : .white.opacity(0.4))
                            Text(grade.displayName)
                                .font(.caption2)
                                .foregroundStyle(selectedGrade == grade ? .white : .white.opacity(0.4))
                            Text("×\(gems.filter { $0.type == selectedType && $0.grade == grade }.count)")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedGrade == grade ? selectedType.color.opacity(0.2) : Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(selectedGrade == grade ? selectedType.color : Color.clear, lineWidth: 1.5))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 合成按钮
    private var mergeButton: some View {
        Button {
            performMerge()
        } label: {
            HStack {
                Image(systemName: "arrow.triangle.merge")
                Text(canMerge ? "合成！" : (selectedGrade.nextGrade == nil ? "已满级" : "宝石不足（需要\(GemGrade.mergeCount)颗）"))
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(canMerge ? selectedType.color : Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canMerge)
    }

    // MARK: - 执行合成
    private func performMerge() {
        guard canMerge, let nextGrade = selectedGrade.nextGrade else { return }

        // 找出3颗同级同类型宝石
        let candidates = gems
            .filter { $0.type == selectedType && $0.grade == selectedGrade }
            .sorted { $0.createdAt < $1.createdAt }

        // 删除3颗
        for i in 0..<GemGrade.mergeCount {
            modelContext.delete(candidates[i])
        }

        // 创建1颗高一级宝石
        let newGem = Gem(
            type: selectedType,
            grade: nextGrade,
            reason: "由\(GemGrade.mergeCount)颗\(selectedGrade.displayName)\(selectedType.gemName)合成"
        )
        modelContext.insert(newGem)

        mergeSuccess = true
    }
}
