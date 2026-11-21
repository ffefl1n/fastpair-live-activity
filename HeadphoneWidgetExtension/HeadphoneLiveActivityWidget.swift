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
                    HStack(spacing: 6) {
                        Image(systemName: context.state.modelType.defaultSFSymbol)
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading) {
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
                    if let single = context.state.singleBattery {
                        BatteryPill(label: "", value: single, icon: "battery.100")
                    } else if let avg = averageBattery(context.state) {
                        BatteryPill(label: "Заряд", value: avg, icon: "battery.100")
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.modelType == .tws {
                        HStack(spacing: 16) {
                            if let left = context.state.leftBattery {
                                BatteryMiniIndicator(label: "L", value: left)
                            }
                            if let caseVal = context.state.caseBattery {
                                BatteryMiniIndicator(label: "⚡", value: caseVal)
                            }
                            if let right = context.state.rightBattery {
                                BatteryMiniIndicator(label: "R", value: right)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.modelType.defaultSFSymbol)
                    .foregroundColor(.green)
            } compactTrailing: {
                if let single = context.state.singleBattery {
                    Text("\(single)%")
                        .font(.caption2.bold())
                        .foregroundColor(.green)
                } else if let avg = averageBattery(context.state) {
                    Text("\(avg)%")
                        .font(.caption2.bold())
                        .foregroundColor(.green)
                } else {
                    Text("OK")
                        .font(.caption2.bold())
                        .foregroundColor(.green)
                }
            } minimal: {
                Image(systemName: context.state.modelType.defaultSFSymbol)
                    .foregroundColor(.green)
            }
        }
    }

    private func averageBattery(_ state: HeadphoneActivityAttributes.ContentState) -> Int? {
        let values = [state.leftBattery, state.rightBattery].compactMap { $0 }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / values.count
    }
}
