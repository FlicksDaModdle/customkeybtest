import UIKit
import SwiftUI

final class KeyboardViewController: UIInputViewController {
    private let handler = KeyboardActionHandler()
    private var hostingController: UIHostingController<KeyboardView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        handler.proxy = textDocumentProxy
        handler.advanceToNextInputMode = { [weak self] in
            self?.advanceToNextInputMode()
        }
        handler.hasFullAccess = hasFullAccess

        let keyboardView = KeyboardView(handler: handler)
        let hosting = UIHostingController(rootView: keyboardView)
        hostingController = hosting

        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosting.didMove(toParent: self)

        // Give the extension enough height for the number row + bigger keys.
        let heightConstraint = view.heightAnchor.constraint(
            equalToConstant: 260 * CGFloat(KeyboardSettings.keyHeightMultiplier)
        )
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Full Access can change while the extension is running (user
        // toggles it in Settings), so re-check each time the keyboard shows.
        handler.hasFullAccess = hasFullAccess
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // No-op, but required override point if you later want to react
        // to the proxy changing (e.g. switching text fields).
    }

    override func textDidChange(_ textInput: UITextInput?) {
        handler.proxy = textDocumentProxy
    }
}
