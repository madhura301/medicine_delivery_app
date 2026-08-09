# iOS Setup

The iOS project is configured and ready to build. Everything below the
"Requires a Mac" line cannot be done on Windows — Xcode and CocoaPods are
macOS-only, so none of the iOS config in this repo has been compile-verified.

## Already configured

| Item | Value / state |
|---|---|
| Bundle identifier | `com.pharmaish.app` — matches the Android `applicationId` |
| Display name | Pharmaish |
| Deployment target | iOS 13.0 (Xcode project and Podfile agree) |
| App icon | Pharmaish logo, RGB with no alpha channel (Apple rejects icons with alpha) |
| Version | Driven by `pubspec.yaml` (`$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)`) |
| Permission strings | Camera, photo library, microphone, location (when-in-use and always) |
| URL schemes | whatsapp, tel, mailto, and UPI apps for Razorpay's intent flow |
| App Transport Security | Apple defaults — HTTPS only, no arbitrary-loads exemption |
| Podfile | Present, pins iOS 13.0 and scopes `permission_handler` to the permissions actually used |

## Requires a Mac

1. **Install pods** — the `ios/Pods` directory does not exist yet and is
   gitignored:
   ```bash
   cd Flutter_UI
   flutter pub get
   cd ios && pod install && cd ..
   ```
   Commit the resulting `Podfile.lock` so every machine resolves the same pod
   versions. Do not commit `Pods/`.

2. **Signing** — open `ios/Runner.xcworkspace` (the workspace, not the
   `.xcodeproj`) and under Runner → Signing & Capabilities pick the Apple
   Developer team. This creates a provisioning profile for
   `com.pharmaish.app`. Nothing in this repo carries signing identities.

3. **Run and test on a real device.** The simulator cannot exercise camera,
   microphone or GPS, which covers most of this app's permission surface.
   Verify each prompt appears with the right wording: prescription photo
   (camera), gallery upload (photos), voice order (microphone), delivery
   address and nearest-chemist matching (location).

4. **Build:**
   ```bash
   flutter build ios --release -t lib/main.dart          # production
   flutter build ipa --release -t lib/main.dart          # App Store archive
   flutter build ios --release -t lib/main_staging.dart  # staging API
   ```

## Notes and known risks

- **`main_staging.dart` installs an `HttpOverrides` that accepts invalid TLS
  certificates.** That entrypoint is for internal testing only — never submit a
  build made from it. `main.dart` (production) has no such override.

- **Razorpay on iOS is untested.** The UPI schemes in `Info.plist` let iOS
  report which payment apps are installed, but the full payment flow has only
  ever run on Android. Test a real transaction before release.

- **Two things were removed from `Info.plist` as App Store rejection risks**,
  each with a comment in the file explaining why:
  - `NSAllowsArbitraryLoads` — disabled ATS app-wide. All APIs are HTTPS, and
    Apple asks for written justification at review. This mirrors
    `cleartextTrafficPermitted="false"` on Android.
  - `UIBackgroundModes` (`fetch`, `remote-notification`) — the app registers no
    push handler and no background fetch task. Declaring unimplemented
    background modes is a documented rejection reason. Re-add them only
    alongside a real implementation.

- **`permission_handler` macros live in `ios/Podfile`.** If a new permission is
  ever used from Dart, flip the matching `PERMISSION_*` flag to `1` *and* add
  the corresponding `NS...UsageDescription` to `Info.plist`. Enabling one
  without the other fails review.

- **Orientation is unrestricted** (portrait plus both landscapes on iPhone, all
  four on iPad). The layouts were designed for phone portrait — the login
  screen in particular is a tall scrolling column. Worth deciding whether to
  lock to portrait, as Android effectively is in practice.

- **iPad**: the project builds for iPad as a scaled iPhone app. If you list the
  app as iPhone-only on the App Store this is fine; otherwise the layouts need
  a tablet pass.
