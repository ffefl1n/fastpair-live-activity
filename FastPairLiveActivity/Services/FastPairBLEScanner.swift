import Foundation
import CoreBluetooth

public struct DiscoveredHeadphone: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let rssi: Int
    public let isFastPair: Bool
}

public final class FastPairBLEScanner: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    public static let shared = FastPairBLEScanner()

    @Published public private(set) var isScanning = false
    @Published public private(set) var discoveredDevices: [DiscoveredHeadphone] = []

    private var centralManager: CBCentralManager?
    private var connectedPeripherals: [UUID: CBPeripheral] = [:]

    public static let fastPairServiceUUID = CBUUID(string: "FE2C")
    public static let xiaomiServiceUUID = CBUUID(string: "FE95")

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
            withServices: [Self.fastPairServiceUUID, Self.xiaomiServiceUUID],
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
            isFastPair: isFastPair
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
        let name = peripheral.name ?? SettingsManager.shared.deviceName
        DispatchQueue.main.async {
            LiveActivityManager.shared.startOrUpdateActivity(deviceName: name)
        }
    }
}
