import Foundation

public final class SettingsManager: ObservableObject {
    public static let shared = SettingsManager()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let deviceName = "fp_device_name"
        static let autoDismiss = "fp_auto_dismiss"
        static let autoDismissDelay = "fp_auto_dismiss_delay"
        static let showFullscreen = "fp_show_fullscreen"
        static let defaultLeftBattery = "fp_left_battery"
        static let defaultRightBattery = "fp_right_battery"
        static let defaultCaseBattery = "fp_case_battery"
        static let modelType = "fp_model_type"
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
    @Published public var showFullscreenOnConnect: Bool {
        didSet { defaults.set(showFullscreenOnConnect, forKey: Keys.showFullscreen) }
    }
    @Published public var defaultLeftBattery: Int {
        didSet { defaults.set(defaultLeftBattery, forKey: Keys.defaultLeftBattery) }
    }
    @Published public var defaultRightBattery: Int {
        didSet { defaults.set(defaultRightBattery, forKey: Keys.defaultRightBattery) }
    }
    @Published public var defaultCaseBattery: Int {
        didSet { defaults.set(defaultCaseBattery, forKey: Keys.defaultCaseBattery) }
    }
    @Published public var modelType: HeadphoneActivityAttributes.HeadphoneModelType {
        didSet { defaults.set(modelType.rawValue, forKey: Keys.modelType) }
    }

    private init() {
        self.deviceName = defaults.string(forKey: Keys.deviceName) ?? "Redmi Buds 8 Active"
        self.autoDismiss = defaults.object(forKey: Keys.autoDismiss) != nil ? defaults.bool(forKey: Keys.autoDismiss) : true
        self.autoDismissDelay = defaults.object(forKey: Keys.autoDismissDelay) != nil ? defaults.double(forKey: Keys.autoDismissDelay) : 15.0
        self.showFullscreenOnConnect = defaults.object(forKey: Keys.showFullscreen) != nil ? defaults.bool(forKey: Keys.showFullscreen) : true
        self.defaultLeftBattery = defaults.object(forKey: Keys.defaultLeftBattery) != nil ? defaults.integer(forKey: Keys.defaultLeftBattery) : 90
        self.defaultRightBattery = defaults.object(forKey: Keys.defaultRightBattery) != nil ? defaults.integer(forKey: Keys.defaultRightBattery) : 90
        self.defaultCaseBattery = defaults.object(forKey: Keys.defaultCaseBattery) != nil ? defaults.integer(forKey: Keys.defaultCaseBattery) : 95

        let typeRaw = defaults.string(forKey: Keys.modelType) ?? HeadphoneActivityAttributes.HeadphoneModelType.tws.rawValue
        self.modelType = HeadphoneActivityAttributes.HeadphoneModelType(rawValue: typeRaw) ?? .tws
    }

    public func applyRedmiBuds8ActivePreset() {
        self.deviceName = "Redmi Buds 8 Active"
        self.modelType = .tws
        self.defaultLeftBattery = 95
        self.defaultRightBattery = 95
        self.defaultCaseBattery = 100
        self.autoDismiss = true
        self.autoDismissDelay = 15.0
        self.showFullscreenOnConnect = true
    }
}
