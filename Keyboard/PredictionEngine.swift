import UIKit

/// Protocol so you can swap in a stronger engine later (Core ML model,
/// Presage, a personal n-gram model, etc.) without touching the UI layer.
protocol PredictionEngine {
    /// Returns ranked completions/suggestions for the current partial word,
    /// optionally using the preceding word for light context.
    func suggestions(for partialWord: String, previousWord: String?) -> [String]
}

/// Baseline engine built on UITextChecker (system spell-check + completion
/// dictionary). Not as strong as Gboard's neural model, but works fully
/// offline, requires no bundled model weights, and is a reasonable
/// placeholder until a Core ML model is wired in (see PredictionEngine
/// protocol above for the swap point).
final class SystemPredictionEngine: PredictionEngine {
    private let checker = UITextChecker()

    func suggestions(for partialWord: String, previousWord: String?) -> [String] {
        guard !partialWord.isEmpty else { return [] }

        let range = NSRange(location: 0, length: partialWord.utf16.count)

        // Word completions (e.g. "hel" -> "hello", "help").
        let completions = checker.completions(
            forPartialWordRange: range,
            in: partialWord,
            language: "en_US"
        ) ?? []

        if !completions.isEmpty {
            return Array(completions.prefix(3))
        }

        // Fall back to spelling-guess if no direct completions found.
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: partialWord,
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en_US"
        )

        if misspelledRange.location != NSNotFound {
            let guesses = checker.guesses(
                forWordRange: misspelledRange,
                in: partialWord,
                language: "en_US"
            ) ?? []
            return Array(guesses.prefix(3))
        }

        return []
    }
}
