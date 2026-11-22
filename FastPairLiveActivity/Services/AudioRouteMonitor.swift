import Foundation
import AVFoundation

public final class AudioRouteMonitor: ObservableObject {
    public static let shared = AudioRouteMonitor()

    @Published public private(set) var connectedDeviceName: String?
    @Published public private(set) var isBluetoothAudioConnected: Bool = false

    private var isMonitoring = false

    private init() {}

    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )

        checkCurrentRoute(triggerNotification: false)
    }

    public func stopMonitoring() {
        isMonitoring = false
        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleAudioRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            switch reason {
            case .newDeviceAvailable:
                self.checkCurrentRoute(triggerNotification: true)

            case .oldDeviceUnavailable:
                self.checkCurrentRoute(triggerNotification: false)

            default:
                self.checkCurrentRoute()
            }
        }
    }

    public func checkCurrentRoute(triggerNotification: Bool = false) {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute

        let btOutputs = currentRoute.outputs.filter { output in
            output.portType == .bluetoothA2DP ||
            output.portType == .bluetoothHFP ||
            output.portType == .bluetoothLE
        }

        if let firstBt = btOutputs.first {
            let name = firstBt.portName
            let previouslyConnected = self.isBluetoothAudioConnected

            self.connectedDeviceName = name
            self.isBluetoothAudioConnected = true

            if !name.isEmpty && name != "Headphones" && name != "Bluetooth Device" {
                SettingsManager.shared.deviceName = name
            }

            if triggerNotification || !previouslyConnected {
                LiveActivityManager.shared.startOrUpdateActivity(deviceName: name)
            }
        } else {
            if self.isBluetoothAudioConnected {
                self.isBluetoothAudioConnected = false
                self.connectedDeviceName = nil
                LiveActivityManager.shared.handleDisconnection()
            }
        }
    }
}
