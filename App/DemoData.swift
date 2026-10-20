import Foundation

enum DemoData {
    static func hhmm(_ m: Int) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: Calendar.current.date(byAdding: .minute, value: -m, to: Date()) ?? Date())
    }

    // MARK: 示例会话（离线演示，真实聊天在「附近」）

    static let sessions: [Session] = [
        Session(name: "阿狸", avatar: "av_1", preview: "周五团建去爬山，记得带水～", time: hhmm(3), unread: 2, muted: false, isGroup: false, msgs: [
            Msg(fromMe: false, kind: .text, text: "在忙吗？", time: hhmm(30)),
            Msg(fromMe: true, kind: .text, text: "刚开完会，怎么啦", time: hhmm(28)),
            Msg(fromMe: false, kind: .voice, text: "6″", time: hhmm(27)),
            Msg(fromMe: false, kind: .text, text: "周五团建去爬山，记得带水～", time: hhmm(3)),
        ]),
        Session(name: "小狐", avatar: "av_5", preview: "[红包] 恭喜发财，大吉大利", time: hhmm(42), unread: 0, muted: false, isGroup: false, msgs: [
            Msg(fromMe: false, kind: .text, text: "上周帮你的忙，一点心意～", time: hhmm(43)),
            Msg(fromMe: false, kind: .redpacket, text: "恭喜发财，大吉大利", time: hhmm(42)),
        ]),
        Session(name: "桃信助手", avatar: "me_services", preview: "示例会话：去「附近」开始真实聊天", time: "周一", unread: 0, muted: false, isGroup: false, msgs: [
            Msg(fromMe: false, kind: .text, text: "这是示例会话，帮你看看气泡长什么样～", time: "周一"),
            Msg(fromMe: false, kind: .text, text: "真实聊天请去「附近」页，找到同时打开桃信的人", time: "周一"),
        ]),
    ]

    static let me = Friend(name: "倾瑶", avatar: "av_me", letter: "Y", wxid: "taoxin_qingyao", region: "浙江 杭州", signature: "软件是一颗软软的桃子")

    // MARK: 朋友圈（演示）

    static let posts: [Post] = [
        Post(who: "苏苏", avatar: "av_4", time: "23 分钟前", text: "早八人的续命神器 ☕️",
             images: ["p_post1"], liked: ["阿狸", "圆圆"],
             comments: [PostComment(who: "圆圆", text: "哪家店！带我去"),
                        PostComment(who: "苏苏", text: "公司楼下那家～")]),
        Post(who: "老周", avatar: "av_2", time: "1 小时前", text: "周末去爬山，山顶的风太舒服了",
             images: ["p_cover"], liked: ["小狐"], comments: []),
        Post(who: "皮皮", avatar: "av_7", time: "3 小时前", text: "公园遛弯，遇见一只笑得很开心的狗子 🐕",
             images: ["p_post3"], liked: [],
             comments: [PostComment(who: "熊熊", text: "这笑得也太治愈了")]),
        Post(who: "阿狸", avatar: "av_1", time: "昨天", text: "春天来了，公园的湖边走一走",
             images: ["p_post2"], liked: ["苏苏", "老周", "小狐"], comments: []),
    ]

    // MARK: 演示会话自动回复池

    static let autoReplies = [
        "好呀好呀", "收到收到！", "哈哈哈哈哈哈", "在忙，晚点回你～",
        "没问题 👌", "真的假的？", "好，见面细说", "绝了，你说得对",
    ]
}
