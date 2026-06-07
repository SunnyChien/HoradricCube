import SwiftUI
import SwiftData

/// 主界面：赫拉迪姆宝盒
struct CubeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Gem.createdAt, order: .reverse) private var gems: [Gem]
    @State private var showAddGem = false
    @State private var showCubeDetail = false
    @State private var cubeOpen = false

    /// 按类型统计宝石数量
    private var gemCountsByType: [GemType: Int] {
        Dictionary(grouping: gems, by: \.type).mapValues { $0.count }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f3460")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    // 标题
                    Text("Horadric Cube")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .shadow(color: .cyan.opacity(0.5), radius: 10)

                    Text("记录成长的每一颗宝石")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))

                    // 宝盒
                    cubeButton

                    // 宝石概览
                    gemOverview

                    // 获得宝石按钮
                    addGemButton
                }
                .padding()
            }
            .navigationDestination(isPresented: $showCubeDetail) {
                CubeDetailView()
            }
            .sheet(isPresented: $showAddGem) {
                AddGemView()
            }
        }
    }

    // MARK: - 宝盒按钮
    private var cubeButton: some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                cubeOpen.toggle()
            }
            if cubeOpen {
                // 短暂延迟后打开详情
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showCubeDetail = true
                    cubeOpen = false
                }
            }
        } label: {
            ZStack {
                // 宝盒外框
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "533a1b"), Color(hex: "8b6914"), Color(hex: "533a1b")],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 200, height: 160)
                    .shadow(color: .orange.opacity(0.4), radius: cubeOpen ? 20 : 8)

                // 宝盒盖子
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "8b6914"), Color(hex: "c9a227"), Color(hex: "8b6914")],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 200, height: 60)
                    .offset(y: cubeOpen ? -50 : -50)
                    .rotation3DEffect(
                        .degrees(cubeOpen ? -60 : 0),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .bottom
                    )

                // 宝盒内部光芒
                if cubeOpen {
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [.cyan.opacity(0.6), .cyan.opacity(0)],
                                center: .center,
                                startRadius: 10,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 60)
                        .offset(y: -10)
                }

                // 宝石数量
                VStack {
                    Image(systemName: "cube.box")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.9))
                    Text("\(gems.count) 颗宝石")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.top, 4)
                }
                .offset(y: 10)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - 获得宝石按钮
    private var addGemButton: some View {
        Button {
            showAddGem = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text("获得宝石")
                    .font(.title3.bold())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.cyan, Color.blue],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .cyan.opacity(0.4), radius: 8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 宝石概览
    private var gemOverview: some View {
        VStack(spacing: 12) {
            Text("宝石收藏")
                .font(.headline)
                .foregroundStyle(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(GemType.allCases) { type in
                    VStack(spacing: 4) {
                        GemIcon(type: type, grade: .chipped, size: 36)
                        Text(type.gemName)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                        Text("×\(gemCountsByType[type, default: 0])")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .bold()
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Color Hex 扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
