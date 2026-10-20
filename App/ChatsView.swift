import SwiftUI

struct ChatsView: View {
    @State private var sessions = DemoData.sessions

    var body: some View {
        List {
            ForEach(Array(sessions.enumerated()), id: \.element.id) { i, s in
                NavigationLink(value: s) {
                    ChatRow(session: s)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.white)
                .listRowInsets(EdgeInsets())
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
        .navigationDestination(for: Session.self) { s in
            ChatDetailView(session: s)
        }
        .onAppear {
            // 从聊天页回来时清空该会话未读（简化：全部清空）
        }
    }
}

// MARK: - 会话行

struct ChatRow: View {
    var session: Session

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                AvatarView(asset: session.avatar, size: 48)
                    .padding(.leading, 14)
                    .padding(.top, 10)
                if session.unread > 0 {
                    BadgeView(count: session.unread, muted: session.muted)
                        .offset(x: 6, y: -4)
                }
            }
            .frame(width: 72)

            VStack(alignment: .leading, spacing: 5) {
                Text(session.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.wxText)
                    .lineLimit(1)
                Text(session.preview)
                    .font(.system(size: 14))
                    .foregroundColor(.wxGray)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 6) {
                Text(session.time)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0xB2B2B2))
                if session.muted {
                    Image("ic_voice")
                        .wxIcon(13)
                        .opacity(0.35)
                }
            }
            .padding(.top, 12)
            .padding(.trailing, 14)
        }
        .padding(.bottom, 10)
        .background(Color.white)
        .contentShape(Rectangle())
    }
}
