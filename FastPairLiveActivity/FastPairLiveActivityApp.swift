import SwiftUI
import AVFoundation

@main
struct FastPairLiveActivityApp: App {
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var audioMonitor = AudioRouteMonitor.shared
    @StateObject private var bleScanner = FastPairBLEScanner.shared
    @StateObject private var activityManager = LiveActivityManager.shared

    @State private var isShowingFullscreenModal = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(audioMonitor)
                    .environmentObject(bleScanner)
                    .environmentObject(activityManager)

                if isShowingFullscreenModal {
                    FullscreenPopupView(
                        deviceName: audioMonitor.connectedDeviceName ?? settings.deviceName,
                        leftBattery: settings.defaultLeftBattery,
                        rightBattery: settings.defaultRightBattery,
                        caseBattery: settings.defaultCaseBattery,
                        autoDismissSeconds: settings.autoDismissDelay,
                        onDismiss: {
                            withAnimation {
                                isShowingFullscreenModal = false
                            }
                        }
                    )
                    .transition(.opacity)
                    .zIndex(999)
                }
            }
            .onAppear {
                setupAudioSession()
                audioMonitor.startMonitoring()
                bleScanner.startScanning()
            }
            .onOpenURL { url in
                handleIncomingURL(url)
            }
        }
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetoothHFP, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error)")
        }
    }

    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "fastpair" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        let nameFromQuery = queryItems.first(where: { $0.name == "name" })?.value
        let name = nameFromQuery ?? audioMonitor.connectedDeviceName ?? settings.deviceName

        let left = Int(queryItems.first(where: { $0.name == "left" })?.value ?? "") ?? settings.defaultLeftBattery
        let right = Int(queryItems.first(where: { $0.name == "right" })?.value ?? "") ?? settings.defaultRightBattery
        let caseBattery = Int(queryItems.first(where: { $0.name == "case" })?.value ?? "") ?? settings.defaultCaseBattery

        activityManager.startOrUpdateActivity(
            deviceName: name,
            leftBattery: left,
            rightBattery: right,
            caseBattery: caseBattery,
            modelType: settings.modelType
        )

        if settings.showFullscreenOnConnect {
            withAnimation {
                isShowingFullscreenModal = true
            }
        }
    }
}
