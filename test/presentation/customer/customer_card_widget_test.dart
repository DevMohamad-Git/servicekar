import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/presentation/customer/widgets/customer_card_widget.dart';

void main() {
  Widget buildCard(CustomerCardData customer, {VoidCallback? onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [CustomerCardWidget(customer: customer, onTap: onTap)],
        ),
      ),
    );
  }

  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('debtor card shows name, phone and plain status word', (
    tester,
  ) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(
      buildCard(
        const CustomerCardData(
          id: 'customer-1',
          name: 'علی رضایی',
          phoneNumber: '09121234567',
          status: CustomerCardStatus.debtor,
          balance: 2500000,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('علی رضایی'), findsOneWidget);
    expect(find.text('0912 123 4567'), findsOneWidget);
    expect(find.text('بدهکار'), findsOneWidget);
    // No tag, icon, or amount — just the plain word.
    expect(find.textContaining('تومان'), findsNothing);
    expect(find.textContaining('۲,۵۰۰,۰۰۰'), findsNothing);
  });

  testWidgets('creditor and settled cards show their plain status words', (
    tester,
  ) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(
      buildCard(
        const CustomerCardData(
          id: 'customer-4',
          name: 'حسین یوسفی',
          phoneNumber: '09012345678',
          status: CustomerCardStatus.creditor,
          balance: 350000,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('بستانکار'), findsOneWidget);
    expect(find.textContaining('تومان'), findsNothing);
  });

  testWidgets('settled card shows تسویه without any amount', (tester) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(
      buildCard(
        const CustomerCardData(
          id: 'customer-2',
          name: 'محمد احمدی',
          phoneNumber: '09359876543',
          status: CustomerCardStatus.settled,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('تسویه'), findsOneWidget);
    expect(find.textContaining('تومان'), findsNothing);
  });

  testWidgets('long names truncate without overflowing the card', (
    tester,
  ) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(
      buildCard(
        const CustomerCardData(
          id: 'customer-5',
          name: 'شرکت پیمانکاری ساختمانی آریا پارس',
          phoneNumber: '09301112233',
          status: CustomerCardStatus.debtor,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('شرکت پیمانکاری ساختمانی آریا پارس'), findsOneWidget);
  });

  testWidgets('tapping the card fires onTap', (tester) async {
    usePhoneViewport(tester);

    var tapped = false;
    await tester.pumpWidget(
      buildCard(
        const CustomerCardData(
          id: 'customer-1',
          name: 'علی رضایی',
          phoneNumber: '09121234567',
          status: CustomerCardStatus.debtor,
        ),
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.text('علی رضایی'));
    expect(tapped, isTrue);
  });
}
