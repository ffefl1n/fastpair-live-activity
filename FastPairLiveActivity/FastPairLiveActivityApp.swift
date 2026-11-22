import SwiftUI
import AVFoundation

@main
struct FastPairLiveActivityApp: App {
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var audioMonitor = AudioRouteMonitor.shared
    @StateObject private var bleScanner = FastPairBLEScanner.shared
    @StateObject private var activityManager = LiveActivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioMonitor)
                .environmentObject(bleScanner)
                .environmentObject(activityManager)
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

        activityManager.startOrUpdateActivity(deviceName: name)
    }
}
