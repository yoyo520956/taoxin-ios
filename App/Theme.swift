import SwiftUI

extension Color {
    /// 主品牌绿 #07C160
    static let wxGreen  = Color(red: 0.03, green: 0.76, blue: 0.38)
    /// 我的气泡绿 #95EC69
    static let wxBubble = Color(red: 0.58, green: 0.93, blue: 0.41)
    /// 页面底灰 #EDEDED
    static let wxBg     = Color(red: 0.93, green: 0.93, blue: 0.93)
    static let wxText   = Color(red: 0.13, green: 0.13, blue: 0.13)
    static let wxGray   = Color(red: 0.55, green: 0.55, blue: 0.55)
    static let wxSep    = Color(red: 0.90, green: 0.90, blue: 0.90)
    /// 链接蓝 #576B95
    static let wxLink   = Color(red: 0.34, green: 0.42, blue: 0.58)
}

extension Image {
    /// 统一图标渲染：原色 + 指定尺寸
    @ViewBuilder
    func wxIcon(_ size: CGFloat) -> some View {
        resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
