import SwiftUI

// MARK: - 数据模型

struct Msg: Identifiable, Hashable {
    let id = UUID()
    var fromMe: Bool
    var kind: MsgKind
    var text: String
    var time: String
    enum MsgKind: String, Hashable { case text, voice, image, redpacket }
}

struct Session: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var avatar: String
    var preview: String
    var time: String
    var unread: Int
    var muted: Bool
    var isGroup: Bool
    var msgs: [Msg]
}

struct Friend: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var avatar: String
    var letter: String
    var wxid: String
    var region: String
    var signature: String
}

struct PostComment: Identifiable, Hashable {
    let id = UUID()
    var who: String
    var text: String
}

struct Post: Identifiable, Hashable {
    let id = UUID()
    var who: String
    var avatar: String
    var time: String
    var text: String
    var images: [String]
    var liked: [String]
    var comments: [PostComment]
}
