import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @State private var nickname = ""
    @State private var avatarAsset = "av_me"
    @State private var customImage: UIImage? = nil
    @State private var photoItem: PhotosPickerItem? = nil
    @EnvironmentObject private var chatCore: ChatCore
    @State private var hasProfile = UserDefaults.standard.bool(forKey: Store.hasProfileKey)

    private let avatarAssets = ["av_me", "av_1", "av_2", "av_3", "av_4", "av_5", "av_6", "av_7"]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 14) {
                Image("p_appicon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .wxGreen.opacity(0.25), radius: 12, y: 6)
                Text("桃信")
                    .font(.system(size: 26, weight: .bold))
                Text("局域网真聊天 · 不经过任何服务器")
                    .font(.system(size: 13))
                    .foregroundColor(.wxGray)
            }
            .padding(.top, 60)

            VStack(alignment: .leading, spacing: 10) {
                Text("给自己起个名字")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.wxGray)
                TextField("昵称（12 字以内）", text: $nickname)
                    .font(.system(size: 17))
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    .onChange(of: nickname) { v in
                        if v.count > 12 { nickname = String(v.prefix(12)) }
                    }
            }
            .padding(.horizontal, 28)
            .padding(.top, 36)

            VStack(alignment: .leading, spacing: 10) {
                Text("挑一张头像")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.wxGray)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(avatarAssets, id: \.self) { a in
                        avatarCell(asset: a)
                    }
                    photoCell
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 22)

            Spacer()

            Button(action: start) {
                Text("进入桃信")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(RoundedRectangle(cornerRadius: 12).fill(canStart ? Color.wxGreen : Color(hex: 0xA8E6C3)))
            }
            .disabled(!canStart)
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.wxBg.ignoresSafeArea())
    }

    private var canStart: Bool {
        !nickname.trimmingCharacters(in: .whitespaces).isEmpty && (customImage != nil || !avatarAsset.isEmpty)
    }

    @ViewBuilder
    private func avatarCell(asset: String) -> some View {
        Button {
            avatarAsset = asset
            customImage = nil
        } label: {
            Image(asset)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(selected(asset: asset) ? Color.wxGreen : .clear, lineWidth: 3)
                )
        }
    }

    @ViewBuilder
    private var photoCell: some View {
        PhotosPicker(selection: $photoItem, matching: .images) {
            Group {
                if let img = customImage {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                } else {
                    VStack(spacing: 4) {
                        Image("ic_plus").wxIcon(18)
                        Text("相册").font(.system(size: 10)).foregroundColor(.wxGray)
                    }
                    .frame(width: 64, height: 64)
                    .background(Color.white)
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(customImage != nil ? Color.wxGreen : Color.wxSep, lineWidth: customImage != nil ? 3 : 1)
            )
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

    private func selected(asset: String) -> Bool {
        customImage == nil && avatarAsset == asset
    }

    private func start() {
        let nick = nickname.trimmingCharacters(in: .whitespaces)
        guard !nick.isEmpty else { return }
        var profile = MyProfile(uid: Store.myUID(), nickname: nick, avatarAsset: avatarAsset, customAvatar: false)
        if let img = customImage {
            let small = Store.downscale(img, maxDim: 300)
            if let d = small.jpegData(compressionQuality: 0.6) {
                _ = Store.shared.cacheImage(d, name: "ava_self.jpg")
                profile.customAvatar = true
            }
        }
        Store.saveProfile(profile)
        chatCore.start(with: profile)
        UserDefaults.standard.set(true, forKey: Store.hasProfileKey)
        hasProfile = true
    }
}
