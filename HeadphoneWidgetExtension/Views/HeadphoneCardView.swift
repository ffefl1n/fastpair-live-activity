import SwiftUI

struct HeadphoneCardLockScreenView: View {
    let state: HeadphoneActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 46, height: 46)
                Image(systemName: "earbuds")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(state.deviceName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Circle()
                        .fill(state.isConnected ? Color.green : Color.red)
                        .frame(width: 7, height: 7)
                    Text(state.isConnected ? "Подключено" : "Отключено")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(state.isConnected ? Color.green : Color.red)
                    Text("•")
                        .foregroundColor(.gray)
                    Text("Bluetooth Audio")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "wave.3.forward")
                    .font(.caption2)
                Text("Fast Pair")
                    .font(.caption2.bold())
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.15))
            .clipShape(Capsule())
            .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(white: 0.11).opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}
