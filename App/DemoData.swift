import Foundation

enum DemoData {
    static func hhmm(_ m: Int) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: Calendar.current.date(byAdding: .minute, value: -m, to: Date()) ?? Date())
    }

    // MARK: 会话

    static let sessions: [Session] = [
        Session(name: "阿狸", avatar: "av_1", preview: "周五团建去爬山，记得带水～", time: hhmm(3), unread: 2, muted: false, isGroup: false, msgs: [
            Msg(fromMe: false, kind: .text, text: "在忙吗？", time: hhmm(30)),
            Msg(fromMe: true, kind: .text, text: "刚开完会，怎么啦", time: hhmm(28)),
            Msg(fromMe: false, kind: .voice, text: "6″", time: hhmm(27)),
            Msg(fromMe: false, kind: .text, text: "周五团建去爬山，记得带水～", time: hhmm(3)),
        ]),
        Session(name: "桃桃小分队", avatar: "av_3", preview: "老周：晚上聚餐，老地方见", time: hhmm(16), unread: 12, muted: true, isGroup: true, msgs: [
            Msg(fromMe: false, kind: .text, text: "圆圆：本周五部门团建，想去的接龙", time: hhmm(60)),
            Msg(fromMe: false, kind: .text, text: "苏苏：+1", time: hhmm(58)),
            Msg(fromMe: false, kind: .text, text: "老周：晚上聚餐，老地方见", time: hhmm(16)),
        ]),
        Session(name: "小狐", avatar: "av_5", preview: "[红包] 恭喜发财，大吉大利", time: hhmm(42), unread: 0, muted: false, isGroup: false, msgs: [
            Msg(fromMe: false, kind: .text, text: "上周帮你的忙，一点心意～", time: hhmm(43)),
            Msg(fromMe: false, kind: .redpacket, text: "恭喜发财，大吉大利", time: hhmm(42)),
        ]),
        Session(name: "老周", avatar: "av_2", preview: "方案我改好了，你看看第 3 页", time: "昨天", unread: 0, muted: false, isGroup: false, msgs: [
            Msg(fromMe: true, kind: .text, text: "周哥，设计稿发我一份呗", time: "昨天"),
            Msg(fromMe: false, kind: .text, text: "方案我改好了，你看看第 3 页", time: "昨天"),
            Msg(fromMe: true, kind: .text, text: "收到，今晚给你反馈", time: "昨天"),
        ]),
        Session(name: "苏苏", avatar: "av_4", preview: "[图片]", time: "昨天", unread: 0, muted: false, isGroup: false, msgs: [
            Msg(fromMe: false, kind: .text, text: "看我在公园拍的照片！", time: "昨天"),
            Msg(fromMe: false, kind: .image, text: "p_post2", time: "昨天"),
            Msg(fromMe: true, kind: .text, text: "拍得真好，下次带我去", time: "昨天"),
        ]),
        Session(name: "桃信助手", avatar: "me_services", preview: "欢迎来到桃信，祝你用得开心～", time: "周一", unread: 0, muted: false, isGroup: false, msgs: [
            Msg(fromMe: false, kind: .text, text: "欢迎来到桃信，祝你用得开心～", time: "周一"),
        ]),
        Session(name: "皮皮", avatar: "av_7", preview: "狗子照我也放群里了", time: "周一", unread: 0, muted: false, isGroup: false, msgs: [
            Msg(fromMe: false, kind: .image, text: "p_post3", time: "周一"),
            Msg(fromMe: false, kind: .text, text: "狗子照我也放群里了", time: "周一"),
        ]),
        Session(name: "熊熊", avatar: "av_6", preview: "好的，明天见！", time: "周日", unread: 0, muted: false, isGroup: false, msgs: [
            Msg(fromMe: true, kind: .text, text: "明天上午十点图书馆见？", time: "周日"),
            Msg(fromMe: false, kind: .text, text: "好的，明天见！", time: "周日"),
        ]),
    ]

    // MARK: 通讯录

    static let friends: [Friend] = [
        Friend(name: "阿狸", avatar: "av_1", letter: "A", wxid: "ali_2024", region: "浙江 杭州", signature: "今天也要好好吃饭"),
        Friend(name: "老周", avatar: "av_2", letter: "L", wxid: "laozhou88", region: "上海 静安", signature: "方案改到第 108 版"),
        Friend(name: "皮皮", avatar: "av_7", letter: "P", wxid: "pipi_peng", region: "广东 深圳", signature: "干饭第一名"),
        Friend(name: "苏苏", avatar: "av_4", letter: "S", wxid: "susu_rabbit", region: "江苏 南京", signature: "早睡早起（不存在的）"),
        Friend(name: "小狐", avatar: "av_5", letter: "X", wxid: "foxxy2025", region: "四川 成都", signature: "火锅续命中"),
        Friend(name: "熊熊", avatar: "av_6", letter: "X", wxid: "bear_bear", region: "湖北 武汉", signature: "图书馆常驻选手"),
        Friend(name: "圆圆", avatar: "av_3", letter: "Y", wxid: "yuanyuan_p", region: "北京 海淀", signature: "滚来滚去～"),
    ]

    static let me = Friend(name: "倾瑶", avatar: "av_me", letter: "Y", wxid: "taoxin_qingyao", region: "浙江 杭州", signature: "软件是一颗软软的桃子")

    // MARK: 朋友圈

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

    // MARK: 自动回复池

    static let autoReplies = [
        "好呀好呀", "收到收到！", "哈哈哈哈哈哈", "在忙，晚点回你～",
        "没问题 👌", "真的假的？", "好，见面细说", "绝了，你说得对",
    ]
}
