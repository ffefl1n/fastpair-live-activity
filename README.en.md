# FastPair Live Activity for iOS 🎧

An iOS utility (iOS 16.2+ / iOS 17 / iOS 18) bringing **Google Fast Pair** and **AirPods-style** pop-up connection cards to third-party Bluetooth headphones (Sony, Galaxy Buds, Pixel Buds, Nothing Ear, Xiaomi, Bose, etc.) using native **Live Activities** and **Dynamic Island**.

---

## 💡 How It Works

Because iOS prevents third-party apps from rendering overlays over other apps and SpringBoard, this utility implements the closest native-supported UI experience on iOS:

1. **Dual Connection Monitoring:**
   - **AVAudioSession:** Instantly detects when system audio route switches to Bluetooth (A2DP / HFP / LE Audio).
   - **CoreBluetooth:** Background BLE scanning for **Google Fast Pair** Service (`UUID: FE2C`) and GATT Battery Service (`UUID: 180F`).
2. **Live Activity Trigger:**
   - When a headphone connection is detected, an `Activity<HeadphoneActivityAttributes>` is created.
   - A modern card appears on the Lock Screen and Dynamic Island displaying connection animation, model name, and individual battery levels (Left / Right / Case).
3. **Auto-Dismiss:**
   - Configurable auto-dismiss (e.g. 15 seconds, just like native AirPods popup), or keep-alive while playing.
4. **iOS Shortcuts Automation:**
   - Deep-link support (`fastpair://connect?name=...`) allows 100% reliable wakeups using the iOS Shortcuts "On Bluetooth Connect" automation trigger.

---

## 🛠 Quick Start & Building

### Requirements
- Mac with **Xcode 15+**
- iOS device with **iOS 16.2+** (including iPhone 11 Pro)
- Apple Developer Account (free or paid) for signing

### XcodeGen Setup
```bash
# Install XcodeGen
brew install xcodegen

# Clone repository
git clone https://github.com/ffefl1n/fastpair-live-activity.git
cd fastpair-live-activity

# Generate Xcode project
xcodegen generate
```

Open `FastPairLiveActivity.xcodeproj` in Xcode, configure your Development Team under **Signing & Capabilities**, and deploy to your iPhone.

---

## 📄 License
MIT License
