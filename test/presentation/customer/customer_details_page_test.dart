import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:servicar/config/l10n/arb/app_localizations.dart';
import 'package:servicar/presentation/customer/pages/customer_details_page.dart';

void main() {
  Widget buildPage() {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('fa'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: const CustomerDetailsPage(customerId: 'customer-1'),
      ),
    );
  }

  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets(
    'renders header, tabs and service history without overflow',
    (tester) async {
      usePhoneViewport(tester);

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('محمد رضایی'), findsOneWidget);
      expect(find.text('تاریخچه خدمات'), findsOneWidget);
      expect(find.text('تعمیر پکیج دیواری'), findsOneWidget);
      expect(find.text('سرویس‌ها'), findsOneWidget);
      expect(find.text('فاکتورها'), findsOneWidget);
      expect(find.text('پرداخت‌ها'), findsOneWidget);
    },
  );

  testWidgets('switches between history tabs', (tester) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.text('فاکتورها'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('تاریخچه فاکتورها'), findsOneWidget);
    expect(find.textContaining('INV-1405-0042'), findsOneWidget);

    await tester.tap(find.text('پرداخت‌ها'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('تاریخچه پرداخت‌ها'), findsOneWidget);
  });
}
