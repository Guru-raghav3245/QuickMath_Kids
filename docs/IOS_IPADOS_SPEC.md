# iOS / iPadOS Port: Technical Spec

Status: proposed. Scope: technical changes only (code, project config, build). Store listing copy, pricing and legal text are out of scope except where they need a technical input.

## 1. Goal and non-goals

**Goal:** ship QuickMath Kids on the App Store as a universal app (iPhone + iPad), with iPad as the primary target. It should have feature parity with Android, including the Free/Premium model.

**Non-goals:** new features, multi-language support, Mac Catalyst or the Mac App Store, Apple Watch, widgets.

## 2. Current state

- `ios/` is the unmodified Flutter scaffold: bundle ID `com.guru.oral_app_new`, `CFBundleDisplayName` "Oral App New", deployment target 12.0, `TARGETED_DEVICE_FAMILY = "1,2"` (already universal), automatic signing with no team, no entitlements file.
- App code is mostly platform-neutral Dart. Android-specific parts are billing guards, notifications, the Play redeem flow, and some copy.
- `main.dart` locks orientation to portrait; `Info.plist` allows landscape on both device types (the two disagree).
- Little responsive layout exists, so a phone layout will stretch on iPad.

## 3. Work items

Priority: **P0** is required to ship, **P1** is expected by App Review or users, **P2** is nice to have.

### 3.1 Billing (P0)

| # | Change | Location |
|---|---|---|
| B1 | Remove the `!Platform.isAndroid` early returns in `_performBackgroundVerification()` and `purchasePremium()` (iOS must use the same code path). Update the "only supports Android" messages. | `lib/services/billing_service.dart` (~lines 62, 191) |
| B2 | Create a **non-consumable** IAP with product ID `premium_plan` in App Store Connect (price tier equivalent to ₹300), reference name, localization and a review screenshot. It must reach "Ready to Submit" and be attached to the app version. | App Store Connect |
| B3 | Add a visible **Restore Purchases** button (Apple requirement for non-consumables). It calls `InAppPurchase.restorePurchases()`, and the result flows through the existing `_handlePurchaseUpdates`. Place it on `PurchaseScreen`. | `lib/screens/purchase_screen.dart`, `billing_service.dart` |
| B4 | Verify that `completePurchase` runs for iOS transactions. The existing `pendingCompletePurchase` checks should cover it, but test `purchased`, `restored` and `error` paths in the sandbox. Unfinished transactions are redelivered on every launch. | `billing_service.dart` (~lines 138, 253) |
| B5 | Hide or replace the **Redeem Code** UI on iOS. It opens `play.google.com/redeem`. Either hide it behind `Platform.isAndroid` (P0) or implement Apple Offer Code redemption (`presentCodeRedemptionSheet` from `in_app_purchase_storekit`, P2). Also review the promo-code branch (`billing_service.dart` ~line 55), which grants premium locally and must not become a bypass in the iOS build. | `purchase_screen.dart` (~lines 398-435), `billing_service.dart` |
| B6 | Review the `is_reset` and cached-premium logic against iOS semantics. The Keychain (flutter_secure_storage) **survives uninstall** on iOS, so a cached `is_premium=true` can outlive the purchase. Make `restorePurchases` the source of truth on first launch after install. | `billing_service.dart` |
| B7 | Enable the **In-App Purchase** capability in Xcode (Signing & Capabilities). | `ios/Runner.xcodeproj` |
| B8 | Add a StoreKit configuration file for simulator and local testing (optional but recommended). | `ios/` |

Acceptance: a sandbox tester can buy, uninstall and reinstall, tap Restore, and regain premium. A fresh sandbox account sees the free tier.

### 3.2 iPad-specific (P0)

