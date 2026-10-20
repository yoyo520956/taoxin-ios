import SwiftUI

struct DiscoverView: View {
    var body: some View {
        List {
            Section {
                navRow("dc_moments", "朋友圈") { MomentsView() }
            }

            Section {
                navRow("dc_channels", "视频号") { PlaceholderView(title: "视频号") }
                navRow("dc_live", "直播") { PlaceholderView(title: "直播") }
            }

            Section {
                navRow("dc_scan", "扫一扫") { PlaceholderView(title: "扫一扫") }
                navRow("dc_shake", "摇一摇") { PlaceholderView(title: "摇一摇") }
                navRow("dc_look", "看一看") { PlaceholderView(title: "看一看") }
                navRow("dc_search2", "搜一搜") { PlaceholderView(title: "搜一搜") }
            }

            Section {
                navRow("dc_nearby", "附近") { PlaceholderView(title: "附近") }
                navRow("dc_shop", "购物") { PlaceholderView(title: "购物") }
                navRow("dc_game", "游戏") { PlaceholderView(title: "游戏") }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.wxBg)
        .navigationTitle("发现")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.wxBg, for: .navigationBar)
    }

    @ViewBuilder
    private func navRow<D: View>(_ icon: String, _ title: String, @ViewBuilder dest: @escaping () -> D) -> some View {
        NavigationLink {
            dest()
        } label: {
            RowItem(icon: icon, title: title)
                .padding(.vertical, 1)
        }
    }
}
