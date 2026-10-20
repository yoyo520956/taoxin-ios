import SwiftUI

struct SettingsView: View {
    @State private var speaker = false
    @State private var youth = false

    var body: some View {
        List {
            Section {
                row("账号与安全")
                Toggle("听筒模式", isOn: $speaker)
            }

            Section {
                Toggle("青少年模式", isOn: $youth)
                row("消息通知")
                row("隐私")
                row("通用")
            }

            Section {
                row("帮助与反馈")
                NavigationLink {
                    about
                } label: {
                    row("关于桃信")
                }
            }

            Section {
                HStack {
                    Spacer()
                    Text("清空聊天记录")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0xFA5151))
                    Spacer()
                }
                .contentShape(Rectangle())
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.wxBg)
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.wxBg, for: .navigationBar)
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
            Text("Version 1.0.0 (20261020.01)")
                .font(.system(size: 13))
                .foregroundColor(.wxGray)
            Text("一颗软软的聊天桃子 · 全部图标 AI 原创生成")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0xB2B2B2))
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
