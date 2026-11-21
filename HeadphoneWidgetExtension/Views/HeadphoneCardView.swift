import SwiftUI

struct HeadphoneCardLockScreenView: View {
    let state: HeadphoneActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 42, height: 42)
                    Image(systemName: state.modelType.defaultSFSymbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(state.deviceName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(state.isConnected ? Color.green : Color.red)
                            .frame(width: 7, height: 7)
                        Text(state.statusMessage)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(state.isConnected ? Color.green : Color.red)
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "wave.3.forward")
                        .font(.caption2)
                    Text("Fast Pair")
                        .font(.caption2.bold())
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.15))
                .clipShape(Capsule())
                .foregroundColor(.white)
            }

            Divider()
                .background(Color.white.opacity(0.15))

            if state.modelType == .tws {
                HStack(spacing: 12) {
                    if let left = state.leftBattery {
                        BatteryCardModule(title: "Левый", subtitle: "L", percentage: left, icon: "earbuds")
                    }
                    if let caseVal = state.caseBattery {
                        BatteryCardModule(title: "Кейс", subtitle: "Case", percentage: caseVal, icon: "bolt.fill")
                    }
                    if let right = state.rightBattery {
                        BatteryCardModule(title: "Правый", subtitle: "R", percentage: right, icon: "earbuds")
                    }
                }
            } else {
                HStack(spacing: 20) {
                    Spacer()
                    if let battery = state.singleBattery ?? state.leftBattery {
                        BatteryCardModule(title: "Заряд аккумулятора", subtitle: "Headset", percentage: battery, icon: "headphones")
                    }
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(white: 0.12).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct BatteryCardModule: View {
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
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            Text("\(percentage)%")
                .font(.system(size: 15, weight: .bold))
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
            .padding(.horizontal, 4)

            Text(subtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct BatteryPill: View {
    let label: String
    let value: Int
    let icon: String

    var body: some View {
        HStack(spacing: 4) {
            if !label.isEmpty {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text("\(value)%")
                .font(.caption2.bold())
                .foregroundColor(.green)
        }
    }
}

struct BatteryMiniIndicator: View {
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.caption2.bold())
                .foregroundColor(.gray)
            Text("\(value)%")
                .font(.caption2.bold())
                .foregroundColor(.white)
        }
    }
}
