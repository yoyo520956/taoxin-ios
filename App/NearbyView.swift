import SwiftUI

struct NearbyView: View {
    @EnvironmentObject private var chatCore: ChatCore

    private var users: [NearbyUser] {
        chatCore.nearby.values.sorted { a, b in
            if a.connected != b.connected { return a.connected }
            return a.peerName < b.peerName
        }
    }

    var body: some View {
        List {
            Section {
                if users.isEmpty {
                    VStack(spacing: 10) {
                        Image("tab_contacts").wxIcon(40).opacity(0.35)
                        Text("正在搜索附近的人…")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.wxText)
                        Text("让朋友也装上桃信并保持打开，就会出现在这里。\n同一 Wi-Fi 或蓝牙范围内即可，无需联网。")
                            .font(.system(size: 12))
                            .foregroundColor(.wxGray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 26)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(users) { u in
                        NavigationLink(value: RealRoute(uid: u.uid)) {
                            row(u)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            if !u.connected { chatCore.invite(peerName: u.peerName) }
                        })
                        .listRowSeparator(.hidden)
                    }
                }
            } header: {
                if !users.isEmpty {
                    Text("同时在线 \(users.filter(\.connected).count) / 发现 \(users.count)")
                        .font(.system(size: 13))
                        .foregroundColor(.wxGray)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.wxBg)
        .navigationTitle("附近")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.wxBg, for: .navigationBar)
        .navigationDestination(for: RealRoute.self) { r in
            RealChatDetailView(uid: r.uid)
        }
    }

    @ViewBuilder
    private func row(_ u: NearbyUser) -> some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                RealAvatarView(uid: u.uid, nickname: u.peerName, size: 44)
                Circle()
                    .fill(u.connected ? Color.wxGreen : Color(hex: 0xC8C8C8))
                    .frame(width: 11, height: 11)
                    .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
                    .offset(x: 2, y: 2)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(u.peerName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.wxText)
                Text(u.connected ? "在线 · 点击直接开聊" : "发现 · 连接中…")
                    .font(.system(size: 12))
                    .foregroundColor(u.connected ? Color.wxGreen : .wxGray)
            }
            Spacer()
        }
        .padding(.vertical, 3)
        .contentShape(Rectangle())
    }
}
