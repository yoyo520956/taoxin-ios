import SwiftUI

// MARK: - 气泡小尾巴（左右镜像复用）

struct BubbleTail: Shape {
    var right: Bool

    func path(in rect: CGRect) -> Path {
        var p = Path()
        if right {
            p.move(to: CGPoint(x: 0, y: 0))
            p.addLine(to: CGPoint(x: rect.width, y: 0))
            p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        } else {
            p.move(to: CGPoint(x: rect.width, y: 0))
            p.addLine(to: CGPoint(x: 0, y: 0))
            p.addLine(to: CGPoint(x: 0, y: rect.height))
        }
        p.closeSubpath()
        return p
    }
}

// MARK: - 消息行

struct MsgRow: View {
    var msg: Msg
    var peerAvatar: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if msg.fromMe { Spacer(minLength: 64) }

            if !msg.fromMe {
                AvatarView(asset: peerAvatar, size: 40)
                bubble
            }
            if msg.fromMe {
                bubble
                AvatarView(asset: "av_me", size: 40)
            }

            if !msg.fromMe { Spacer(minLength: 64) }
        }
    }

    @ViewBuilder
    private var bubble: some View {
        switch msg.kind {
        case .text:
            Text(msg.text)
                .font(.system(size: 16))
                .foregroundColor(.wxText)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(bubbleColor)
                .wxBubbleClip(6, tail: msg.fromMe, fill: bubbleColor)
        case .voice:
            HStack(spacing: 6) {
                if msg.fromMe {
                    Text("6″").font(.system(size: 15)).foregroundColor(.wxText)
                    Image("ic_voice").wxIcon(16)
                } else {
                    Image("ic_voice").wxIcon(16)
                    Text(msg.text).font(.system(size: 15)).foregroundColor(.wxText)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .frame(minWidth: 88)
            .background(bubbleColor)
            .wxBubbleClip(6, tail: msg.fromMe, fill: bubbleColor)
        case .image:
            Image(msg.text)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        case .redpacket:
            HStack(spacing: 10) {
                Image("ic_redpacket").wxIcon(30)
                VStack(alignment: .leading, spacing: 3) {
                    Text(msg.text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    Text("桃信红包")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.75))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minWidth: 190, alignment: .leading)
            .background(
                LinearGradient(colors: [Color(hex: 0xF77B4C), Color(hex: 0xF0492F)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .wxBubbleClip(6, tail: msg.fromMe, fill: Color(hex: 0xF0492F))
        }
    }

    private var bubbleColor: Color {
        msg.fromMe ? .wxBubble : .white
    }
}

extension View {
    /// 圆角 + 消息小尾巴（尾巴颜色需与气泡底色一致，显式传入）
    @ViewBuilder
    func wxBubbleClip(_ r: CGFloat, tail right: Bool, fill: Color) -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: r))
            .overlay(
                BubbleTail(right: right)
                    .fill(fill)
                    .frame(width: 6, height: 11)
                    .offset(x: right ? 5.5 : -5.5, y: 0),
                alignment: right ? .topTrailing : .topLeading
            )
    }
}