| # | Change | Location |
|---|---|---|
| P1 | **Share sheet anchor.** `Share.shareXFiles` has no `sharePositionOrigin`. On iPad the share sheet is a popover and fails without it. Pass the share button's rect (via `RenderBox` from the button's `BuildContext`). Verify the call against the installed `share_plus` version's current API. | `lib/screens/result_screen/result_screen.dart` (~line 215) |
| P2 | **Orientation policy.** Decide one of the two options below and make `Info.plist` and `main.dart` agree. **A (recommended):** portrait-only iPad. Set `UIRequiresFullScreen = true` (this opts out of Split View/Slide Over), and restrict the plist orientation arrays to portrait. **B:** support all orientations and multitasking. This needs layouts that work in landscape and at any window width, and removing the `setPreferredOrientations` lock. | `ios/Runner/Info.plist`, `lib/main.dart` |
| P3 | **Large-screen layout.** Cap content width (for example `ConstrainedBox` to ~600-700 pt, centered) on the start, practice, result, history, wrong-answer, settings, purchase, FAQ and how-to screens. Scale answer buttons, the timer card and fonts sensibly. Check the grid pickers and bottom sheets in `dropdowns/` and the modals. Test at 11" and 13" iPad sizes and the smallest iPhone. | `lib/screens/**` |
| P4 | Check dialogs, bottom sheets and popup menus for correct presentation on iPad (they should stay centered and bounded, not full-width). | `lib/screens/**/modals`, `dropdowns/` |
| P5 | Input: keep the app usable with keyboard and pointer (hover or tap) as an iPad convenience, which is low priority. | n/a |

Acceptance: no clipped or stretched UI on 11" and 13" iPads in every supported orientation, and PDF sharing works from the iPad popover.

### 3.3 Platform plumbing (P0)

| # | Change | Location |
|---|---|---|
| X1 | Set display name to **QuickMath Kids** and replace `CFBundleName`. | `ios/Runner/Info.plist` |
| X2 | Decide the **bundle ID**: keep `com.guru.oral_app_new` or choose a new one. Register it in the Apple Developer account and set the signing team. The RunnerTests ID must follow. | `project.pbxproj` |
| X3 | Raise the **deployment target** (12.0 is below what current Flutter and the plugins support; likely iOS 13 or 14). Update `IPHONEOS_DEPLOYMENT_TARGET` in all configs and uncomment or set `platform :ios` in the Podfile. | `project.pbxproj`, `ios/Podfile` |
| X4 | **App icons.** The AppIcon set exists. Verify that the 1024x1024 marketing icon has **no alpha channel** and that the iPad sizes (76, 83.5) are correct. Add an `ios:` target to the `flutter_launcher_icons` config (with `remove_alpha_ios: true`), then regenerate. | `pubspec.yaml`, `Assets.xcassets` |
| X5 | **Launch screen** is the default storyboard. Replace it with a branded one if desired (P2). | `ios/Runner/Base.lproj` |
| X6 | `UIStatusBarHidden` is `true` in `Info.plist`. Confirm that is intended on iOS. | `Info.plist` |
| X7 | Add `ITSAppUsesNonExemptEncryption = false` to skip the export-compliance prompt on each upload, if no custom encryption is used (HTTPS and the Keychain are exempt). | `Info.plist` |
| X8 | Run `pod install`, commit `Podfile.lock`, and make sure all plugins build for the chosen deployment target. | `ios/` |

### 3.4 Notifications (P1)

The reminder code in `notifications_scheduler.dart` builds Android-only details.

- Initialize with `DarwinInitializationSettings` alongside the Android settings, with permission requests off at init and requested explicitly (`requestPermissions`) when the user sets a reminder.
- Pass `DarwinNotificationDetails` in `NotificationDetails(iOS: ...)`.
- In `AppDelegate.swift`, set `UNUserNotificationCenter.current().delegate = self` so notifications show while the app is in the foreground.
- `androidScheduleMode: exactAllowWhileIdle` can stay, since iOS ignores it. iOS has no exact-alarm permission.
- `matchDateTimeComponents: time` (daily repeat) is supported on iOS.
- Handle the "permission denied" state with a message pointing to Settings.
- Heads-up: iOS caps pending local notifications at 64.

### 3.5 Text-to-speech (P0, a core feature)

- Configure the `flutter_tts` audio session on iOS: `setSharedInstance(true)` and `setIosAudioCategory(playback, ...)` so speech plays when the hardware silent switch is on and mixes or ducks properly.
- Check voice selection: `setLanguage('en-US')` works, but speech rate and pitch scales differ between Android and iOS. The 0.5 default rate on iOS is much faster or slower than on Android, so retune the defaults and slider ranges in `settings_service.dart` and `settings_screen.dart`.
- Test interruption handling: incoming call, app backgrounded, and the pause modal.

