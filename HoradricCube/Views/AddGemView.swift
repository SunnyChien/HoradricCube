import SwiftUI
import SwiftData
import PhotosUI

/// 获得宝石页面 - 第一步：选择宝石类型和等级
struct AddGemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: GemType = .sports
    @State private var selectedGrade: GemGrade = .chipped
    @State private var showConfirm = false

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

                        // 领取按钮
                        claimButton
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
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showConfirm) {
                ClaimGemView(type: selectedType, grade: selectedGrade)
            }
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

    // MARK: - 领取按钮
    private var claimButton: some View {
        Button {
            showConfirm = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text("领取这颗宝石")
                    .font(.title3.bold())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [selectedType.color, selectedType.color.opacity(0.7)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: selectedType.color.opacity(0.4), radius: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 领取确认弹窗
struct ClaimGemView: View {
    let type: GemType
    let grade: GemGrade

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var reason = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoUIImage: UIImage?
    @State private var photoData: Data?

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 宝石预览
                        VStack(spacing: 8) {
                            GemIcon(type: type, grade: grade, size: 64)
                            Text("\(type.gemName) · \(grade.displayName)")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 8)

                        // 获得原因
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

                        // 上传照片
                        VStack(alignment: .leading, spacing: 8) {
                            Text("成果展示")
                                .font(.headline)
                                .foregroundStyle(.white)

                            photoSection
                        }

                        // 存入宝盒按钮
                        Button {
                            saveGem()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "cube.box")
                                Text("存入宝盒")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                reason.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.gray.opacity(0.3)
                                : type.color
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(reason.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("领取宝石")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        photoData = data
                        photoUIImage = UIImage(data: data)
                    }
                }
            }
        }
    }

    // MARK: - 照片区
    private var photoSection: some View {
        VStack(spacing: 12) {
            if let uiImage = photoUIImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            photoUIImage = nil
                            photoData = nil
                            selectedPhoto = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .background(Circle().fill(.black.opacity(0.5)))
                        }
                        .padding(6)
                    }
            }

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                HStack {
                    Image(systemName: photoUIImage == nil ? "photo.badge.plus" : "photo.on.rectangle.angled")
                    Text(photoUIImage == nil ? "添加照片" : "更换照片")
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - 保存
    private func saveGem() {
        let gem = Gem(
            type: type,
            grade: grade,
            reason: reason.trimmingCharacters(in: .whitespaces),
            photoData: photoData
        )
        modelContext.insert(gem)
        dismiss()
    }
}
