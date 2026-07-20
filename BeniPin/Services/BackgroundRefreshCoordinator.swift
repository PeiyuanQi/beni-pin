import BackgroundTasks
import Foundation

extension Notification.Name {
    static let catalogDidRefresh = Notification.Name("catalogDidRefresh")
}
final class BackgroundRefreshCoordinator {
    static let shared = BackgroundRefreshCoordinator()
    static let taskIdentifier = "com.peiyuanqi.benipin.catalog-refresh"

    private init() {}

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.taskIdentifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            self.handle(refreshTask)
        }
    }

    func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 24 * 60 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    private func handle(_ task: BGAppRefreshTask) {
        schedule()

        let operation = Task {
            do {
                _ = try await CatalogRepository().refreshFromRemote()
                NotificationCenter.default.post(name: .catalogDidRefresh, object: nil)
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            operation.cancel()
        }
    }
}
