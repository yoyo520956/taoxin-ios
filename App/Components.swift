import SwiftUI

// MARK: - 全局 UI 状态（聊天页时隐藏 TabBar）

final class UIState: ObservableObject {
    @Published var hideTabBar = false
}

// MARK: - 头像

struct AvatarView: View {
    var asset: String
    var size: CGFloat

    var body: some View {
        Image(asset)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: max(4, size * 0.12)))
    }
}

// MARK: - 未读角标

struct BadgeView: View {
    var count: Int
    var muted: Bool = false

    var body: some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 5)
            .frame(minWidth: 17, minHeight: 17)
            .background(Capsule().fill(muted ? Color(hex: 0xB2B2B2) : Color(hex: 0xFA5151)))
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}

// MARK: - 通用行（发现页/我的页，AI 图标 + 右箭头复用 ic_back 旋转）

struct RowItem: View {
    var icon: String
    var title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(icon).wxIcon(26).frame(width: 30)
            Text(title).font(.system(size: 16)).foregroundColor(.wxText)
            Spacer()
            Image("ic_back")
                .wxIcon(13)
                .rotationEffect(.degrees(180))
                .opacity(0.35)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - 占位页

struct PlaceholderView: View {
    var title: String
    var body: some View {
        VStack(spacing: 14) {
            Image("p_appicon")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .opacity(0.9)
            Text("\(title) · 功能开发中")
                .font(.system(size: 15))
                .foregroundColor(.wxGray)
            Text("先用下面的功能打发一下时间吧～")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0xB2B2B2))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.wxBg)
    }
}
