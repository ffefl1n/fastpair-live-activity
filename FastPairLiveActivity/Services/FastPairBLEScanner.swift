import Foundation
import CoreBluetooth

public struct DiscoveredHeadphone: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let rssi: Int
    public let isFastPair: Bool
    public var batteryLevel: Int?
}

public final class FastPairBLEScanner: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    public static let shared = FastPairBLEScanner()

    @Published public private(set) var isScanning = false
    @Published public private(set) var discoveredDevices: [DiscoveredHeadphone] = []

    private var centralManager: CBCentralManager?
    private var connectedPeripherals: [UUID: CBPeripheral] = [:]

    public static let fastPairServiceUUID = CBUUID(string: "FE2C")
    public static let xiaomiServiceUUID = CBUUID(string: "FE95")
    public static let batteryServiceUUID = CBUUID(string: "180F")
    public static let batteryLevelCharUUID = CBUUID(string: "2A19")

    private override init() {
        super.init()
    }

    public func startScanning() {
        if centralManager == nil {
            centralManager = CBCentralManager(
                delegate: self,
                queue: .main,
                options: [CBCentralManagerOptionRestoreIdentifierKey: "FastPairCentralManagerRestoreKey"]
            )
        } else if centralManager?.state == .poweredOn {
            performScan()
        }
    }

    private func performScan() {
        guard centralManager?.state == .poweredOn else { return }
        isScanning = true
        centralManager?.scanForPeripherals(
            withServices: [Self.fastPairServiceUUID, Self.batteryServiceUUID, Self.xiaomiServiceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }

    public func stopScanning() {
        centralManager?.stopScan()
        isScanning = false
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            performScan()
        } else {
            isScanning = false
        }
    }

    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in peripherals {
                connectedPeripherals[peripheral.identifier] = peripheral
                peripheral.delegate = self
            }
        }
    }

    public func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Bluetooth Device"
        let isFastPair = advertisementData[CBAdvertisementDataServiceDataKey] != nil

        let discovered = DiscoveredHeadphone(
            id: peripheral.identifier,
            name: name,
            rssi: RSSI.intValue,
            isFastPair: isFastPair,
            batteryLevel: nil
        )

        if !discoveredDevices.contains(where: { $0.id == discovered.id }) {
            discoveredDevices.append(discovered)
        }

        if let pName = peripheral.name, (pName.contains("Redmi") || pName.contains("Buds") || pName.contains("Xiaomi")) {
            SettingsManager.shared.deviceName = pName
        }

        connectedPeripherals[peripheral.identifier] = peripheral
        peripheral.delegate = self
        central.connect(peripheral, options: nil)
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([Self.batteryServiceUUID, Self.xiaomiServiceUUID])
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == Self.batteryServiceUUID {
            peripheral.discoverCharacteristics([Self.batteryLevelCharUUID], for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let chars = service.characteristics else { return }
        for char in chars where char.uuid == Self.batteryLevelCharUUID {
            peripheral.readValue(for: char)
            peripheral.setNotifyValue(true, for: char)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid == Self.batteryLevelCharUUID,
              let value = characteristic.value,
              let batteryByte = value.first else { return }

        let battery = Int(batteryByte)
        let name = peripheral.name ?? SettingsManager.shared.deviceName

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let index = self.discoveredDevices.firstIndex(where: { $0.id == peripheral.identifier }) {
                self.discoveredDevices[index].batteryLevel = battery
            }

            SettingsManager.shared.defaultLeftBattery = battery
            SettingsManager.shared.defaultRightBattery = battery

            LiveActivityManager.shared.startOrUpdateActivity(
                deviceName: name,
                leftBattery: battery,
                rightBattery: battery,
                caseBattery: SettingsManager.shared.defaultCaseBattery,
                singleBattery: nil,
                modelType: SettingsManager.shared.modelType
            )
        }
    }
}
