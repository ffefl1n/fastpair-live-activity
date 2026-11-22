import Foundation

public final class SettingsManager: ObservableObject {
    public static let shared = SettingsManager()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let deviceName = "fp_device_name"
        static let autoDismiss = "fp_auto_dismiss"
        static let autoDismissDelay = "fp_auto_dismiss_delay"
    }

    @Published public var deviceName: String {
        didSet { defaults.set(deviceName, forKey: Keys.deviceName) }
    }
    @Published public var autoDismiss: Bool {
        didSet { defaults.set(autoDismiss, forKey: Keys.autoDismiss) }
    }
    @Published public var autoDismissDelay: Double {
        didSet { defaults.set(autoDismissDelay, forKey: Keys.autoDismissDelay) }
    }

    private init() {
        self.deviceName = defaults.string(forKey: Keys.deviceName) ?? "Redmi Buds 8 Active"
        self.autoDismiss = defaults.object(forKey: Keys.autoDismiss) != nil ? defaults.bool(forKey: Keys.autoDismiss) : true
        self.autoDismissDelay = defaults.object(forKey: Keys.autoDismissDelay) != nil ? defaults.double(forKey: Keys.autoDismissDelay) : 15.0
    }

    public func applyRedmiBuds8Active() {
        self.deviceName = "Redmi Buds 8 Active"
        self.autoDismiss = true
        self.autoDismissDelay = 15.0
    }
}
