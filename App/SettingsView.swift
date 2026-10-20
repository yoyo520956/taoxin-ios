import SwiftUI

struct SettingsView: View {
    @State private var speaker = false
    @EnvironmentObject private var chatCore: ChatCore
    @State private var confirmLogout = false

    var body: some View {
        List {
            Section {
                row("账号与安全")
                Toggle("听筒模式", isOn: $speaker)
            }

            Section {
                row("消息通知")
                row("隐私")
                row("通用")
            }

            Section {
                NavigationLink {
                    about
                } label: {
                    row("关于桃信")
                }
            }

            Section {
                HStack {
                    Spacer()
                    Text("退出登录")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: 0xFA5151))
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { confirmLogout = true }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.wxBg)
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.wxBg, for: .navigationBar)
        .alert("退出登录", isPresented: $confirmLogout) {
            Button("取消", role: .cancel) {}
            Button("退出", role: .destructive) { logout() }
        } message: {
            Text("聊天记录仍保留在本机，重新登录后可见")
        }
    }

    private func logout() {
        chatCore.stop()
        Store.clearAccount()
    }

    private var about: some View {
        VStack(spacing: 18) {
            Image("p_appicon")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .padding(.top, 60)
            Text("桃信")
                .font(.system(size: 22, weight: .semibold))
            Text("Version 2.0.0 (20261020.02)")
                .font(.system(size: 13))
                .foregroundColor(.wxGray)
            Text("局域网真聊天 · 设备直连不经过服务器\n全部图标 AI 原创生成")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0xB2B2B2))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.wxBg)
    }

    @ViewBuilder
    private func row(_ title: String) -> some View {
        HStack {
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
