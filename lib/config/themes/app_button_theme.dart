part of 'app_themes.dart';

/// Shared geometry every button variant in ServiceKar inherits.
/// Kept library-private — the per-variant factories below are the
/// only public surface.
const double _kButtonMinHeight = 48;
const double _kButtonRadius = 12;
const double _kButtonTextFontSize = 16;
const FontWeight _kButtonTextWeight = FontWeight.w600;
const EdgeInsets _kButtonPadding =
    EdgeInsets.symmetric(horizontal: 24, vertical: 12);

/// `filledButtonTheme` factory.
///
/// FilledButton is M3's *primary* call-to-action (e.g. `Create`,
/// `Save`, `Update` in [CreateCustomerPage] / [EditCustomerPage]).
/// Calling [buildFilledButtonTheme] from the [AppThemes.light]
/// mixin wires this into [ThemeData.filledButtonTheme] so every
/// `FilledButton(...)` widget in the app inherits the geometry
/// without per-call-site configuration.
FilledButtonThemeData buildFilledButtonTheme() {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, _kButtonMinHeight),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(_kButtonRadius)),
      ),
      padding: _kButtonPadding,
      textStyle: const TextStyle(
        fontSize: _kButtonTextFontSize,
        fontWeight: _kButtonTextWeight,
      ),
    ),
  );
}

/// `elevatedButtonTheme` factory.
///
/// ElevatedButton is M3's *secondary* call-to-action (e.g. the
/// "Customers" CTA in the home page). Lives in the theme so all
/// `ElevatedButton(...)` calls inherit consistent geometry.
ElevatedButtonThemeData buildElevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(0, _kButtonMinHeight),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(_kButtonRadius)),
      ),
      padding: _kButtonPadding,
      textStyle: const TextStyle(
        fontSize: _kButtonTextFontSize,
        fontWeight: _kButtonTextWeight,
      ),
    ),
  );
}

/// `outlinedButtonTheme` factory.
///
/// OutlinedButton is M3's *tertiary* call-to-action (e.g. the
/// optional "Add customer" empty-state CTA in
/// [EmptyCustomerStateWidget]).
OutlinedButtonThemeData buildOutlinedButtonTheme() {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, _kButtonMinHeight),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(_kButtonRadius)),
      ),
      padding: _kButtonPadding,
      textStyle: const TextStyle(
        fontSize: _kButtonTextFontSize,
        fontWeight: _kButtonTextWeight,
      ),
    ),
  );
}

/// `textButtonTheme` factory.
///
/// TextButton is M3's *low-emphasis* action — used for dialog
/// `Cancel`, inline "Edit this" links, etc. Slightly smaller
/// height than the other variants because TextButton usually
/// sits in inline / dialog contexts where the broader 48dp tap
/// target would dwarf the label. 44dp still beats WCAG 2.5.5's
/// recommended touch target (44×44).
TextButtonThemeData buildTextButtonTheme() {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      minimumSize: const Size(0, 44),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: const TextStyle(
        fontSize: _kButtonTextFontSize,
        fontWeight: _kButtonTextWeight,
      ),
    ),
  );
}
