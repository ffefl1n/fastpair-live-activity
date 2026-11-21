import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioMonitor: AudioRouteMonitor
    @EnvironmentObject var bleScanner: FastPairBLEScanner
    @EnvironmentObject var activityManager: LiveActivityManager

    @State private var testDeviceName: String = "Sony WF-1000XM4"
    @State private var testLeftBattery: Double = 85
    @State private var testRightBattery: Double = 80
    @State private var testCaseBattery: Double = 95
    @State private var selectedModelType: HeadphoneActivityAttributes.HeadphoneModelType = .tws
    @State private var isShowingCopiedToast = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Состояние мониторинга")) {
                    HStack {
                        Image(systemName: audioMonitor.isBluetoothAudioConnected ? "headphones" : "headphones.circle")
                            .foregroundColor(audioMonitor.isBluetoothAudioConnected ? .green : .secondary)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(audioMonitor.isBluetoothAudioConnected ? "Аудио подключено" : "Ожидание подключения...")
                                .font(.headline)
                            if let name = audioMonitor.connectedDeviceName {
                                Text(name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Image(systemName: activityManager.activeActivityId != nil ? "bolt.fill" : "bolt.slash")
                            .foregroundColor(activityManager.activeActivityId != nil ? .yellow : .secondary)
                        Text("Live Activity:")
                        Spacer()
                        Text(activityManager.activeActivityId != nil ? "Активна на экране" : "Не запущена")
                            .foregroundColor(activityManager.activeActivityId != nil ? .green : .secondary)
                    }

                    if activityManager.activeActivityId != nil {
                        Button(role: .destructive, action: {
                            activityManager.stopActivityImmediately()
                        }) {
                            Label("Закрыть карточку Live Activity", systemImage: "xmark.circle")
                        }
                    }
                }

                Section(header: Text("Тест / Демонстрация карточки"), footer: Text("Нажмите кнопку ниже, чтобы моментально запустить Live Activity и увидеть карточку на экране блокировки вашего iPhone.")) {
                    TextField("Название наушников", text: $testDeviceName)

                    Picker("Тип устройства", selection: $selectedModelType) {
                        ForEach(HeadphoneActivityAttributes.HeadphoneModelType.allCases, id: \.self) { type in
                            Text(type.title).tag(type)
                        }
                    }

                    if selectedModelType == .tws {
                        VStack(alignment: .leading) {
                            Text("Левый наушник: \(Int(testLeftBattery))%")
                            Slider(value: $testLeftBattery, in: 0...100, step: 5)
                        }
                        VStack(alignment: .leading) {
                            Text("Правый наушник: \(Int(testRightBattery))%")
                            Slider(value: $testRightBattery, in: 0...100, step: 5)
                        }
                        VStack(alignment: .leading) {
                            Text("Кейс: \(Int(testCaseBattery))%")
                            Slider(value: $testCaseBattery, in: 0...100, step: 5)
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Text("Батарея: \(Int(testLeftBattery))%")
                            Slider(value: $testLeftBattery, in: 0...100, step: 5)
                        }
                    }

                    Button(action: triggerSimulation) {
                        HStack {
                            Spacer()
                            Label("Запустить Live Activity", systemImage: "play.fill")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section(header: Text("Параметры закрытия")) {
                    Toggle("Авто-закрытие (как у AirPods)", isOn: $activityManager.shouldAutoDismiss)

                    if activityManager.shouldAutoDismiss {
                        Stepper(value: $activityManager.autoDismissDelay, in: 5...60, step: 5) {
                            Text("Закрывать через: \(Int(activityManager.autoDismissDelay)) сек.")
                        }
                    }
                }

                Section(header: Text("Автоматизация через iOS Shortcuts"), footer: Text("Для 100% моментального срабатывания настройте автоматизацию в приложении «Команды» по триггеру Bluetooth.")) {
                    Button(action: copyShortcutsURL) {
                        Label(isShowingCopiedToast ? "Ссылка скопирована!" : "Скопировать URL для автоматизации", systemImage: isShowingCopiedToast ? "checkmark" : "doc.on.doc")
                    }
                    Text("fastpair://connect?name=\(testDeviceName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&left=\(Int(testLeftBattery))&right=\(Int(testRightBattery))&case=\(Int(testCaseBattery))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("FastPair Live")
        }
    }

    private func triggerSimulation() {
        activityManager.startOrUpdateActivity(
            deviceName: testDeviceName,
            leftBattery: Int(testLeftBattery),
            rightBattery: Int(testRightBattery),
            caseBattery: selectedModelType == .tws ? Int(testCaseBattery) : nil,
            singleBattery: selectedModelType != .tws ? Int(testLeftBattery) : nil,
            modelType: selectedModelType
        )
    }

    private func copyShortcutsURL() {
        let urlString = "fastpair://connect?name=\(testDeviceName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&left=\(Int(testLeftBattery))&right=\(Int(testRightBattery))&case=\(Int(testCaseBattery))"
        UIPasteboard.general.string = urlString
        isShowingCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isShowingCopiedToast = false
        }
    }
}
