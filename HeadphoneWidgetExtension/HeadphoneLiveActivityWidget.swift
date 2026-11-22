import ActivityKit
import WidgetKit
import SwiftUI

struct HeadphoneLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HeadphoneActivityAttributes.self) { context in
            HeadphoneCardLockScreenView(state: context.state)
                .activityBackgroundTint(Color.black.opacity(0.65))
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: "earbuds")
                            .font(.title2)
                            .foregroundColor(.white)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.deviceName)
                                .font(.headline)
                                .lineLimit(1)
                            Text(context.state.statusMessage)
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.leading, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
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
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Text("Беспроводные TWS наушники подключены")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            } compactLeading: {
                Image(systemName: "earbuds")
                    .foregroundColor(.green)
            } compactTrailing: {
                Image(systemName: "checkmark")
                    .font(.caption2.bold())
                    .foregroundColor(.green)
            } minimal: {
                Image(systemName: "earbuds")
                    .foregroundColor(.green)
            }
        }
    }
}
