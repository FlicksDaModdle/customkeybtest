import SwiftUI

struct ContentView: View {
    @AppStorage(
        "hapticsEnabled", store: UserDefaults(suiteName: AppGroup.identifier)
    ) private var hapticsEnabled: Bool = true

    @AppStorage(
        "hapticStyle", store: UserDefaults(suiteName: AppGroup.identifier)
    ) private var hapticStyle: Int = 2

    @AppStorage(
        "keyHeightMultiplier", store: UserDefaults(suiteName: AppGroup.identifier)
    ) private var keyHeightMultiplier: Double = 1.18

    @AppStorage(
        "showNumberRow", store: UserDefaults(suiteName: AppGroup.identifier)
    ) private var showNumberRow: Bool = true

    var body: some View {
        NavigationView {
            Form {
                Section("Setup") {
                    Text("1. Go to Settings > General > Keyboard > Keyboards > Add New Keyboard, and enable MyKeyboard.")
                    Text("2. Tap MyKeyboard in that list again and turn on Allow Full Access. This is required for haptics to work.")
                }

                Section("Layout") {
                    Toggle("Show number row", isOn: $showNumberRow)
                    VStack(alignment: .leading) {
                        Text("Key height: \(String(format: "%.0f%%", keyHeightMultiplier * 100))")
                        Slider(value: $keyHeightMultiplier, in: 1.0...1.4, step: 0.02)
                    }
                }

                Section("Haptics") {
                    Toggle("Enable haptics", isOn: $hapticsEnabled)
                    Picker("Strength", selection: $hapticStyle) {
                        Text("Light").tag(0)
                        Text("Medium").tag(1)
                        Text("Heavy").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .disabled(!hapticsEnabled)
                }

                Section {
                    Button("Open Settings App") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .navigationTitle("MyKeyboard")
        }
    }
}

#Preview {
    ContentView()
}
