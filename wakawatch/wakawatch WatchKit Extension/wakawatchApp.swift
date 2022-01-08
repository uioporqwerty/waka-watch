import SwiftUI

@main
struct wakawatchApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                AuthorizationView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
