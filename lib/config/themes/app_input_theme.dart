part of 'app_themes.dart';

/// Builds the global `inputDecorationTheme` for [AppThemes].
///
/// Drives every [TextField] / [TextFormField] across the app —
/// `CreateCustomerPage`, `EditCustomerPage`, and
/// `CustomerSearchBarWidget` all rely on this to inherit a
/// consistent filled-rounded look without per-widget styling.
///
/// Why `buildAppInputTheme` exists when Lalafen does NOT include
/// one — Lalafen's UI is content-playback-only (lullabies, white
/// noise, audio albums); it has no forms. ServiceKar's customer
/// onboarding flow needs a canonical, theme-aligned
/// `InputDecoration` so every form field renders identically
/// across screens; otherwise `Create / Edit Customer` style drift
/// over time.
///
/// Design choices:
///   * **Filled, not outlined** — Material 3's default treatment;
///     reads faster than the legacy outlined-only style and lets
///     the field "sink" into the background.
///   * **12dp corner radius** — matches the button / card radius
///     for visual coherence.
///   * **16/14 content padding** — meets the 48dp effective tap
///     target once the label padding is folded in.
///
/// The [scheme] parameter supplies `surfaceContainerHighest`,
/// `outline`, `primary`, and `error` for fill / border colours,
/// and the resulting theme follows light / dark flips automatically.
InputDecorationTheme buildAppInputTheme(ColorScheme scheme) {
  return InputDecorationTheme(
    filled: true,
    fillColor: scheme.surfaceContainerHighest,
    hoverColor: scheme.surfaceContainerHigh,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.error, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.error, width: 2),
    ),
    labelStyle: TextStyle(color: scheme.onSurfaceVariant),
    floatingLabelStyle: TextStyle(color: scheme.primary),
  );
}
