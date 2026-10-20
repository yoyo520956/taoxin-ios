import SwiftUI

@main
struct TaoxinApp: App {
    @StateObject private var chatCore = ChatCore.shared
    @AppStorage(Store.hasProfileKey) private var hasProfile = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasProfile {
                    RootTabView()
                } else {
                    OnboardingView()
                }
            }
            .preferredColorScheme(.light)
            .environmentObject(chatCore)
            .onAppear {
                if hasProfile, chatCore.profile == nil, let p = Store.loadProfile() {
                    chatCore.start(with: p)
                }
            }
        }
    }
}
