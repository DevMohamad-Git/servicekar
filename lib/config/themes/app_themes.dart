import 'package:flutter/material.dart';

/// Theme shell that mirrors `lalafen/lib/config/themes/app_themes.dart`.
///
/// Today it just exposes the stock Material 3 light/dark themes so the
/// app compiles and runs. Once design tokens (colors, typography,
/// spacing) are agreed on, replace the bodies here without touching
/// the rest of the app.
class AppThemes {
  const AppThemes._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    ),
  );
}
