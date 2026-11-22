import SwiftUI

public struct FullscreenPopupView: View {
    public let deviceName: String
    public let leftBattery: Int
    public let rightBattery: Int
    public let caseBattery: Int
    public let autoDismissSeconds: Double
    public let onDismiss: () -> Void

    @State private var appearAnimation = false
    @State private var wavePulse = false
    @State private var timeRemaining: Double = 15.0
    @State private var timer: Timer?

    public init(
        deviceName: String,
        leftBattery: Int = 90,
        rightBattery: Int = 90,
        caseBattery: Int = 95,
        autoDismissSeconds: Double = 15.0,
        onDismiss: @escaping () -> Void
    ) {
        self.deviceName = deviceName
        self.leftBattery = leftBattery
        self.rightBattery = rightBattery
        self.caseBattery = caseBattery
        self.autoDismissSeconds = autoDismissSeconds
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation()
                }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    Capsule()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)

                    VStack(spacing: 4) {
                        Text(deviceName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                                .scaleEffect(wavePulse ? 1.3 : 1.0)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: wavePulse)

                            Text("Подключено")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }

                    ZStack {
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(Color.white.opacity(wavePulse ? 0.05 : 0.25), lineWidth: 1.5)
                                .frame(width: CGFloat(130 + i * 35), height: CGFloat(130 + i * 35))
                                .scaleEffect(wavePulse ? 1.08 : 0.95)
                                .animation(
                                    .easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.25),
                                    value: wavePulse
                                )
                        }

                        VStack(spacing: 8) {
                            HStack(spacing: 24) {
                                Image(systemName: "earbuds")
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(.white)
                                    .shadow(color: .white.opacity(0.3), radius: 10)

                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.yellow)

                                Image(systemName: "earbuds")
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(.white)
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                    .shadow(color: .white.opacity(0.3), radius: 10)
                            }

                            Text("TWS Stereo")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.gray)
                                .textCase(.uppercase)
                                .tracking(2)
                        }
                    }
                    .frame(height: 140)

                    HStack(spacing: 12) {
                        BatteryFullscreenPill(
                            title: "Левый",
                            subtitle: "L",
                            percentage: leftBattery,
                            icon: "earbuds"
                        )

                        BatteryFullscreenPill(
                            title: "Кейс",
                            subtitle: "Case",
                            percentage: caseBattery,
                            icon: "bolt.fill"
                        )

                        BatteryFullscreenPill(
                            title: "Правый",
                            subtitle: "R",
                            percentage: rightBattery,
                            icon: "earbuds"
                        )
                    }
                    .padding(.horizontal, 4)

                    VStack(spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.12))
                                Capsule()
                                    .fill(Color.green.opacity(0.8))
                                    .frame(width: geo.size.width * CGFloat(max(0, timeRemaining / autoDismissSeconds)))
                                    .animation(.linear(duration: 0.1), value: timeRemaining)
                            }
                        }
                        .frame(height: 3)
                        .padding(.horizontal, 8)

                        Text("Закроется автоматически через \(Int(ceil(timeRemaining))) сек.")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }

                    Button(action: dismissWithAnimation) {
                        HStack {
                            Spacer()
                            Text("Готово")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(white: 0.11))
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 24)
                .offset(y: appearAnimation ? 0 : 350)
                .opacity(appearAnimation ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                appearAnimation = true
            }
            wavePulse = true
            startDismissTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func startDismissTimer() {
        timeRemaining = autoDismissSeconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0.1 {
                timeRemaining -= 0.1
            } else {
                timer?.invalidate()
                timer = nil
                dismissWithAnimation()
            }
        }
    }

    private func dismissWithAnimation() {
        withAnimation(.easeOut(duration: 0.25)) {
            appearAnimation = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
}

struct BatteryFullscreenPill: View {
    let title: String
    let subtitle: String
    let percentage: Int
    let icon: String

    var batteryColor: Color {
        if percentage > 20 {
            return .green
        } else if percentage > 10 {
            return .yellow
        } else {
            return .red
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))

            Text("\(percentage)%")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                    Capsule()
                        .fill(batteryColor)
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(percentage) / 100.0)))
                }
            }
            .frame(height: 5)
            .padding(.horizontal, 6)

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
