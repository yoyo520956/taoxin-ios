import SwiftUI

struct ProfileView: View {
    var friend: Friend

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    AvatarView(asset: friend.avatar, size: 62)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(friend.name)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.wxText)
                        Text("微信号：\(friend.wxid)")
                            .font(.system(size: 13))
                            .foregroundColor(.wxGray)
                        Text("地区：\(friend.region)")
                            .font(.system(size: 13))
                            .foregroundColor(.wxGray)
                    }
                    Spacer()
                }
                .padding(.vertical, 6)
                .listRowSeparator(.hidden)
            }

            Section {
                row("设置备注和标签")
                row("朋友权限")
            }

            Section {
                row("朋友圈")
                row("更多信息")
            }

            Section {
                HStack {
                    Spacer()
                    Text("发消息")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 10)
                .listRowBackground(Color.wxGreen)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.wxBg)
        .navigationTitle(friend.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.wxBg, for: .navigationBar)
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
