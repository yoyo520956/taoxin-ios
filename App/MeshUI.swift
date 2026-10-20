import SwiftUI
import UIKit

// MARK: - 路由

struct RealRoute: Hashable { var uid: String }

// MARK: - 真实头像（缓存文件 or 首字符占位）

struct RealAvatarView: View {
    var uid: String
    var nickname: String
    var size: CGFloat

    var body: some View {
        ZStack {
            if let url = Store.shared.avatarFileURL(uid: uid),
               let img = UIImage(contentsOfFile: url.path) {
                Image(uiImage: img).resizable().scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: max(4, size * 0.12))
                    .fill(Color(hex: 0xA8D8B9))
                Text(String(nickname.prefix(1)))
                    .font(.system(size: size * 0.42, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: max(4, size * 0.12)))
    }
}

// MARK: - 本机头像

struct MyAvatarView: View {
    var profile: MyProfile
    var size: CGFloat

    var body: some View {
        Group {
            if profile.customAvatar, let img = Store.shared.loadImage("ava_self.jpg") {
                Image(uiImage: img).resizable().scaledToFill()
            } else if !profile.avatarAsset.isEmpty {
                Image(profile.avatarAsset).resizable().scaledToFill()
            } else {
                Color(hex: 0xA8D8B9)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: max(4, size * 0.12)))
    }
}
