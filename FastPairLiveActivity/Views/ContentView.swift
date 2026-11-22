import SwiftUI

struct ContentView: View {
    @ObservedObject var settings = SettingsManager.shared
    @EnvironmentObject var audioMonitor: AudioRouteMonitor
    @EnvironmentObject var bleScanner: FastPairBLEScanner
    @EnvironmentObject var activityManager: LiveActivityManager

    @State private var isShowingFullscreenDemo = false
    @State private var isShowingCopiedToast = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Быстрый выбор наушников")) {
                    Button(action: {
                        settings.applyRedmiBuds8ActivePreset()
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "earbuds")
                                    .font(.title3)
                                    .foregroundColor(.red)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Пресет: Redmi Buds 8 Active")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("TWS, 15 сек. авто-закрытие, Fullscreen")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(settings.deviceName == "Redmi Buds 8 Active" ? .green : .clear)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section(header: Text("Состояние подключения")) {
                    HStack {
                        Image(systemName: audioMonitor.isBluetoothAudioConnected ? "headphones" : "headphones.circle")
                            .foregroundColor(audioMonitor.isBluetoothAudioConnected ? .green : .secondary)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(audioMonitor.isBluetoothAudioConnected ? "Подключено к аудио" : "Ожидание подключения...")
                                .font(.headline)
                            Text(audioMonitor.connectedDeviceName ?? settings.deviceName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Image(systemName: activityManager.activeActivityId != nil ? "bolt.fill" : "bolt.slash")
                            .foregroundColor(activityManager.activeActivityId != nil ? .yellow : .secondary)
                        Text("Live Activity:")
                        Spacer()
                        Text(activityManager.activeActivityId != nil ? "Активна (15 сек.)" : "Спит")
                            .foregroundColor(activityManager.activeActivityId != nil ? .green : .secondary)
                    }

                    if activityManager.activeActivityId != nil {
                        Button(role: .destructive, action: {
                            activityManager.stopActivityImmediately()
                        }) {
                            Label("Закрыть Live Activity", systemImage: "xmark.circle")
                        }
                    }
                }

                Section(header: Text("Просмотр карточки и Fullscreen"), footer: Text("Нажмите кнопку, чтобы увидеть полноэкранное окно с анимацией и запустить Live Activity.")) {
                    TextField("Имя устройства", text: $settings.deviceName)

                    VStack(alignment: .leading) {
                        Text("Левый наушник: \(settings.defaultLeftBattery)%")
                        Slider(value: Binding(
                            get: { Double(settings.defaultLeftBattery) },
                            set: { settings.defaultLeftBattery = Int($0) }
                        ), in: 0...100, step: 5)
                    }

                    VStack(alignment: .leading) {
                        Text("Правый наушник: \(settings.defaultRightBattery)%")
                        Slider(value: Binding(
                            get: { Double(settings.defaultRightBattery) },
                            set: { settings.defaultRightBattery = Int($0) }
                        ), in: 0...100, step: 5)
                    }

                    VStack(alignment: .leading) {
                        Text("Кейс: \(settings.defaultCaseBattery)%")
                        Slider(value: Binding(
                            get: { Double(settings.defaultCaseBattery) },
                            set: { settings.defaultCaseBattery = Int($0) }
                        ), in: 0...100, step: 5)
                    }

                    Button(action: triggerFullConnectionFlow) {
                        HStack {
                            Spacer()
                            Label("Показать Fullscreen + Live Activity", systemImage: "play.circle.fill")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section(header: Text("Параметры сохранения и таймера")) {
                    Toggle("Авто-закрытие карточки", isOn: $settings.autoDismiss)

                    if settings.autoDismiss {
                        Stepper(value: $settings.autoDismissDelay, in: 5...60, step: 5) {
                            Text("Таймер закрытия: \(Int(settings.autoDismissDelay)) сек.")
                        }
                    }

                    Toggle("Показывать Fullscreen при открытии", isOn: $settings.showFullscreenOnConnect)
                }

                Section(header: Text("Автоматизация через iOS Shortcuts"), footer: Text("При подключении Redmi Buds 8 Active шорткат откроет приложение на долю секунды, покажет Fullscreen шторку и запустит 15-секундную Live Activity.")) {
                    Button(action: copyShortcutsURL) {
                        Label(isShowingCopiedToast ? "Ссылка скопирована!" : "Скопировать URL для шортката", systemImage: isShowingCopiedToast ? "checkmark" : "doc.on.doc")
                    }
                    Text("fastpair://connect")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("FastPair Live")
        }
        .sheet(isPresented: $isShowingFullscreenDemo) {
            FullscreenPopupView(
                deviceName: audioMonitor.connectedDeviceName ?? settings.deviceName,
                leftBattery: settings.defaultLeftBattery,
                rightBattery: settings.defaultRightBattery,
                caseBattery: settings.defaultCaseBattery,
                autoDismissSeconds: settings.autoDismissDelay,
                onDismiss: {
                    isShowingFullscreenDemo = false
                }
            )
        }
    }

    private func triggerFullConnectionFlow() {
        let name = audioMonitor.connectedDeviceName ?? settings.deviceName

        activityManager.startOrUpdateActivity(
            deviceName: name,
            leftBattery: settings.defaultLeftBattery,
            rightBattery: settings.defaultRightBattery,
            caseBattery: settings.defaultCaseBattery,
            modelType: settings.modelType
        )

        isShowingFullscreenDemo = true
    }

    private func copyShortcutsURL() {
        UIPasteboard.general.string = "fastpair://connect"
        isShowingCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isShowingCopiedToast = false
        }
    }
}
