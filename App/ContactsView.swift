import SwiftUI

struct ContactsView: View {
    @State private var friends = DemoData.friends

    private let specials: [(String, String)] = [
        ("ct_newfriend", "新的朋友"),
        ("ct_group", "群聊"),
        ("ct_tag", "标签"),
        ("ct_official", "公众号"),
    ]

    private var grouped: [(String, [Friend])] {
        Dictionary(grouping: friends) { $0.letter }
            .sorted { $0.key < $1.key }
            .map { ($0.key, $0.value) }
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                Section {
                    ForEach(specials, id: \.0) { icon, name in
                        HStack(spacing: 12) {
                            Image(icon).wxIcon(30).frame(width: 34)
                            Text(name).font(.system(size: 16)).foregroundColor(.wxText)
                        }
                        .padding(.vertical, 2)
                        .listRowSeparator(.hidden)
                    }
                }

                ForEach(grouped, id: \.0) { sec in
                    Section {
                        ForEach(sec.1) { f in
                            NavigationLink(value: f) {
                                HStack(spacing: 12) {
                                    AvatarView(asset: f.avatar, size: 38)
                                    Text(f.name).font(.system(size: 16)).foregroundColor(.wxText)
                                }
                                .padding(.vertical, 1)
                            }
                        }
                        .listRowSeparator(.hidden)
                    } header: {
                        Text(sec.0)
                            .font(.system(size: 13))
                            .foregroundColor(.wxGray)
                            .id(sec.0)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.wxBg)
            .navigationTitle("通讯录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.wxBg, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image("ic_add").wxIcon(19)
                }
            }
            .navigationDestination(for: Friend.self) { f in
                ProfileView(friend: f)
            }
            .safeAreaInset(edge: .trailing) {
                IndexBar(letters: grouped.map(\.0)) { letter in
                    proxy.scrollTo(letter, anchor: .top)
                }
            }
        }
    }
}

// MARK: - 右侧字母索引条

struct IndexBar: View {
    var letters: [String]
    var onTap: (String) -> Void

    var body: some View {
        VStack(spacing: 3) {
            ForEach(letters, id: \.self) { l in
                Text(l)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.wxGray)
                    .frame(width: 20, height: 16)
                    .contentShape(Rectangle())
                    .onTapGesture { onTap(l) }
            }
        }
        .padding(.trailing, 2)
    }
}
