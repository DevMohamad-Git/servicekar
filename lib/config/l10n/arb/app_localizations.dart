import 'package:flutter/widgets.dart';

/// Stub `AppLocalizations` placeholder. Replace with the file produced
/// by `flutter gen-l10n` once ARB strings are added under
/// `lib/config/l10n/arb/`. Kept here today so the barrel
/// `lib/config/l10n/l10n.dart` compiles and the placeholder import in
/// the migration result does not blow up the analyzer.
///
/// Mirrors the shape `flutter_localizations` produces; never call
/// these keys — they are placeholders.
class AppLocalizations {
  const AppLocalizations();

  static const AppLocalizationsDelegate delegate = AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
  ];

  /// Look up the closest supported locale from the device's preferred
  /// locales. Without any ARB entries this falls back to English.
  static Locale resolve(Locale? locale, Iterable<Locale> supported) {
    final s = supported.isEmpty ? const [Locale('en')] : supported;
    if (locale == null) return s.first;
    return s.firstWhere(
      (l) => l.languageCode == locale.languageCode,
      orElse: () => s.first,
    );
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      const AppLocalizations();

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
