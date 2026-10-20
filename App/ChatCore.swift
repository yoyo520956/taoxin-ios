import Foundation
import MultipeerConnectivity
import UIKit

/// 局域网真聊天核心：同时担任 广播者+浏览者，任意方向都能建立连接
final class ChatCore: NSObject, ObservableObject {
    static let shared = ChatCore()
    static let serviceType = "taoxin-mesh"

    @Published var nearby: [String: NearbyUser] = [:]      // key: 对方 peer displayName
    @Published var chats: [String: RealChat] = [:]          // key: 对方 uid
    @Published var unread: [String: Int] = [:]
    @Published var activeChatUID: String? = nil
    @Published var onlinePeers: Set<String> = []            // 已连接 peer displayName

    private(set) var profile: MyProfile?
    private var mcSession: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    var peerIDs: [String: MCPeerID] = [:]           // displayName → MCPeerID
    var uidToPeer: [String: String] = [:]           // uid → displayName
    var peerToUID: [String: String] = [:]      // displayName → uid
    private var invited = Set<String>()

    var totalUnread: Int { unread.values.reduce(0, +) }

    // MARK: 启动 / 重启

    func start(with profile: MyProfile) {
        self.profile = profile
        let name = String(profile.nickname.prefix(20))
        let me = MCPeerID(displayName: name)
        let s = MCSession(peer: me, securityIdentity: nil, encryptionPreference: .required)
        mcSession = s

        let adv = MCNearbyServiceAdvertiser(peer: me, discoveryInfo: ["uid": profile.uid], serviceType: Self.serviceType)
        let brw = MCNearbyServiceBrowser(peer: me, serviceType: Self.serviceType)
        advertiser = adv
        browser = brw

        s.delegate = self
        adv.delegate = self
        brw.delegate = self
        adv.startAdvertisingPeer()
        brw.startBrowsingForPeers()

        for c in Store.shared.loadAllChats() {
            chats[c.peer.uid] = c
        }
    }

    func restart(with profile: MyProfile) {
        stop()
        nearby.removeAll()
        onlinePeers.removeAll()
        invited.removeAll()
        start(with: profile)
    }

    func stop() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        mcSession = nil
        advertiser = nil
        browser = nil
    }

    func markRead(uid: String) {
        unread[uid] = 0
    }

    // MARK: 连接

    func invite(peerName: String) {
        guard let id = peerIDs[peerName], let s = mcSession, !invited.contains(peerName) else { return }
        guard !onlinePeers.contains(peerName) else { return }
        invited.insert(peerName)
        browser?.invitePeer(id, to: s, withContext: nil, timeout: 30)
        DispatchQueue.main.asyncAfter(deadline: .now() + 35) { [weak self] in
            self?.invited.remove(peerName)
        }
    }

    // MARK: 发送

    func sendText(uid: String, _ text: String) {
        let body = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else { return }
        let msg = MeshMsg(t: "text", id: UUID().uuidString, uid: profile?.uid ?? "",
                          nick: profile?.nickname ?? "", ava: nil, img: nil,
                          body: body, ts: Date().timeIntervalSince1970)
        deliver(msg, kind: "text", text: body, chatUID: uid)
    }

    func sendImage(uid: String, _ image: UIImage) {
        let small = Store.downscale(image)
        guard let data = small.jpegData(compressionQuality: 0.5) else { return }
        let msg = MeshMsg(t: "img", id: UUID().uuidString, uid: profile?.uid ?? "",
                          nick: profile?.nickname ?? "", ava: nil, img: data,
                          body: "", ts: Date().timeIntervalSince1970)
        deliver(msg, kind: "img", text: "", chatUID: uid)
    }

    private func deliver(_ msg: MeshMsg, kind: String, text: String, chatUID: String) {
        let peerName = uidToPeer[chatUID]
        var ok = false
        if let peerName, let s = mcSession, let pid = peerIDs[peerName], onlinePeers.contains(peerName) {
            if let data = try? JSONEncoder().encode(msg) {
                ok = ((try? s.send(data, toPeers: [pid], with: .reliable)) != nil)
            }
        }
        if kind == "img" {
            let name = "img_\(msg.id).jpg"
            if let d = msg.img { _ = Store.shared.cacheImage(d, name: name) }
            appendLocal(uid: chatUID, kind: "img", text: ok ? name : "", status: ok ? "sent" : "failed", peerNick: msg.nick)
        } else {
            appendLocal(uid: chatUID, kind: "text", text: text, status: ok ? "sent" : "failed", peerNick: msg.nick)
        }
    }

    private func appendLocal(uid: String, kind: String, text: String, status: String, peerNick: String) {
        let m = RealMsg(fromMe: true, kind: kind, text: text,
                        ts: Date().timeIntervalSince1970, status: status)
        appendMsg(m, uid: uid, nick: peerNick, avatarData: nil, fromMe: true)
    }

    /// 统一的消息落库入口（收发共用）
    func appendMsg(_ m: RealMsg, uid: String, nick: String, avatarData: Data?, fromMe: Bool) {
        var chat = chats[uid] ?? RealChat(peer: PeerInfo(uid: uid, nickname: nick, customAvatar: false), msgs: [])
        if chat.peer.nickname.isEmpty { chat.peer.nickname = nick }
        chat.msgs.append(m)
        if chat.msgs.count > 300 {
            chat.msgs.removeFirst(chat.msgs.count - 300)
        }
        chats[uid] = chat
        if !fromMe && activeChatUID != uid {
            unread[uid] = (unread[uid] ?? 0) + 1
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        Store.shared.saveChat(chat)
    }
}
