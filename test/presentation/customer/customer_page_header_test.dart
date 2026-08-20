import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/config/themes/app_themes.dart';
import 'package:servicar/presentation/customer/widgets/customer_page_header.dart';

void main() {
  // Wraps the header in an RTL scaffold (the app's real locale is Persian),
  // with a plain body so only the header participates in layout.
  Widget rtlScaffold(PreferredSizeWidget header) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(appBar: header, body: const SizedBox()),
  );

  Widget wrap(PreferredSizeWidget header) =>
      MaterialApp(theme: AppThemes.light, home: rtlScaffold(header));

  testWidgets(
    'places the back arrow on the left and the actions on the right',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          CustomerPageHeader(
            title: 'عنوان',
            onBack: () {},
            actions: [
              const SizedBox(key: ValueKey('action'), width: 60, height: 48),
            ],
          ),
        ),
      );

      final screenWidth = tester.getSize(find.byType(Scaffold)).width;
      final backCenter = tester.getCenter(find.byTooltip('بازگشت')).dx;
      final actionCenter = tester
          .getCenter(find.byKey(const ValueKey('action')))
          .dx;

      expect(backCenter, lessThan(screenWidth / 2));
      expect(actionCenter, greaterThan(screenWidth / 2));
    },
  );

  testWidgets('keeps the title centered when there are no actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(CustomerPageHeader(title: 'عنوان', onBack: () {})),
    );

    final screenWidth = tester.getSize(find.byType(Scaffold)).width;
    final titleCenter = tester.getCenter(find.text('عنوان')).dx;

    expect((titleCenter - screenWidth / 2).abs(), lessThan(1.0));
  });

  testWidgets(
    'consumes the status-bar inset but leaves the bottom inset to the body',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemes.light,
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(top: 24, bottom: 48),
            ),
            child: rtlScaffold(
              CustomerPageHeader(title: 'عنوان', onBack: () {}),
            ),
          ),
        ),
      );

      // The header grows to cover the status bar so the white surface runs
      // edge to edge; the navigation-bar inset is NOT added, so the height
      // is exactly the top inset plus the toolbar height.
      final headerSize = tester.getSize(find.byType(CustomerPageHeader));
      expect(headerSize.height, 24 + kAppbarHeight);

      // Content sits below the status-bar inset.
      final backCenter = tester.getCenter(find.byTooltip('بازگشت')).dy;
      expect(backCenter, greaterThan(24));
    },
  );
}
