import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @EnvironmentObject private var chatCore: ChatCore
    @Environment(\.dismiss) private var dismiss
    @State private var nickname = ""
    @State private var avatarAsset = ""
    @State private var customImage: UIImage? = nil
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var saved = false

    private let avatarAssets = ["av_me", "av_1", "av_2", "av_3", "av_4", "av_5", "av_6", "av_7"]

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    avatarPreview
                    VStack(alignment: .leading, spacing: 6) {
                        Text("头像与昵称")
                            .font(.system(size: 16, weight: .medium))
                        Text("保存后会向附近的人重新广播名片")
                            .font(.system(size: 12))
                            .foregroundColor(.wxGray)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("昵称") {
                TextField("昵称（12 字以内）", text: $nickname)
                    .font(.system(size: 16))
                    .onChange(of: nickname) { v in
                        if v.count > 12 { nickname = String(v.prefix(12)) }
                    }
            }

            Section("头像") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                    ForEach(avatarAssets, id: \.self) { a in
                        cell(asset: a)
                    }
                    photoCell
                }
                .padding(.vertical, 6)
            }

            Section {
                Button(action: save) {
                    HStack {
                        Spacer()
                        Text(saved ? "已保存 ✓" : "保存")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(canSave ? Color.wxGreen : Color(hex: 0xA8E6C3))
                .disabled(!canSave)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.wxBg)
        .navigationTitle("编辑资料")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.wxBg, for: .navigationBar)
        .onAppear(loadCurrent)
        .onDisappear {
            if saved, let p = Store.loadProfile() {
                chatCore.restart(with: p)
            }
        }
    }

    private var canSave: Bool {
        !nickname.trimmingCharacters(in: .whitespaces).isEmpty && (customImage != nil || !avatarAsset.isEmpty)
    }

    private var avatarPreview: some View {
        Group {
            if let img = customImage {
                Image(uiImage: img).resizable().scaledToFill()
            } else if !avatarAsset.isEmpty {
                Image(avatarAsset).resizable().scaledToFill()
            } else {
                Color(hex: 0xA8D8B9)
            }
        }
        .frame(width: 62, height: 62)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func cell(asset: String) -> some View {
        Button {
            avatarAsset = asset
            customImage = nil
        } label: {
            Image(asset)
                .resizable().scaledToFill()
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9)
                    .strokeBorder(selected(asset) ? Color.wxGreen : .clear, lineWidth: 3))
        }
    }

    @ViewBuilder
    private var photoCell: some View {
        PhotosPicker(selection: $photoItem, matching: .images) {
            Group {
                if let img = customImage {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    VStack(spacing: 4) {
                        Image("ic_plus").wxIcon(16)
                        Text("相册").font(.system(size: 10)).foregroundColor(.wxGray)
                    }
                    .frame(width: 58, height: 58)
                    .background(Color.white)
                }
            }
            .frame(width: 58, height: 58)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .overlay(RoundedRectangle(cornerRadius: 9)
                .strokeBorder(customImage != nil ? Color.wxGreen : Color.wxSep, lineWidth: customImage != nil ? 3 : 1))
        }
        .onChange(of: photoItem) { item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    await MainActor.run {
                        customImage = img
                        avatarAsset = ""
                    }
                }
            }
        }
    }

    private func selected(_ a: String) -> Bool {
        customImage == nil && avatarAsset == a
    }

    private func loadCurrent() {
        guard let p = Store.loadProfile() else { return }
        nickname = p.nickname
        avatarAsset = p.avatarAsset
        if p.customAvatar { customImage = Store.shared.loadImage("ava_self.jpg") }
    }

    private func save() {
        let nick = nickname.trimmingCharacters(in: .whitespaces)
        guard !nick.isEmpty, var p = Store.loadProfile() else { return }
        p.nickname = nick
        p.avatarAsset = avatarAsset
        p.customAvatar = false
        if let img = customImage {
            let small = Store.downscale(img, maxDim: 300)
            if let d = small.jpegData(compressionQuality: 0.6) {
                _ = Store.shared.cacheImage(d, name: "ava_self.jpg")
                p.customAvatar = true
            }
        }
        Store.saveProfile(p)
        saved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { dismiss() }
    }
}

