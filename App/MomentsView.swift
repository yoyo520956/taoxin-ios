import SwiftUI

struct MomentsView: View {
    @State private var posts = DemoData.posts
    private let myName = DemoData.me.name

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                cover
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(posts.enumerated()), id: \.element.id) { i, post in
                        PostRow(post: post, myName: myName) { who in
                            toggleLike(post)
                        }
                        if i < posts.count - 1 {
                            Rectangle().fill(Color.wxSep).frame(height: 0.6)
                                .padding(.leading, 62)
                        }
                    }
                }
                .padding(.top, 44)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white)
        .navigationTitle("朋友圈")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("dc_moments").wxIcon(20)
            }
        }
    }

    private var cover: some View {
        Image("p_cover")
            .resizable()
            .scaledToFill()
            .frame(height: 270)
            .clipped()
            .overlay(alignment: .bottomTrailing) {
                HStack(spacing: 10) {
                    Text(myName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                    AvatarView(asset: DemoData.me.avatar, size: 64)
                }
                .padding(.trailing, 14)
                .offset(y: 26)
            }
            .zIndex(1)
    }

    private func toggleLike(_ post: Post) {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else { return }
        if let i = posts[idx].liked.firstIndex(of: myName) {
            posts[idx].liked.remove(at: i)
        } else {
            posts[idx].liked.append(myName)
        }
    }
}

// MARK: - 单条朋友圈

struct PostRow: View {
    var post: Post
    var myName: String
    var onLike: (String) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(asset: post.avatar, size: 42)
                .padding(.top, 10)

            VStack(alignment: .leading, spacing: 8) {
                Text(post.who)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.wxLink)
                    .padding(.top, 10)

                Text(post.text)
                    .font(.system(size: 15))
                    .foregroundColor(.wxText)

                imageGrid

                actionRow

                if !post.liked.isEmpty || !post.comments.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        if !post.liked.isEmpty {
                            HStack(spacing: 6) {
                                Image("me_favorites").wxIcon(13)
                                Text(post.liked.joined(separator: "、"))
                                    .font(.system(size: 13))
                                    .foregroundColor(.wxLink)
                                    .lineLimit(3)
                            }
                        }
                        ForEach(post.comments) { c in
                            (Text(c.who).foregroundColor(.wxLink)
                             + Text("：" + c.text).foregroundColor(.wxText))
                                .font(.system(size: 13))
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 4).fill(Color(hex: 0xF7F7F7)))
                    .padding(.bottom, 12)
                } else {
                    EmptyView()
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.trailing, 14)
    }

    @ViewBuilder
    private var imageGrid: some View {
        if post.images.count == 1 {
            Image(post.images[0])
                .resizable()
                .scaledToFill()
                .frame(width: 170, height: 128)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else if post.images.count > 1 {
            HStack(spacing: 4) {
                ForEach(post.images, id: \.self) { img in
                    Image(img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 84, height: 84)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 14) {
            Text(post.time)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0xB2B2B2))
            Spacer()
            Button {
                onLike(post.who)
            } label: {
                HStack(spacing: 4) {
                    Image("me_favorites").wxIcon(12)
                    Text(post.liked.contains(myName) ? "已赞" : "赞")
                        .font(.system(size: 12))
                }
                .foregroundColor(post.liked.contains(myName) ? .wxGreen : .wxGray)
            }
            HStack(spacing: 4) {
                Image("ic_emoji").wxIcon(12)
                Text("评论").font(.system(size: 12))
            }
            .foregroundColor(.wxGray)
        }
    }
}
