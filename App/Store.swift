import Foundation
import UIKit

/// 本地持久化：聊天记录 / 账号 / 头像与图片缓存
final class Store {
    static let shared = Store()

    let chatsDir: URL
    let mediaDir: URL

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        chatsDir = docs.appendingPathComponent("chats", isDirectory: true)
        mediaDir = docs.appendingPathComponent("media", isDirectory: true)
        try? FileManager.default.createDirectory(at: chatsDir, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: mediaDir, withIntermediateDirectories: true)
    }

    // MARK: 聊天记录（每对方一个 json）

    func loadAllChats() -> [RealChat] {
        guard let files = try? FileManager.default.contentsOfDirectory(at: chatsDir, includingPropertiesForKeys: nil) else { return [] }
        return files.filter { $0.pathExtension == "json" }.compactMap { url in
            guard let d = try? Data(contentsOf: url) else { return nil }
            return try? JSONDecoder().decode(RealChat.self, from: d)
        }
    }

    func saveChat(_ chat: RealChat) {
        let url = chatsDir.appendingPathComponent("\(chat.peer.uid).json")
        if let d = try? JSONEncoder().encode(chat) {
            try? d.write(to: url, options: .atomic)
        }
    }

    // MARK: 账号

    static let profileKey = "taoxin.profile"
    static let uidKey = "taoxin.uid"
    static let hasProfileKey = "taoxin.hasProfile"

    static func myUID() -> String {
        if let s = UserDefaults.standard.string(forKey: uidKey), !s.isEmpty { return s }
        let s = UUID().uuidString
        UserDefaults.standard.set(s, forKey: uidKey)
        return s
    }

    static func loadProfile() -> MyProfile? {
        guard let d = UserDefaults.standard.data(forKey: profileKey) else { return nil }
        return try? JSONDecoder().decode(MyProfile.self, from: d)
    }

    static func saveProfile(_ p: MyProfile) {
        if let d = try? JSONEncoder().encode(p) {
            UserDefaults.standard.set(d, forKey: profileKey)
        }
    }

    static func clearAccount() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: profileKey)
        ud.removeObject(forKey: uidKey)
        ud.set(false, forKey: hasProfileKey)
    }

    // MARK: 媒体缓存

    /// 保存收到的头像，返回文件名
    @discardableResult
    func cacheAvatar(_ data: Data, uid: String) -> String {
        let name = "ava_\(uid).jpg"
        try? data.write(to: mediaDir.appendingPathComponent(name), options: .atomic)
        return name
    }

    func avatarFileURL(uid: String) -> URL? {
        let url = mediaDir.appendingPathComponent("ava_\(uid).jpg")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    @discardableResult
    func cacheImage(_ data: Data, name: String) -> String {
        try? data.write(to: mediaDir.appendingPathComponent(name), options: .atomic)
        return name
    }

    func loadImage(_ name: String) -> UIImage? {
        let url = mediaDir.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    // MARK: 图片压缩

    static func downscale(_ image: UIImage, maxDim: CGFloat = 900) -> UIImage {
        let size = image.size
        let m = max(size.width, size.height)
        guard m > maxDim else { return image }
        let scale = maxDim / m
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let fmt = UIGraphicsImageRendererFormat.default()
        fmt.scale = 1
        return UIGraphicsImageRenderer(size: newSize, format: fmt).image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
