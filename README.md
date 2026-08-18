# MyKeyboard

A custom iOS keyboard extension: adds a persistent number row, larger keys,
haptic feedback (requires Full Access), and a basic word-completion engine
built on `UITextChecker`. Built to be compiled entirely via GitHub Actions —
no Mac required.

## Before you build

You need to change a few placeholder identifiers so they're unique to you:

1. **Bundle IDs** — currently `com.yourname.mykeyboard` and
   `com.yourname.mykeyboard.keyboard` in `project.yml`. Change the prefix to
   whatever's registered in your Apple Developer account.
2. **App Group ID** — currently `group.com.yourname.mykeyboard` in:
   - `Shared/AppGroup.swift`
   - `App/MyKeyboard.entitlements`
   - `Keyboard/Keyboard.entitlements`
   All three must match exactly and must match an App Group you've registered
   in the Developer portal.
3. **exportOptions.plist** — fill in `YOUR_TEAM_ID`, `YOUR_APP_PROFILE_NAME`,
   and `YOUR_EXTENSION_PROFILE_NAME` with your actual Team ID and the exact
   names of your two Ad Hoc provisioning profiles (one for the app, one for
   the extension — both need the App Group and, for the extension, Full
   Access capability enabled in the profile).

## GitHub Actions: unsigned build

The workflow now builds `MyKeyboardApp.app` **unsigned** (`CODE_SIGNING_ALLOWED=NO`)
and just zips it into the standard `Payload/MyKeyboardApp.app` → `.ipa`
folder structure. No signing secrets are needed for the build itself — no
certificate, no provisioning profiles, no Team ID in CI.

That means the actual signing happens later, at install time, via whatever
tool applies your certificate — e.g. **AltStore** or **Sideloadly**, both of
which take an unsigned `.ipa` and re-sign + install it using a cert/profile
you provide on that end. `exportOptions.plist` is unused now with this
workflow and can be deleted, unless you want to switch back to CI-side
signing later.

Push to `main` (or trigger manually from the Actions tab) and the workflow
will produce `MyKeyboard.ipa` as a downloadable build artifact — unsigned,
ready to hand to your sideloading tool of choice.

## Installing the IPA on your device

Since the IPA coming out of CI is unsigned, you'll sign and install it in
one step through your sideloading tool (AltStore, Sideloadly, etc.), pointing
it at the certificate/profile you have. That step needs to happen from a
computer or companion app, since Apple doesn't allow raw `.ipa` installs
directly from Files/Safari.

## Customizing

- **Number row / key sizing** — `Keyboard/KeyLayout.swift` defines the rows;
  `KeyboardSettings.keyHeightMultiplier` (adjustable in the app's Settings
  screen) scales key height live.
- **Haptics** — `Keyboard/KeyboardView.swift`, `KeyboardActionHandler`. Style
  and on/off are stored in the shared App Group and editable from the
  container app.
- **Prediction engine** — `Keyboard/PredictionEngine.swift` defines a
  `PredictionEngine` protocol with one implementation (`SystemPredictionEngine`,
  backed by `UITextChecker`). To upgrade to a stronger engine later (e.g. a
  Core ML next-word model), write a new type conforming to `PredictionEngine`
  and swap it in `KeyboardActionHandler`'s `predictionEngine` property — no
  other code needs to change.

## Known limitations

- Haptics only fire when the user (you) has granted **Full Access** to the
  keyboard in Settings — this is an iOS platform restriction, not a bug.
- The prediction engine is intentionally basic (system spell-check /
  completion dictionary) — see the note above for how to swap in something
  stronger.
