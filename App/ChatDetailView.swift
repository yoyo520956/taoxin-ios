import SwiftUI

struct DemoChatDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var ui: UIState
    @State private var session: Session
    @State private var draft = ""
    @State private var replyIdx = 0

    init(session: Session) {
        _session = State(initialValue: session)
    }

    var body: some View {
        VStack(spacing: 0) {
            messageList
            InputBar(draft: $draft, onSend: send)
        }
        .background(Color.wxBg)
        .navigationTitle(session.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image("ic_back").wxIcon(20)
                }
            }
        }
        .toolbarBackground(Color.wxBg, for: .navigationBar)
        .onAppear { ui.hideTabBar = true }
        .onDisappear { ui.hideTabBar = false }
    }

    // MARK: 消息列表

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(session.msgs) { m in
                        MsgRow(msg: m, peerAvatar: session.avatar)
                            .id(m.id)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
            .background(Color.wxBg)
            .onChange(of: session.msgs.count) { _ in
                if let last = session.msgs.last {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if let last = session.msgs.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: 发送 + 自动回复

    private func send() {
        let t = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        draft = ""
        session.msgs.append(Msg(fromMe: true, kind: .text, text: t, time: DemoData.hhmm(0)))
        let reply = DemoData.autoReplies[replyIdx % DemoData.autoReplies.count]
        replyIdx += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            session.msgs.append(Msg(fromMe: false, kind: .text, text: reply, time: DemoData.hhmm(0)))
        }
    }
}

// MARK: - 底部输入栏

struct InputBar: View {
    @Binding var draft: String
    var onSend: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image("ic_voice").wxIcon(24)

            TextField("说点什么…", text: $draft)
                .font(.system(size: 16))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white)
                )

            if draft.isEmpty {
                Image("ic_emoji").wxIcon(24)
                Image("ic_plus").wxIcon(24)
            } else {
                Button(action: onSend) {
                    Text("发送")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.wxGreen))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 7)
        .padding(.bottom, 9)
        .background(
            Color(hex: 0xF7F7F7)
                .overlay(Rectangle().fill(Color.wxSep).frame(height: 0.6), alignment: .top)
        )
    }
}
