import SwiftUI

struct ContentView: View {
    @ObservedObject var settings = SettingsManager.shared
    @EnvironmentObject var audioMonitor: AudioRouteMonitor
    @EnvironmentObject var bleScanner: FastPairBLEScanner
    @EnvironmentObject var activityManager: LiveActivityManager

    @State private var wavePulse = false
    @State private var timeRemaining: Double = 15.0
    @State private var timer: Timer?
    @State private var isShowingSettingsSheet = false
    @State private var isShowingCopiedToast = false

    var currentDeviceName: String {
        audioMonitor.connectedDeviceName ?? settings.deviceName
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(white: 0.08),
                    Color(white: 0.03),
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "wave.3.forward")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                        Text("FAST PAIR")
                            .font(.system(size: 13, weight: .black))
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())

                    Spacer()

                    Button(action: {
                        isShowingSettingsSheet = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(10)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                VStack(spacing: 24) {
                    ZStack {
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(Color.white.opacity(wavePulse ? 0.06 : 0.22), lineWidth: 1.5)
                                .frame(width: CGFloat(140 + i * 40), height: CGFloat(140 + i * 40))
                                .scaleEffect(wavePulse ? 1.08 : 0.94)
                                .animation(
                                    .easeInOut(duration: 1.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.28),
                                    value: wavePulse
                                )
                        }

                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )

                            HStack(spacing: 16) {
                                Image(systemName: "earbuds")
                                    .font(.system(size: 44, weight: .light))
                                    .foregroundColor(.white)
                                    .shadow(color: .white.opacity(0.4), radius: 12)

                                Image(systemName: "earbuds")
                                    .font(.system(size: 44, weight: .light))
                                    .foregroundColor(.white)
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                    .shadow(color: .white.opacity(0.4), radius: 12)
                            }
                        }
                    }
                    .frame(height: 180)

                    VStack(spacing: 8) {
                        Text(currentDeviceName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 16)

                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 9, height: 9)
                                .scaleEffect(wavePulse ? 1.3 : 1.0)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: wavePulse)

                            Text("Подключено к iPhone")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.green)
                        }

                        Text("Беспроводные наушники • Bluetooth")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }

                    VStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.12))
                                Capsule()
                                    .fill(Color.green)
                                    .frame(width: geo.size.width * CGFloat(max(0, timeRemaining / settings.autoDismissDelay)))
                                    .animation(.linear(duration: 0.1), value: timeRemaining)
                            }
                        }
                        .frame(height: 4)
                        .padding(.horizontal, 24)

                        Text("Авто-закрытие через \(Int(ceil(timeRemaining))) сек.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 8)

                    Button(action: {
                        dismissCard()
                    }) {
                        HStack {
                            Spacer()
                            Text("Готово")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(Color(white: 0.12).opacity(0.95))
                        .overlay(
                            RoundedRectangle(cornerRadius: 36, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)

                Spacer()
            }
        }
        .onAppear {
            wavePulse = true
            startCountdown()
            activityManager.startOrUpdateActivity(deviceName: currentDeviceName)
        }
        .sheet(isPresented: $isShowingSettingsSheet) {
            settingsSheetView
        }
    }

    private var settingsSheetView: some View {
        NavigationView {
            List {
                Section(header: Text("Текущие наушники")) {
                    Button(action: {
                        settings.applyRedmiBuds8Active()
                    }) {
                        HStack {
                            Label("Сбросить на Redmi Buds 8 Active", systemImage: "arrow.counterclockwise")
                            Spacer()
                            if settings.deviceName == "Redmi Buds 8 Active" {
                                Image(systemName: "checkmark").foregroundColor(.green)
                            }
                        }
                    }

                    TextField("Имя устройства", text: $settings.deviceName)
                }

                Section(header: Text("Параметры таймера")) {
                    Toggle("Авто-закрытие через 15 сек.", isOn: $settings.autoDismiss)

                    if settings.autoDismiss {
                        Stepper(value: $settings.autoDismissDelay, in: 5...60, step: 5) {
                            Text("Длительность: \(Int(settings.autoDismissDelay)) сек.")
                        }
                    }
                }

                Section(header: Text("Быстрые команды (Shortcuts)")) {
                    Button(action: copyShortcutsURL) {
                        Label(isShowingCopiedToast ? "Скопировано!" : "Скопировать URL: fastpair://connect", systemImage: isShowingCopiedToast ? "checkmark" : "doc.on.doc")
                    }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarItems(trailing: Button("Закрыть") {
                isShowingSettingsSheet = false
                resetCountdown()
            })
        }
    }

    private func startCountdown() {
        timer?.invalidate()
        timeRemaining = settings.autoDismissDelay
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0.1 {
                timeRemaining -= 0.1
            } else {
                timer?.invalidate()
                timer = nil
                dismissCard()
            }
        }
    }

    private func resetCountdown() {
        startCountdown()
    }

    private func dismissCard() {
        timer?.invalidate()
        timer = nil
        activityManager.stopActivityImmediately()
    }

    private func copyShortcutsURL() {
        UIPasteboard.general.string = "fastpair://connect"
        isShowingCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isShowingCopiedToast = false
        }
    }
}
