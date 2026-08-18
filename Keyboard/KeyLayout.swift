import Foundation

enum KeyAction: Equatable {
    case character(String)
    case shift
    case backspace
    case space
    case returnKey
    case globe
    case switchToNumbers
    case switchToLetters
    case switchToSymbols
}

struct KeyModel: Identifiable, Equatable {
    let id = UUID()
    let action: KeyAction
    let displayLetters: (lower: String, upper: String)
    /// Relative width weight versus a standard letter key (1.0 = standard).
    var widthWeight: Double = 1.0

    init(_ char: String, widthWeight: Double = 1.0) {
        self.action = .character(char)
        self.displayLetters = (char, char.uppercased())
        self.widthWeight = widthWeight
    }

    init(action: KeyAction, label: String, widthWeight: Double = 1.0) {
        self.action = action
        self.displayLetters = (label, label)
        self.widthWeight = widthWeight
    }
}

enum KeyLayout {
    static let numberRow: [KeyModel] = "1234567890".map { KeyModel(String($0)) }

    static let letterRows: [[KeyModel]] = [
        "qwertyuiop".map { KeyModel(String($0)) },
        "asdfghjkl".map { KeyModel(String($0)) },
        [KeyModel(action: .shift, label: "shift", widthWeight: 1.4)]
            + "zxcvbnm".map { KeyModel(String($0)) }
            + [KeyModel(action: .backspace, label: "delete.left", widthWeight: 1.4)]
    ]

    static let bottomRow: [KeyModel] = [
        KeyModel(action: .switchToNumbers, label: "123", widthWeight: 1.3),
        KeyModel(action: .globe, label: "globe", widthWeight: 1.0),
        KeyModel(action: .space, label: "space", widthWeight: 4.0),
        KeyModel(action: .returnKey, label: "return", widthWeight: 1.6)
    ]

    static let symbolsRow1: [KeyModel] = "@#$_&-+()".map { KeyModel(String($0)) }
    static let symbolsRow2: [KeyModel] = "*\"':;!?".map { KeyModel(String($0)) }
}
