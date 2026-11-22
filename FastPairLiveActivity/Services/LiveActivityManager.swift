import Foundation
import ActivityKit

public final class LiveActivityManager: ObservableObject {
    public static let shared = LiveActivityManager()

    @Published public private(set) var activeActivityId: String?

    private var currentActivity: Activity<HeadphoneActivityAttributes>?
    private var dismissTimer: Timer?

    private init() {
        self.currentActivity = Activity<HeadphoneActivityAttributes>.activities.first
        self.activeActivityId = currentActivity?.id
    }

    public func startOrUpdateActivity(deviceName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not authorized.")
            return
        }

        let state = HeadphoneActivityAttributes.ContentState(
            deviceName: deviceName,
            isConnected: true,
            statusMessage: "Подключено",
            timestamp: Date()
        )

        if let existingActivity = currentActivity ?? Activity<HeadphoneActivityAttributes>.activities.first {
            Task {
                await existingActivity.update(
                    ActivityContent(state: state, staleDate: nil)
                )
                DispatchQueue.main.async {
                    self.currentActivity = existingActivity
                    self.activeActivityId = existingActivity.id
                    self.scheduleAutoDismiss()
                }
            }
        } else {
            let attributes = HeadphoneActivityAttributes(deviceIdentifier: deviceName)

            do {
                let activity = try Activity<HeadphoneActivityAttributes>.request(
                    attributes: attributes,
                    content: ActivityContent(state: state, staleDate: nil),
                    pushType: nil
                )
                DispatchQueue.main.async {
                    self.currentActivity = activity
                    self.activeActivityId = activity.id
                    self.scheduleAutoDismiss()
                }
            } catch {
                print("Failed to start Live Activity: \(error)")
            }
        }
    }

    public func handleDisconnection() {
        guard let activity = currentActivity ?? Activity<HeadphoneActivityAttributes>.activities.first else { return }

        let state = HeadphoneActivityAttributes.ContentState(
            deviceName: activity.content.state.deviceName,
            isConnected: false,
            statusMessage: "Отключено",
            timestamp: Date()
        )

        Task {
            await activity.update(ActivityContent(state: state, staleDate: nil))
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await activity.end(dismissalPolicy: .immediate)
            DispatchQueue.main.async {
                self.currentActivity = nil
                self.activeActivityId = nil
            }
        }
    }

    public func stopActivityImmediately() {
        dismissTimer?.invalidate()
        dismissTimer = nil

        Task {
            for activity in Activity<HeadphoneActivityAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
            DispatchQueue.main.async {
                self.currentActivity = nil
                self.activeActivityId = nil
            }
        }
    }

    private func scheduleAutoDismiss() {
        dismissTimer?.invalidate()
        dismissTimer = nil

        let settings = SettingsManager.shared
        guard settings.autoDismiss && settings.autoDismissDelay > 0 else { return }

        dismissTimer = Timer.scheduledTimer(withTimeInterval: settings.autoDismissDelay, repeats: false) { [weak self] _ in
            guard let self = self, let activity = self.currentActivity else { return }
            Task {
                await activity.end(dismissalPolicy: .immediate)
                DispatchQueue.main.async {
                    self.currentActivity = nil
                    self.activeActivityId = nil
                }
            }
        }
    }
}