### 3.6 Remaining plugin checks (P1)

| Plugin | Check |
|---|---|
| `flutter_secure_storage` | Works with default Keychain options. See B6 for uninstall persistence. |
| `shared_preferences` | No change needed. |
| `upgrader` | Uses the iTunes lookup on iOS. It does nothing until the app is live, and it needs the app's App Store country. Make sure it doesn't show a broken prompt in TestFlight. |
| `package_info_plus`, `url_launcher` | `url_launcher` needs `LSApplicationQueriesSchemes` only if you call `canLaunchUrl` for custom schemes. Mailto and https links need nothing. |
| `confetti`, `google_fonts`, `dropdown_button2`, `pdf` | Pure Dart. Smoke test only. `google_fonts` fetches fonts at runtime unless they are bundled, so offline-first iOS builds should bundle them. |
| `change_app_package_name` | A dev-only tool sitting in `dependencies`. Remove it (it should not ship in the app). |

### 3.7 Copy and docs (P1)

- `lib/screens/faq/faq_data.dart` (~line 62): "only available for Android via Google Play" is wrong after the port.
- `README.md`: the Platform line and the Play Store banner.
- Any "Play Store" wording in `purchase_screen.dart` and the billing success and error messages. Make them store-neutral or platform-conditional.
- `CLAUDE.md`: update the platform notes and add iOS build commands.

### 3.8 Kids / privacy compliance (technical inputs)

- Decide whether to enter the **Kids Category** (ages 6-8 or 9-11). It forbids third-party analytics and ads, and requires a **parental gate** before the purchase flow and any external link (support email, privacy policy, store links). If chosen, add a parental gate (a math question or a long-press) in front of `purchasePremium`, `url_launcher` calls and the share sheet.
- Add `ios/Runner/PrivacyInfo.xcprivacy` declaring required-reason API usage (UserDefaults via shared_preferences, file timestamp and disk space APIs used by plugins) and no tracking. Check that each pod ships its own manifest.
- App Privacy answers: no data collected, if that remains true. Confirm that no SDK in the dependency tree collects data.

## 4. Build, test and release

- **Requirements:** macOS, Xcode (current stable), CocoaPods, Apple Developer Program membership, and an App Store Connect app record.
- **Build:** `flutter build ipa --release` (set `--build-name` and `--build-number` from `pubspec.yaml`). Upload via Xcode Organizer or Transporter.
- **Versioning:** `pubspec.yaml`'s `x.y.z+N` feeds `CFBundleShortVersionString` and `CFBundleVersion`. The build number must increase on each TestFlight or App Store upload. It is tracked independently of the Android version code.
- **Test matrix:** a physical iPhone (small and current), a physical iPad, plus the iPad simulator in portrait and landscape. Run flows for sandbox IAP buy and restore, TTS with the silent switch on, notification scheduling, PDF share from iPad, and a dark-mode pass.
- **TestFlight:** internal testing, then external, before submission.
- **CI (optional, P2):** a macOS runner doing `flutter analyze`, `flutter test` and `flutter build ipa --no-codesign`.

## 5. Suggested sequence

1. X1-X4, X8: project config and a clean build on a device.
2. B1-B7: billing and Restore, tested in the sandbox.
3. 3.5 TTS, then 3.4 notifications.
4. P1-P4: iPad share anchor, orientation policy and layouts.
5. 3.6-3.8: plugin checks, copy and privacy manifest, and the Kids decision.
6. TestFlight, fix, submit.

## 6. Open decisions

1. Bundle ID: reuse `com.guru.oral_app_new` or a new one?
2. iPad orientation: portrait-only with full screen (A) or full multitasking support (B)?
3. Kids Category: opt in (needs a parental gate and extra restrictions) or not?
4. Price tier for Premium on iOS, and whether to implement Apple offer codes.
5. Minimum iOS version (13 or 14?), based on the plugin requirements after `pod install`.
