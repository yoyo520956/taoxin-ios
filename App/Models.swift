import Foundation

// MARK: - 数据模型

/// 示例消息（离线演示会话用）
struct Msg: Identifiable, Hashable {
    let id = UUID()
    var fromMe: Bool
    var kind: MsgKind
    var text: String
    var time: String
    enum MsgKind: String, Hashable { case text, voice, image, redpacket }
}

/// 示例会话
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

/// 真实消息（局域网 Mesh 持久化）
struct RealMsg: Identifiable, Codable, Hashable {
    var id: String
    var fromMe: Bool
    var kind: String       // "text" | "img"
    var text: String       // 文本内容 / 图片缓存文件名
    var ts: Double
    var status: String     // "sent" | "failed"（仅 fromMe 有意义）

    init(id: String = UUID().uuidString, fromMe: Bool, kind: String,
         text: String, ts: Double, status: String = "sent") {
        self.id = id; self.fromMe = fromMe; self.kind = kind
        self.text = text; self.ts = ts; self.status = status
    }
}

struct PeerInfo: Codable, Hashable {
    var uid: String
    var nickname: String
    var customAvatar: Bool
}

/// 真实聊天记录（按对方 uid 持久化）
struct RealChat: Identifiable, Codable, Hashable {
    var id: String { peer.uid }
    var peer: PeerInfo
    var msgs: [RealMsg]
}

/// 本机账号
struct MyProfile: Codable {
    var uid: String
    var nickname: String
    var avatarAsset: String   // 内置 AI 头像名，空串=自定义照片
    var customAvatar: Bool
}

/// Mesh 线上传输信封
struct MeshMsg: Codable {
    var t: String      // "hello" | "text" | "img"
    var id: String
    var uid: String
    var nick: String
    var ava: Data?     // hello 时携带头像 jpeg
    var img: Data?     // img 时携带图片 jpeg
    var body: String
    var ts: Double
}

/// 附近发现的人
struct NearbyUser: Identifiable, Hashable {
    var id: String { peerName }
    var peerName: String
    var uid: String
    var connected: Bool
}

// MARK: - 朋友圈演示数据

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

/// 好友（示例资料页用）
struct Friend: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var avatar: String
    var letter: String
    var wxid: String
    var region: String
    var signature: String
}
