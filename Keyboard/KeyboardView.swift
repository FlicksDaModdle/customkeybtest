import SwiftUI
import UIKit

enum KeyboardMode {
    case letters
    case numbers
    case symbols
}

/// Bridges SwiftUI actions back to the UIInputViewController's textDocumentProxy.
final class KeyboardActionHandler: ObservableObject {
    weak var proxy: UITextDocumentProxy?
    var advanceToNextInputMode: (() -> Void)?

    @Published var mode: KeyboardMode = .letters
    @Published var isShifted: Bool = false
    @Published var suggestions: [String] = []

    private let predictionEngine: PredictionEngine = SystemPredictionEngine()
    private var lightGenerator: UIImpactFeedbackGenerator?
    private var mediumGenerator: UIImpactFeedbackGenerator?
    private var heavyGenerator: UIImpactFeedbackGenerator?

    /// Full Access is required for haptics to fire at all inside a keyboard
    /// extension. Pass this in from the view controller.
    var hasFullAccess: Bool = false {
        didSet { prepareGeneratorsIfNeeded() }
    }

    private func prepareGeneratorsIfNeeded() {
        guard hasFullAccess else { return }
        lightGenerator = UIImpactFeedbackGenerator(style: .light)
        mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
        heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
        [lightGenerator, mediumGenerator, heavyGenerator].forEach { $0?.prepare() }
    }

    func handle(_ action: KeyAction) {
        fireHaptic()

        switch action {
        case .character(let char):
            let text = isShifted ? char.uppercased() : char
            proxy?.insertText(text)
            if isShifted { isShifted = false }
            updateSuggestions()

        case .shift:
            isShifted.toggle()

        case .backspace:
            proxy?.deleteBackward()
            updateSuggestions()

        case .space:
            proxy?.insertText(" ")
            suggestions = []

        case .returnKey:
            proxy?.insertText("\n")
            suggestions = []

        case .globe:
            advanceToNextInputMode?()

        case .switchToNumbers:
            mode = .numbers

        case .switchToLetters:
            mode = .letters

        case .switchToSymbols:
            mode = .symbols
        }
    }

    func applySuggestion(_ word: String) {
        // Remove the partial word already typed, then insert the full word + space.
        if let current = currentWordFragment(), !current.isEmpty {
            for _ in 0..<current.count {
                proxy?.deleteBackward()
            }
        }
        proxy?.insertText(word + " ")
        suggestions = []
    }

    private func updateSuggestions() {
        guard let fragment = currentWordFragment(), fragment.count >= 2 else {
            suggestions = []
            return
        }
        suggestions = predictionEngine.suggestions(for: fragment, previousWord: nil)
    }

    private func currentWordFragment() -> String? {
        guard let before = proxy?.documentContextBeforeInput else { return nil }
        let trimmed = before.split(separator: " ", omittingEmptySubsequences: false).last ?? ""
        return String(trimmed)
    }

    private func fireHaptic() {
        guard hasFullAccess, KeyboardSettings.hapticsEnabled else { return }
        switch KeyboardSettings.hapticStyle {
        case 0: lightGenerator?.impactOccurred()
        case 1: mediumGenerator?.impactOccurred()
        default: heavyGenerator?.impactOccurred()
        }
    }
}

struct KeyboardView: View {
    @ObservedObject var handler: KeyboardActionHandler

    private var keyHeight: CGFloat {
        42 * CGFloat(KeyboardSettings.keyHeightMultiplier)
    }

    var body: some View {
        VStack(spacing: 8) {
            if !handler.suggestions.isEmpty {
                suggestionBar
            }

            if KeyboardSettings.showNumberRow {
                rowView(KeyLayout.numberRow)
            }

            switch handler.mode {
            case .letters:
                ForEach(Array(KeyLayout.letterRows.enumerated()), id: \.offset) { _, row in
                    rowView(row)
                }
            case .numbers:
                rowView(KeyLayout.symbolsRow1)
                rowView(KeyLayout.symbolsRow2)
            case .symbols:
                rowView(KeyLayout.symbolsRow1)
                rowView(KeyLayout.symbolsRow2)
            }

            rowView(KeyLayout.bottomRow)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    private var suggestionBar: some View {
        HStack(spacing: 0) {
            ForEach(handler.suggestions, id: \.self) { word in
                Button {
                    handler.applySuggestion(word)
                } label: {
                    Text(word)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                if word != handler.suggestions.last {
                    Divider().frame(height: 20)
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(6)
    }

    private func rowView(_ keys: [KeyModel]) -> some View {
        HStack(spacing: 6) {
            ForEach(keys) { key in
                keyButton(key)
            }
        }
    }

    private func keyButton(_ key: KeyModel) -> some View {
        Button {
            handler.handle(key.action)
        } label: {
            keyLabel(key)
                .frame(maxWidth: .infinity)
                .frame(height: keyHeight)
                .background(keyBackground(key))
                .cornerRadius(6)
        }
        .frame(width: nil)
        .layoutPriority(key.widthWeight)
        .frame(maxWidth: .infinity)
        .scaleEffect(1.0)
        .modifier(KeyWidthModifier(weight: key.widthWeight))
    }

    @ViewBuilder
    private func keyLabel(_ key: KeyModel) -> some View {
        switch key.action {
        case .character(let char):
            Text(handler.isShifted ? char.uppercased() : char)
                .font(.system(size: 22))
        case .shift:
            Image(systemName: handler.isShifted ? "shift.fill" : "shift")
                .font(.system(size: 18))
        case .backspace:
            Image(systemName: "delete.left")
                .font(.system(size: 18))
        case .space:
            Text("space")
                .font(.system(size: 14))
        case .returnKey:
            Text("return")
                .font(.system(size: 14))
        case .globe:
            Image(systemName: "globe")
                .font(.system(size: 18))
        case .switchToNumbers:
            Text("123")
                .font(.system(size: 16))
        case .switchToLetters:
            Text("ABC")
                .font(.system(size: 16))
        case .switchToSymbols:
            Text("#+=")
                .font(.system(size: 16))
        }
    }

    private func keyBackground(_ key: KeyModel) -> Color {
        switch key.action {
        case .character:
            return Color(.systemBackground)
        default:
            return Color(.secondarySystemBackground)
        }
    }
}

/// Applies a relative width weight to a key inside its HStack.
private struct KeyWidthModifier: ViewModifier {
    let weight: Double
    func body(content: Content) -> some View {
        content.layoutPriority(weight)
    }
}
