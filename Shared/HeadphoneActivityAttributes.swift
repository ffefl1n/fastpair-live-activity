import Foundation
import ActivityKit

public struct HeadphoneActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var deviceName: String
        public var isConnected: Bool
        public var statusMessage: String
        public var timestamp: Date

        public init(
            deviceName: String,
            isConnected: Bool,
            statusMessage: String = "Подключено",
            timestamp: Date = Date()
        ) {
            self.deviceName = deviceName
            self.isConnected = isConnected
            self.statusMessage = statusMessage
            self.timestamp = timestamp
        }
    }

    public var deviceIdentifier: String

    public init(deviceIdentifier: String) {
        self.deviceIdentifier = deviceIdentifier
    }
}
