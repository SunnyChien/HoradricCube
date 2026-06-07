import SwiftUI
import SwiftData

/// 获得宝石页面
struct AddGemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: GemType = .sports
    @State private var selectedGrade: GemGrade = .chipped
    @State private var reason = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 宝石预览
                        gemPreview

                        // 选择宝石类型
                        typePicker

                        // 选择宝石等级
                        gradePicker

                        // 输入获得原因
                        reasonInput
                    }
                    .padding()
                }
            }
            .navigationTitle("获得宝石")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("存入宝盒") { saveGem() }
                        .foregroundStyle(.cyan)
                        .disabled(reason.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - 宝石预览
    private var gemPreview: some View {
        VStack(spacing: 8) {
            GemIcon(type: selectedType, grade: selectedGrade, size: 80)
            Text("\(selectedType.gemName) · \(selectedGrade.displayName)")
                .font(.title3.bold())
                .foregroundStyle(.white)
        }
        .padding(.vertical, 16)
    }

    // MARK: - 类型选择
    private var typePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("宝石类型")
                .font(.headline)
                .foregroundStyle(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(GemType.allCases) { type in
                    Button {
                        withAnimation { selectedType = type }
                    } label: {
                        VStack(spacing: 4) {
                            GemIcon(type: type, grade: .chipped, size: 32)
                            Text(type.rawValue)
                                .font(.caption2)
                                .foregroundStyle(selectedType == type ? .white : .white.opacity(0.6))
                        }
                        .padding(8)
                        .background(
                            selectedType == type
                            ? type.color.opacity(0.3)
                            : Color.white.opacity(0.05)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedType == type ? type.color : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 等级选择
    private var gradePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("宝石等级")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                ForEach(GemGrade.allCases) { grade in
                    Button {
                        withAnimation { selectedGrade = grade }
                    } label: {
                        VStack(spacing: 4) {
                            Text(grade.symbol)
                                .font(.title2)
                                .foregroundStyle(selectedGrade == grade ? selectedType.color : .white.opacity(0.5))
                            Text(grade.displayName)
                                .font(.caption2)
                                .foregroundStyle(selectedGrade == grade ? .white : .white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedGrade == grade
                            ? selectedType.color.opacity(0.2)
                            : Color.white.opacity(0.05)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedGrade == grade ? selectedType.color : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 原因输入
    private var reasonInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("获得原因")
                .font(.headline)
                .foregroundStyle(.white)

            TextField("今天做了什么了不起的事？", text: $reason)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(.white)
        }
    }

    // MARK: - 保存
    private func saveGem() {
        let gem = Gem(type: selectedType, grade: selectedGrade, reason: reason.trimmingCharacters(in: .whitespaces))
        modelContext.insert(gem)
        dismiss()
    }
}
