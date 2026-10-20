import SwiftUI
import PhotosUI

struct RealChatDetailView: View {
    var uid: String
    @EnvironmentObject private var chatCore: ChatCore
    @EnvironmentObject private var ui: UIState
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var photoItem: PhotosPickerItem? = nil

    private var chat: RealChat? { chatCore.chats[uid] }
    private var peerName: String {
        chat?.peer.nickname ?? chatCore.uidToPeer[uid] ?? "连接中…"
    }
    private var isOnline: Bool {
        guard let name = chatCore.uidToPeer[uid] else { return false }
        return chatCore.onlinePeers.contains(name)
    }

    var body: some View {
        VStack(spacing: 0) {
            if !isOnline && (chat?.msgs.isEmpty ?? true) {
                connecting
            } else {
                messageList
            }
            inputBar
        }
        .background(Color.wxBg)
        .navigationTitle(peerName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: { Image("ic_back").wxIcon(20) }
            }
        }
        .toolbarBackground(Color.wxBg, for: .navigationBar)
        .onAppear {
            ui.hideTabBar = true
            chatCore.activeChatUID = uid
            chatCore.markRead(uid: uid)
        }
        .onDisappear {
            ui.hideTabBar = false
            chatCore.activeChatUID = nil
        }
        .onChange(of: chatCore.unread[uid] ?? 0) { v in
            if v > 0 { chatCore.markRead(uid: uid) }
        }
    }

    private var connecting: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView().tint(.wxGreen)
            Text("正在建立直连通道…")
                .font(.system(size: 14))
                .foregroundColor(.wxGray)
            Text("双方需保持桃信打开且在同一 Wi-Fi / 蓝牙范围")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: 0xB2B2B2))
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.wxBg)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(chat?.msgs ?? []) { m in
                        realRow(m)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
            .background(Color.wxBg)
            .onChange(of: chat?.msgs.count ?? 0) { _ in
                if let last = chat?.msgs.last {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if let last = chat?.msgs.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    @ViewBuilder
    private func realRow(_ m: RealMsg) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if m.fromMe { Spacer(minLength: 64) }
            if !m.fromMe {
                RealAvatarView(uid: uid, nickname: peerName, size: 38)
            }
            VStack(alignment: m.fromMe ? .trailing : .leading, spacing: 3) {
                bubble(m)
                if m.fromMe && m.status == "failed" {
                    Text("未送达 · 对方可能不在线")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xFA5151))
                }
            }
            if m.fromMe {
                MyAvatarView(profile: chatCore.profile ?? MyProfile(uid: uid, nickname: "我", avatarAsset: "av_me", customAvatar: false), size: 38)
            }
            if !m.fromMe { Spacer(minLength: 64) }
        }
    }

    @ViewBuilder
    private func bubble(_ m: RealMsg) -> some View {
        let fill: Color = m.fromMe ? .wxBubble : .white
        if m.kind == "img" {
            Group {
                if let img = Store.shared.loadImage(m.text) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 170)
                        .frame(maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: 0xE0E0E0))
                        .frame(width: 140, height: 100)
                }
            }
        } else {
            Text(m.text)
                .font(.system(size: 16))
                .foregroundColor(.wxText)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(fill)
                .wxBubbleClip(6, tail: m.fromMe, fill: fill)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                Image("ic_plus").wxIcon(24)
            }
            .onChange(of: photoItem) { item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        await MainActor.run {
                            chatCore.sendImage(uid: uid, img)
                        }
                    }
                    await MainActor.run { photoItem = nil }
                }
            }

            TextField("说点什么…", text: $draft)
                .font(.system(size: 16))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.white))
                .onSubmit(send)

            Button(action: send) {
                Text("发送")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(RoundedRectangle(cornerRadius: 5).fill(draft.isEmpty ? Color(hex: 0xA8E6C3) : Color.wxGreen))
            }
            .disabled(draft.isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.top, 7)
        .padding(.bottom, 9)
        .background(
            Color(hex: 0xF7F7F7)
                .overlay(Rectangle().fill(Color.wxSep).frame(height: 0.6), alignment: .top)
        )
    }

    private func send() {
        chatCore.sendText(uid: uid, draft)
        draft = ""
    }
}
