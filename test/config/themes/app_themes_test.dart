import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/config/themes/app_themes.dart';

/// Infrastructure test for `AppThemes.light`.
///
/// Why this test exists ──────────────────────────────────────────
/// The theme bundle has *many* independent layers (color scheme,
/// typography, button factories, input theme, AppBar geometry). A
/// single Material 3 refactor can regress one layer while leaving
/// the others intact, so we lock each one down with a focused
/// assertion. No widget mounting is required — `ThemeData` is a
/// plain Dart object whose getters are stable across the build.
void main() {
  group('AppThemes.light', () {
    test('is a Material 3 light theme', () {
      final theme = AppThemes.light;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
    });

    test('color scheme binds the ServiceKar brand palette', () {
      final theme = AppThemes.light;
      expect(theme.colorScheme.primary, kPrimaryColor);
      expect(theme.colorScheme.secondary, kSecondaryColor);
      expect(theme.colorScheme.tertiary, kTertiaryColor);
      expect(theme.colorScheme.surface, kBackgroundColor);
    });

    test('scaffold background uses the soft surface tint', () {
      final theme = AppThemes.light;
      expect(theme.scaffoldBackgroundColor, kBackgroundColor);
    });

    test('textTheme populates every M3 role with the bundled Vazirmatn', () {
      final theme = AppThemes.light;
      final tt = theme.textTheme;
      // Every role must be non-null.
      expect(tt.displayLarge, isNotNull);
      expect(tt.displayMedium, isNotNull);
      expect(tt.displaySmall, isNotNull);
      expect(tt.headlineLarge, isNotNull);
      expect(tt.headlineMedium, isNotNull);
      expect(tt.headlineSmall, isNotNull);
      expect(tt.titleLarge, isNotNull);
      expect(tt.titleMedium, isNotNull);
      expect(tt.titleSmall, isNotNull);
      expect(tt.bodyLarge, isNotNull);
      expect(tt.bodyMedium, isNotNull);
      expect(tt.bodySmall, isNotNull);
      expect(tt.labelLarge, isNotNull);
      expect(tt.labelMedium, isNotNull);
      expect(tt.labelSmall, isNotNull);
      // The whole textTheme is applied with the Vazirmatn family.
      expect(tt.bodyMedium!.fontFamily, 'Vazirmatn');
      expect(tt.titleLarge!.fontFamily, 'Vazirmatn');
      expect(tt.headlineMedium!.fontFamily, 'Vazirmatn');
    });

    test('button themes cover all 4 M3 button families', () {
      final theme = AppThemes.light;
      expect(theme.filledButtonTheme, isNotNull);
      expect(theme.elevatedButtonTheme, isNotNull);
      expect(theme.outlinedButtonTheme, isNotNull);
      expect(theme.textButtonTheme, isNotNull);
    });

    test('input decoration theme is filled with 12dp radius', () {
      final theme = AppThemes.light;
      final inputTheme = theme.inputDecorationTheme;
      expect(inputTheme.filled, isTrue);
      // The factory always sets a non-null OutlineInputBorder.
      // `OutlineInputBorder.borderRadius` is statically typed as
      // `BorderRadiusGeometry`, whose abstract base does not expose
      // `topLeft`. We narrow to the concrete `BorderRadius` so the
      // corner assertions can compile.
      final border = inputTheme.border! as OutlineInputBorder;
      final radius = border.borderRadius as BorderRadius;
      expect(radius.topLeft.x, 12);
      expect(radius.topRight.x, 12);
      expect(radius.bottomLeft.x, 12);
      expect(radius.bottomRight.x, 12);
    });

    test('AppBar uses the bundled height constant', () {
      final theme = AppThemes.light;
      expect(theme.appBarTheme.toolbarHeight, kAppbarHeight);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.centerTitle, isFalse);
    });

    test('checkbox theme wraps in a compact 3dp pill', () {
      final theme = AppThemes.light;
      // Same pattern as the input theme: narrow from
      // `OutlinedBorder?` to `RoundedRectangleBorder`, then to the
      // concrete `BorderRadius` so the corner is reachable.
      final shape = theme.checkboxTheme.shape! as RoundedRectangleBorder;
      final radius = shape.borderRadius as BorderRadius;
      expect(radius.topLeft.x, 3);
    });
  });
}
