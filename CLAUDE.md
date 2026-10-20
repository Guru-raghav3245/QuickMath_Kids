# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Product

QuickMath Kids is an Android-only Flutter app (package `quickmath_kids`, applicationId `com.guru.oral_app_new`, live on Google Play) for audio-based mental-math practice, aimed at children aged 6-12. Questions are read aloud via text-to-speech; the child picks an answer from multiple-choice buttons. It works fully offline and collects no personal data. English only (multi-language, badges/rewards are planned, not built).

### Features

- **Operations:** addition, subtraction, multiplication, division, LCM, GCF, each at beginner / intermediate / advanced level. Each level has many specific ranges (e.g. "+5", "Up to 10", "×7", "Mixed ×6–×9", LCM of 3 numbers up to 50).
- **Practice session:** endless questions for the chosen operation and range. A countdown timer (1–60 min) or a count-up timer with no limit. Pause, quit and inactivity modals. Confetti on correct answers. A hint card rotates tips pointing to the speaker button. The speaker button re-reads the question; TTS rate, pitch and volume are adjustable in Settings.
- **Wrong-answer loop:** missed questions are saved (keyed by category `"<operation> - <range display name>"`). The next session for the same operation and range replays them first, before generating new questions. The Wrong Answers screen lets the user review, swipe-delete or clear them.
- **Results:** time taken, attempted and correct counts, and a per-question breakdown. Results can be exported as a PDF and shared (`pdf` + `share_plus`).
- **Quiz history:** completed quizzes are saved with a unique auto-generated title (suffix `-2`, `-3`…). They can be reopened in the Result screen, renamed, deleted or cleared.
- **Other:** daily practice reminder notifications (`flutter_local_notifications`, exact alarms), dark mode, How-to-Use screen, searchable FAQ, support screen, forced-update prompt (`upgrader`).

### Free vs. Premium (one-time in-app purchase, `premium_plan`, ~₹300)

| | Free | Premium |
|---|---|---|
| Quizzes | 3 per day (`daily_quizzes` pref in `start_screen.dart`, reset daily) | Unlimited |
| Session length | Fixed 2 minutes | 1–60 min or no limit |
| Ranges | Basic ones; ranges in `_paidRanges` (`dropdowns/dropdown_widgets.dart`) show a premium snackbar | All, including mixed/advanced and LCM/GCF |
| Quiz history, wrong-answer history, settings, pause | Locked (drawer items route to `PurchaseScreen`) | Available |

Premium UI also changes the theme accent (amber). Gating is spread across `start_screen.dart`, `drawer.dart`, `dropdown_widgets.dart`, `practice_screen.dart`, `app_theme.dart` and `purchase_screen.dart`, all reading `billingServiceProvider`. A new gated feature has to be checked in each of the places that apply.

## Commands

- `flutter pub get` — install deps
- `flutter run` — run on a connected device/emulator (portrait-only)
- `flutter analyze` — lint (`flutter_lints`; `deprecated_member_use` and `unused_local_variable` are ignored in `analysis_options.yaml`; currently ~49 infos, no errors/warnings)
- `flutter test` / `flutter test test/widget_test.dart` — `test/widget_test.dart` is the unmodified counter template with its `MyApp` import commented out; there is effectively no test coverage.
- `dart run flutter_launcher_icons` / `dart run flutter_native_splash:create` — regenerate icons/splash after editing their config in `pubspec.yaml`
- `flutter build appbundle --release` — Play Store build. Version is in `pubspec.yaml` (`version: x.y.z+build`); the build number is the Play version code and must exceed the last upload.

Release signing reads the gitignored `android/key.properties`. Its `storeFile` is an absolute path to the gitignored `android/upload-keystore.jks`, so update it when building on a different machine. `android2/` is a stray secondary Android project; the real one is `android/`. Minification is intentionally off in `android/app/build.gradle.kts`.

## Architecture

State management is Riverpod (`flutter_riverpod` v3, with `StateProvider` / `StateNotifierProvider` / `ChangeNotifierProvider` imported from `flutter_riverpod/legacy`). `main.dart` wraps the app in `ProviderScope`; `SplashScreen` waits up to ~5s for `BillingService.isInitialized`, then routes to `StartScreen`.

- `lib/question_logic/` — UI-free domain.
  - `enum_values.dart`: `Operation` (6 types × 3 levels) and `Range` (one value per difficulty choice shown in the UI).
  - `question_generator.dart`: one large `generateTwoRandomNumbers(Operation, Range)` that switches on operation, then range. It returns `List<int>` of operands **followed by the answer**: `[a, b, answer]`, or `[a, b, c, answer]` for 3-number LCM. `practice_screen.dart` slices this by index, so keep the layout when adding cases. Adding a difficulty means a new `Range` value, a case here, an entry in the start-screen dropdowns, and a `_paidRanges` decision.
  - `tts_translator.dart`: `TTSService.speak`, which reads rate/pitch/volume from the settings providers. `wrong_answer_service.dart`: wrong-question persistence.
- `lib/screens/` — `start_screen/` (operation, range and timer selection; drawer; dropdown grid pickers), `practice_screen/` (the quiz loop in `practice_screen.dart`, with `helpers/` for timer, TTS, hints, confetti and answer options, `ui/` widgets and `modals/`), `result_screen/` (results and `pdf_sharing.dart`), plus history, wrong-answers, settings, notifications, purchase, FAQ, how-to-use and support screens.
- `lib/services/` — `billing_service.dart` (singleton `ChangeNotifier` over `in_app_purchase`; premium flag cached in `flutter_secure_storage`), `settings_service.dart` (TTS providers), `quiz_history_service.dart`.
- Persistence is local only. `shared_preferences` holds JSON string lists under `quiz_history` and `wrong_questions`, plus `daily_quizzes`; the premium flag is in secure storage.
- `lib/app_theme.dart` — dark-mode provider and theme builder; the theme also depends on premium status.
