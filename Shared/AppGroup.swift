import Foundation

/// Change this to match the App Group identifier you register in the
/// Apple Developer portal (must match both entitlements files exactly).
enum AppGroup {
    static let identifier = "group.com.yourname.mykeyboard"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }
}

/// Settings shared between the container app and the keyboard extension,
/// backed by the shared App Group UserDefaults suite.
enum KeyboardSettings {
    private enum Keys {
        static let hapticsEnabled = "hapticsEnabled"
        static let hapticStyle = "hapticStyle"
        static let keyHeightMultiplier = "keyHeightMultiplier"
        static let showNumberRow = "showNumberRow"
    }

    static var hapticsEnabled: Bool {
        get { AppGroup.defaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? true }
        set { AppGroup.defaults.set(newValue, forKey: Keys.hapticsEnabled) }
    }

    /// 0 = light, 1 = medium, 2 = heavy
    static var hapticStyle: Int {
        get { AppGroup.defaults.object(forKey: Keys.hapticStyle) as? Int ?? 2 }
        set { AppGroup.defaults.set(newValue, forKey: Keys.hapticStyle) }
    }

    /// Multiplier applied to the stock key height. 1.0 = stock size.
    static var keyHeightMultiplier: Double {
        get { AppGroup.defaults.object(forKey: Keys.keyHeightMultiplier) as? Double ?? 1.18 }
        set { AppGroup.defaults.set(newValue, forKey: Keys.keyHeightMultiplier) }
    }

    static var showNumberRow: Bool {
        get { AppGroup.defaults.object(forKey: Keys.showNumberRow) as? Bool ?? true }
        set { AppGroup.defaults.set(newValue, forKey: Keys.showNumberRow) }
    }
}
