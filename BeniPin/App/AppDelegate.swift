import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        BackgroundRefreshCoordinator.shared.register()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        BackgroundRefreshCoordinator.shared.schedule()
    }
}
