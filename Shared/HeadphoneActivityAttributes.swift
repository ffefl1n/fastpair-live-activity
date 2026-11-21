import Foundation
import ActivityKit

public struct HeadphoneActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var deviceName: String
        public var isConnected: Bool
        public var leftBattery: Int?     // 0 - 100
        public var rightBattery: Int?    // 0 - 100
        public var caseBattery: Int?     // 0 - 100
        public var singleBattery: Int?   // для полноразмерных наушников
        public var statusMessage: String
        public var modelType: HeadphoneModelType
        public var timestamp: Date

        public init(
            deviceName: String,
            isConnected: Bool,
            leftBattery: Int? = nil,
            rightBattery: Int? = nil,
            caseBattery: Int? = nil,
            singleBattery: Int? = nil,
            statusMessage: String = "Подключено",
            modelType: HeadphoneModelType = .tws,
            timestamp: Date = Date()
        ) {
            self.deviceName = deviceName
            self.isConnected = isConnected
            self.leftBattery = leftBattery
            self.rightBattery = rightBattery
            self.caseBattery = caseBattery
            self.singleBattery = singleBattery
            self.statusMessage = statusMessage
            self.modelType = modelType
            self.timestamp = timestamp
        }
    }

    public enum HeadphoneModelType: String, Codable, CaseIterable {
        case tws = "tws"
        case overEar = "overEar"
        case neckband = "neckband"

        public var title: String {
            switch self {
            case .tws: return "Внутриканальные TWS"
            case .overEar: return "Полноразмерные"
            case .neckband: return "С шейным ободом"
            }
        }

        public var defaultSFSymbol: String {
            switch self {
            case .tws: return "earbuds"
            case .overEar: return "headphones"
            case .neckband: return "headphones.circle.fill"
            }
        }
    }

    public var deviceIdentifier: String
    public var preferredModelType: HeadphoneModelType

    public init(deviceIdentifier: String, preferredModelType: HeadphoneModelType = .tws) {
        self.deviceIdentifier = deviceIdentifier
        self.preferredModelType = preferredModelType
    }
}
