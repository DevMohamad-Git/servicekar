import 'package:flutter/material.dart';

part 'colors.dart';
part 'font_sizes.dart';
part 'text_style_extensions.dart';
part 'app_typography.dart';
part 'app_button_theme.dart';
part 'app_input_theme.dart';

/// Theme bundle for the Servicar app.
///
/// Combines Lalafen's part-composition pattern with three
/// ServiceKar-specific extensions that Lalafen doesn't ship:
///
///   **Lalafen-aligned** (lifted from
///   `lalafen/lib/config/themes/`):
///   * `colors.dart` — raw brand colour tokens.
///   * `font_sizes.dart` — numeric typographic scales +
///     `kAppbarHeight` for AppBar geometry.
///   * `text_style_extensions.dart` — `TextStyle.create({...})` /
///     `withDefaults({...})` factory helpers.
///
///   **ServiceKar extensions** (this app's domain):
///   * `app_typography.dart` — `buildAppTextTheme(TextTheme)` lifts
///     M3 default sizes ~2sp for the README's "Large and Readable
///     User Interface" requirement (low-light customer sites).
///   * `app_button_theme.dart` — four M3 button variant factories
///     sharing 48dp tap target and 12dp radius, wired through
///     [ThemeData.filledButtonTheme] etc.
///   * `app_input_theme.dart` — filled-rounded `InputDecoration`
///     for customer form fields.
mixin AppThemes {
  /// Default Material 3 light theme for ServiceKar.
  static ThemeData get light {
    final base = ThemeData.light();
    const colorScheme = ColorScheme.light(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      tertiary: kTertiaryColor,
      scrim: kQuaternaryColor,
      surface: kBackgroundColor,
    );

    const appBarTheme = AppBarTheme(
      backgroundColor: kBackgroundColor,
      foregroundColor: kTextPrimaryColor,
      elevation: 0,
      toolbarHeight: kAppbarHeight,
      centerTitle: false,
    );
    const iconButtonTheme = IconButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStatePropertyAll(0),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        visualDensity: VisualDensity.compact,
        splashFactory: NoSplash.splashFactory,
      ),
    );
    final checkboxTheme = CheckboxThemeData(
      splashRadius: 0,
      visualDensity: VisualDensity.compact,
      checkColor: WidgetStateProperty.all(Colors.white),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: const BorderSide(color: Colors.grey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: kBackgroundColor,
      appBarTheme: appBarTheme,
      iconButtonTheme: iconButtonTheme,
      checkboxTheme: checkboxTheme,
      splashColor: kGrey4Color.withValues(alpha: 0.3),
      highlightColor: kGrey4Color.withValues(alpha: 0.6),
      colorScheme: colorScheme,
      // ─── ServiceKar extensions (wired through the part files) ───
      textTheme: buildAppTextTheme(base.textTheme),
      primaryTextTheme: buildAppTextTheme(base.primaryTextTheme),
      filledButtonTheme: buildFilledButtonTheme(),
      elevatedButtonTheme: buildElevatedButtonTheme(),
      outlinedButtonTheme: buildOutlinedButtonTheme(),
      textButtonTheme: buildTextButtonTheme(),
      inputDecorationTheme: buildAppInputTheme(colorScheme),
    );
  }
}
