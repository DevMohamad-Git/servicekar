import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/config/l10n/arb/app_localizations.dart';
import 'package:servicar/presentation/debt/models/mock_debtors.dart';
import 'package:servicar/presentation/debt/widgets/debtor_card_widget.dart';

MockDebtor _debtor() => MockDebtor(
      id: 'customer-4',
      fullName: 'حسین یوسفی',
      phoneNumber: '09012345678',
      debtAmount: 5400000,
      lastServiceDate: DateTime(2026, 7, 24),
    );

Widget buildCard(
  MockDebtor debtor, {
  bool selectionMode = false,
  bool isSelected = false,
  VoidCallback? onSendReminder,
  VoidCallback? onToggleSelected,
}) {
  return MaterialApp(
    locale: const Locale('fa'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DebtorCardWidget(
            debtor: debtor,
            selectionMode: selectionMode,
            isSelected: isSelected,
            onSendReminder: onSendReminder ?? () {},
            onToggleSelected: onToggleSelected ?? () {},
          ),
        ],
      ),
    ),
  );
}

void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('normal mode shows identity, amount and the reminder pill', (
    tester,
  ) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(buildCard(_debtor()));

    expect(tester.takeException(), isNull);
    expect(find.text('حسین یوسفی'), findsOneWidget);
    // Grouped phone digits stay visible for quick dial-checks.
    expect(find.text('0901 234 5678'), findsOneWidget);
    // Amount is rendered with an inline quiet toman unit.
    expect(find.textContaining('۵,۴۰۰,۰۰۰', findRichText: true),
        findsOneWidget);
    expect(find.textContaining('تومان', findRichText: true), findsOneWidget);
    // The compact tinted reminder action is present…
    expect(find.text('ارسال پیامک یادآوری'), findsOneWidget);
    // …and selection checkboxes are not.
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('tapping the reminder pill fires onSendReminder', (
    tester,
  ) async {
    usePhoneViewport(tester);

    var sent = false;
    await tester.pumpWidget(
      buildCard(_debtor(), onSendReminder: () => sent = true),
    );

    await tester.tap(find.text('ارسال پیامک یادآوری'));
    expect(sent, isTrue);
  });

  testWidgets('selection mode swaps the pill for a select indicator and '
      'makes the card body toggle selection', (tester) async {
    usePhoneViewport(tester);

    var toggled = false;
    await tester.pumpWidget(
      buildCard(
        _debtor(),
        selectionMode: true,
        onToggleSelected: () => toggled = true,
      ),
    );

    expect(tester.takeException(), isNull);
    // Reminder action is hidden while selecting…
    expect(find.text('ارسال پیامک یادآوری'), findsNothing);
    // …and no Material checkbox is used — the avatar slot carries the
    // selection indicator so narrow rows keep their full width.
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    // Tapping the identity zone toggles the row.
    await tester.tap(find.text('حسین یوسفی'));
    expect(toggled, isTrue);
  });

  testWidgets('selected card morphs the avatar into a checked disc '
      'without overflow', (tester) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(
      buildCard(_debtor(), selectionMode: true, isSelected: true),
    );

    // The white check on the primary disc marks the picked row.
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
