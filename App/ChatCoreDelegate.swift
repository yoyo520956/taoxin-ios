import Foundation
import MultipeerConnectivity
import UIKit

// MARK: - MCSession / 广播 / 浏览 三协议实现

extension ChatCore: MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {

    // MARK: 连接状态

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            switch state {
            case .connected:
                onlinePeers.insert(peerID.displayName)
                nearby[peerID.displayName]?.connected = true
                sendHello(to: peerID)
            case .notConnected:
                onlinePeers.remove(peerID.displayName)
                nearby[peerID.displayName]?.connected = false
            default:
                break
            }
        }
    }

    /// 连接建立后互发名片（uid/昵称/头像）
    private func sendHello(to peerID: MCPeerID) {
        guard let p = profile, let s = mcSession else { return }
        var avaData: Data?
        if p.customAvatar {
            avaData = Store.shared.loadImage("ava_self.jpg")?.jpegData(compressionQuality: 0.5)
        } else if let img = UIImage(named: p.avatarAsset) {
            avaData = Store.downscale(img, maxDim: 300).jpegData(compressionQuality: 0.5)
        }
        let hello = MeshMsg(t: "hello", id: UUID().uuidString, uid: p.uid, nick: p.nickname,
                            ava: avaData, img: nil, body: "", ts: Date().timeIntervalSince1970)
        if let d = try? JSONEncoder().encode(hello) {
            try? s.send(d, toPeers: [peerID], with: .reliable)
        }
    }

    // MARK: 收数据

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let msg = try? JSONDecoder().decode(MeshMsg.self, from: data),
              msg.uid != (profile?.uid ?? "") else { return }
        Task { @MainActor in
            handleIncoming(msg, from: peerID)
        }
    }

    private func handleIncoming(_ msg: MeshMsg, from peerID: MCPeerID) {
        uidToPeer[msg.uid] = peerID.displayName
        peerToUID[peerID.displayName] = msg.uid

        if msg.t == "hello" {
            if let d = msg.ava { _ = Store.shared.cacheAvatar(d, uid: msg.uid) }
            var chat = chats[msg.uid] ?? RealChat(peer: PeerInfo(uid: msg.uid, nickname: msg.nick, customAvatar: msg.ava != nil), msgs: [])
            chat.peer.nickname = msg.nick
            chat.peer.customAvatar = msg.ava != nil
            chats[msg.uid] = chat
            Store.shared.saveChat(chat)
            return
        }

        if msg.t == "img", let d = msg.img {
            let name = "img_\(msg.id).jpg"
            _ = Store.shared.cacheImage(d, name: name)
            let m = RealMsg(fromMe: false, kind: "img", text: name, ts: msg.ts)
            appendMsg(m, uid: msg.uid, nick: msg.nick, avatarData: msg.ava, fromMe: false)
            return
        }

        let m = RealMsg(fromMe: false, kind: "text", text: msg.body, ts: msg.ts)
        appendMsg(m, uid: msg.uid, nick: msg.nick, avatarData: msg.ava, fromMe: false)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    // MARK: 被邀请 → 自动接受

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, mcSession)
    }

    // MARK: 发现 / 丢失

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        let uid = info?["uid"] ?? ("p_" + peerID.displayName)
        Task { @MainActor in
            peerIDs[peerID.displayName] = peerID
            peerToUID[peerID.displayName] = uid
            uidToPeer[uid] = peerID.displayName
            nearby[peerID.displayName] = NearbyUser(peerName: peerID.displayName, uid: uid,
                                                    connected: onlinePeers.contains(peerID.displayName))
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in
            nearby.removeValue(forKey: peerID.displayName)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {}
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {}
}
