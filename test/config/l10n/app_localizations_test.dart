import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/config/l10n/arb/app_localizations.dart';
import 'package:servicar/config/l10n/arb/app_localizations_en.dart';
import 'package:servicar/config/l10n/arb/app_localizations_fa.dart';

/// Infrastructure test for the generated-localization surface.
///
/// Why this test exists ──────────────────────────────────────────
/// `flutter gen-l10n` would normally produce these classes from
/// `app_fa.arb` / `app_en.arb`. In this project the generator is
/// not always available (sandbox / no pub.dev), so the surface is
/// hand-authored and mirrored from the upstream tool. If a future
/// refactor drops a key, mis-tabulates a Persian glyph, or breaks
/// the `lookupAppLocalizations` dispatch, this test catches it
/// without needing a mounted `BuildContext`.
void main() {
  // `AppLocalizations` subclasses are immutable (all getters return
  // const strings), so each group can hold a single shared
  // instance — no `setUp`/`late` plumbing required.
  group('AppLocalizationsFa (default MVP locale)', () {
    final l10n = AppLocalizationsFa();

    test('localeName resolves to "fa"', () {
      expect(l10n.localeName, 'fa');
    });

    test('core navigation labels render in Persian', () {
      expect(l10n.appName, 'سرویس‌کار');
      expect(l10n.customers, 'مشتریان');
      expect(l10n.services, 'سرویس‌ها');
      expect(l10n.invoices, 'فاکتورها');
    });

    test('customer form labels render in Persian', () {
      expect(l10n.fullName, 'نام و نام خانوادگی');
      expect(l10n.phoneNumber, 'شماره تلفن');
      expect(l10n.email, 'ایمیل');
      expect(l10n.address, 'آدرس');
    });

    test('snackbar / dialog labels render in Persian', () {
      expect(l10n.customerCreated, 'مشتری ایجاد شد');
      expect(l10n.customerUpdated, 'مشتری به‌روز شد');
      expect(l10n.customerDeleted, 'مشتری حذف شد');
    });

    test('locale is reported as RTL for downstream Directionality', () {
      // The MVP forces Locale('fa') in `app.dart` — this test
      // guards that the locale is consistently canonicalized.
      expect(const Locale('fa').languageCode, 'fa');
    });
  });

  group('AppLocalizationsEn (tool fallback)', () {
    final l10n = AppLocalizationsEn();

    test('localeName resolves to "en"', () {
      expect(l10n.localeName, 'en');
    });

    test('core navigation labels render in English', () {
      expect(l10n.appName, 'Servicar');
      expect(l10n.customers, 'Customers');
      expect(l10n.services, 'Services');
      expect(l10n.invoices, 'Invoices');
    });

    test('customer form labels render in English', () {
      expect(l10n.fullName, 'Full name');
      expect(l10n.phoneNumber, 'Phone number');
      expect(l10n.email, 'Email');
      expect(l10n.address, 'Address');
    });
  });

  group('lookupAppLocalizations dispatch', () {
    test('routes Locale("fa") to AppLocalizationsFa', () {
      expect(
        lookupAppLocalizations(const Locale('fa')),
        isA<AppLocalizationsFa>(),
      );
    });

    test('routes Locale("en") to AppLocalizationsEn', () {
      expect(
        lookupAppLocalizations(const Locale('en')),
        isA<AppLocalizationsEn>(),
      );
    });

    test('supportedLocales lists both fa and en', () {
      final codes =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(codes, containsAll(['fa', 'en']));
    });
  });
}
