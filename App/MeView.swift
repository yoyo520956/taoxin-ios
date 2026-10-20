import SwiftUI

struct MeView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    ProfileView(friend: DemoData.me)
                } label: {
                    HStack(spacing: 14) {
                        AvatarView(asset: DemoData.me.avatar, size: 62)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(DemoData.me.name)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.wxText)
                            Text("微信号：\(DemoData.me.wxid)")
                                .font(.system(size: 13))
                                .foregroundColor(.wxGray)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                .listRowSeparator(.hidden)
            }

            Section {
                NavigationLink { PlaceholderView(title: "服务") } label: {
                    RowItem(icon: "me_services", title: "服务")
                }
            }

            Section {
                NavigationLink { MomentsView() } label: {
                    RowItem(icon: "dc_moments", title: "朋友圈")
                }
                NavigationLink { PlaceholderView(title: "收藏") } label: {
                    RowItem(icon: "me_favorites", title: "收藏")
                }
                NavigationLink { PlaceholderView(title: "卡包") } label: {
                    RowItem(icon: "me_wallet", title: "卡包")
                }
                NavigationLink { PlaceholderView(title: "表情") } label: {
                    RowItem(icon: "me_stickers", title: "表情")
                }
            }

            Section {
                NavigationLink { SettingsView() } label: {
                    RowItem(icon: "me_settings", title: "设置")
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.wxBg)
        .navigationTitle("我")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.wxBg, for: .navigationBar)
    }
}
