import SwiftUI

struct ChatsView: View {
    @EnvironmentObject private var chatCore: ChatCore

    private var realChats: [RealChat] {
        chatCore.chats.values.sorted { ($0.msgs.last?.ts ?? 0) > ($1.msgs.last?.ts ?? 0) }
    }

    var body: some View {
        List {
            if realChats.isEmpty {
                Section {
                    VStack(spacing: 8) {
                        Image("dc_nearby").wxIcon(34).opacity(0.8)
                        Text("还没有真实会话")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.wxText)
                        Text("去「附近」找同时打开桃信的朋友，\n消息在设备之间直达，不经过服务器")
                            .font(.system(size: 12))
                            .foregroundColor(.wxGray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .listRowSeparator(.hidden)
                }
            } else {
                Section {
                    ForEach(realChats) { chat in
                        NavigationLink(value: RealRoute(uid: chat.peer.uid)) {
                            RealChatRow(chat: chat)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.white)
                        .listRowInsets(EdgeInsets())
                    }
                }
            }

            Section {
                ForEach(Array(DemoData.sessions.enumerated()), id: \.element.id) { i, s in
                    NavigationLink(value: s) {
                        ChatRow(session: s)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.white)
                    .listRowInsets(EdgeInsets())
                }
            } header: {
                Text("示例会话")
                    .font(.system(size: 13))
                    .foregroundColor(.wxGray)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.wxBg)
        .navigationTitle("微信")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image("ic_search").wxIcon(19)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("ic_add").wxIcon(19)
            }
        }
        .toolbarBackground(Color.wxBg, for: .navigationBar)
        .navigationDestination(for: RealRoute.self) { r in
            RealChatDetailView(uid: r.uid)
        }
        .navigationDestination(for: Session.self) { s in
            DemoChatDetailView(session: s)
        }
    }
}

// MARK: - 真实会话行

struct RealChatRow: View {
    var chat: RealChat
    @EnvironmentObject private var chatCore: ChatCore

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RealAvatarView(uid: chat.peer.uid, nickname: chat.peer.nickname, size: 48)
                    .padding(.leading, 14)
                    .padding(.top, 10)
                let n = chatCore.unread[chat.peer.uid] ?? 0
                if n > 0 {
                    BadgeView(count: n)
                        .offset(x: 6, y: -4)
                }
            }
            .frame(width: 72)

            VStack(alignment: .leading, spacing: 5) {
                Text(chat.peer.nickname)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.wxText)
                    .lineLimit(1)
                Text(preview)
                    .font(.system(size: 14))
                    .foregroundColor(.wxGray)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 6) {
                Text(timeText)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0xB2B2B2))
                if !chatCore.onlinePeers.contains(chatCore.uidToPeer[chat.peer.uid] ?? "") {
                    Circle().fill(Color(hex: 0xD0D0D0)).frame(width: 7, height: 7)
                } else {
                    Circle().fill(Color.wxGreen).frame(width: 7, height: 7)
                }
            }
            .padding(.top, 12)
            .padding(.trailing, 14)
        }
        .padding(.bottom, 10)
        .background(Color.white)
        .contentShape(Rectangle())
    }

    private var preview: String {
        guard let m = chat.msgs.last else { return "" }
        if m.kind == "img" { return m.fromMe ? "[图片]" : "[图片]" }
        return (m.fromMe ? "" : "") + m.text
    }

    private var timeText: String {
        guard let ts = chat.msgs.last?.ts else { return "" }
        let d = Date(timeIntervalSince1970: ts)
        let f = DateFormatter()
        if Calendar.current.isDateInToday(d) {
            f.dateFormat = "HH:mm"
        } else {
            f.dateFormat = "MM-dd"
        }
        return f.string(from: d)
    }
}
