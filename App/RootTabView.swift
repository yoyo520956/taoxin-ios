import SwiftUI

enum AppTab: Int, CaseIterable {
    case chats, contacts, discover, me
}

struct RootTabView: View {
    @State private var tab: AppTab = .chats
    @StateObject private var ui = UIState()

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch tab {
                case .chats:    NavigationStack { ChatsView() }
                case .contacts: NavigationStack { ContactsView() }
                case .discover: NavigationStack { DiscoverView() }
                case .me:       NavigationStack { MeView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !ui.hideTabBar {
                TabBarView(tab: $tab)
                    .transition(.move(edge: .bottom))
            }
        }
        .environmentObject(ui)
        .animation(.easeInOut(duration: 0.18), value: ui.hideTabBar)
    }
}

// MARK: - TabBar（微信样式：白底 + 细线 + 图标/文字）

struct TabBarView: View {
    @Binding var tab: AppTab
    @EnvironmentObject var ui: UIState
    @State private var unreadTotal = 15

    var body: some View {
        HStack(spacing: 0) {
            item(.chats, "tab_chats", "tab_chats_on", "微信", unreadTotal)
            item(.contacts, "tab_contacts", "tab_contacts_on", "通讯录", 0)
            item(.discover, "tab_discover", "tab_discover_on", "发现", 0)
            item(.me, "tab_me", "tab_me_on", "我", 0)
        }
        .padding(.top, 7)
        .padding(.bottom, 4)
        .background(
            Color.white
                .overlay(Rectangle().fill(Color.wxSep).frame(height: 0.6), alignment: .top)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    @ViewBuilder
    private func item(_ t: AppTab, _ off: String, _ on: String, _ label: String, _ badge: Int) -> some View {
        Button {
            tab = t
        } label: {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    let selected = tab == t
                    (Image(selected ? on : off))
                        .wxIcon(26)
                        .frame(width: 34, height: 28)
                    if badge > 0 {
                        BadgeView(count: badge)
                            .offset(x: 8, y: -6)
                    }
                }
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(tab == t ? .wxGreen : Color(hex: 0x7C7C7C))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
