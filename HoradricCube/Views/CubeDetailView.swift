import SwiftUI
import SwiftData

/// 宝盒详情页：查看所有已获得的宝石
struct CubeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Gem.createdAt, order: .reverse) private var gems: [Gem]
    @State private var selectedType: GemType?
    @State private var showMerge = false

    /// 筛选后的宝石
    private var filteredGems: [Gem] {
        if let type = selectedType {
            return gems.filter { $0.type == type }
        }
        return gems
    }

    /// 按类型+等级分组统计
    private var gemInventory: [GemType: [GemGrade: Int]] {
        Dictionary(grouping: gems, by: \.type).mapValues { typeGems in
            Dictionary(grouping: typeGems, by: \.grade).mapValues { $0.count }
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f3460")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // 类型筛选栏
                typeFilter

                // 宝石库存
                inventorySection

                Divider().overlay(.white.opacity(0.2))

                // 宝石列表
                gemList
            }
        }
        .navigationTitle("赫拉迪姆宝盒")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showMerge = true
                } label: {
                    Label("合成", systemImage: "arrow.triangle.merge")
                        .foregroundStyle(.cyan)
                }
            }
        }
        .sheet(isPresented: $showMerge) {
            MergeGemView()
        }
    }

    // MARK: - 类型筛选
    private var typeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "全部", isSelected: selectedType == nil) {
                    selectedType = nil
                }
                ForEach(GemType.allCases) { type in
                    filterChip(
                        label: type.rawValue,
                        icon: type.iconName,
                        isSelected: selectedType == type
                    ) {
                        selectedType = type
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func filterChip(label: String, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(label)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.cyan.opacity(0.3) : Color.white.opacity(0.1))
            .foregroundStyle(isSelected ? .cyan : .white.opacity(0.7))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - 宝石库存
    private var inventorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("库存")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(GemType.allCases) { type in
                        if let grades = gemInventory[type] {
                            VStack(spacing: 4) {
                                GemIcon(type: type, grade: .normal, size: 30)
                                Text(type.gemName)
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.7))
                                ForEach(GemGrade.allCases) { grade in
                                    let count = grades[grade, default: 0]
                                    if count > 0 {
                                        Text("\(grade.symbol) ×\(count)")
                                            .font(.caption2)
                                            .foregroundStyle(type.color)
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - 宝石列表
    private var gemList: some View {
        Group {
            if filteredGems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "cube.box")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("宝盒空空如也")
                        .foregroundStyle(.white.opacity(0.5))
                    Text("快去获得第一颗宝石吧！")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredGems) { gem in
                        NavigationLink {
                            GemDetailView(gem: gem)
                        } label: {
                            GemCard(gem: gem)
                        }
                        .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    modelContext.delete(gem)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}
