import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:servicar/config/l10n/arb/app_localizations.dart';
import 'package:servicar/presentation/customer/pages/create_customer_page.dart';
import 'package:servicar/presentation/customer/pages/create_customer_submit.dart';
import 'package:servicar/presentation/customer/services/profile_image_picker.dart';

class _DelayedSubmit implements CreateCustomerSubmit {
  const _DelayedSubmit({this.delay = const Duration(milliseconds: 1)});

  final Duration delay;

  @override
  Future<String?> call(CreateCustomerDraft draft) async {
    await Future<void>.delayed(delay);
    return null;
  }
}

void main() {
  Widget buildPage({
    CreateCustomerDraft? initialDraft,
    CreateCustomerSubmit? submit,
    ProfileImagePicker? profileImagePicker,
  }) {
    return ProviderScope(
      overrides: [
        if (submit != null)
          createCustomerSubmitProvider.overrideWithValue(submit),
      ],
      child: MaterialApp(
        locale: const Locale('fa'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: CreateCustomerPage(
          initialDraft: initialDraft,
          profileImagePicker: profileImagePicker,
        ),
      ),
    );
  }

  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  FilledButton submitButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byType(FilledButton));

  testWidgets('renders the empty form with a disabled submit', (tester) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('مشتری جدید'), findsOneWidget);
    expect(find.text('اطلاعات اصلی'), findsOneWidget);
    expect(find.text('نام و نام خانوادگی'), findsOneWidget);
    expect(find.text('شماره موبایل'), findsOneWidget);
    expect(find.text('ایمیل'), findsOneWidget);
    expect(find.text('آدرس'), findsOneWidget);
    expect(find.text('یادداشت / توضیحات'), findsOneWidget);

    // Required fields start empty, so the primary CTA is disabled.
    expect(submitButton(tester).onPressed, isNull);
  });

  testWidgets('stays scrollable and overflow-free on a small viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Off-screen fields are still built inside the scroll view.
    expect(find.text('یادداشت / توضیحات'), findsOneWidget);
  });

  testWidgets(
    'shows an inline error and keeps submit disabled for a bad phone',
    (tester) async {
      usePhoneViewport(tester);

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'علی رضایی');
      await tester.enterText(find.byType(TextFormField).at(1), '12345');
      await tester.pumpAndSettle();

      expect(find.text('شماره موبایل معتبر نیست'), findsOneWidget);
      expect(submitButton(tester).onPressed, isNull);
    },
  );

  testWidgets('valid submit shows loading then success and resets the form', (
    tester,
  ) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(
      buildPage(
        submit: const _DelayedSubmit(delay: Duration(seconds: 1)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'علی رضایی');
    await tester.enterText(find.byType(TextFormField).at(1), '09121234567');
    await tester.pumpAndSettle();

    expect(submitButton(tester).onPressed, isNotNull);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    // In-flight: spinner replaces the label and the button is disabled.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(submitButton(tester).onPressed, isNull);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('مشتری ایجاد شد'), findsOneWidget);
    // The form resets back to the empty state.
    expect(find.text('علی رضایی'), findsNothing);
    expect(submitButton(tester).onPressed, isNull);
  });

  testWidgets('selects, cancels, and removes a profile image', (tester) async {
    usePhoneViewport(tester);

    XFile? nextImage = XFile('/cache/profile.jpg');
    ImageSource? lastSource;
    final picker = ProfileImagePicker(
      pickImage: (source) async {
        lastSource = source;
        return nextImage;
      },
    );

    await tester.pumpWidget(buildPage(profileImagePicker: picker));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('create-customer-profile-avatar')));
    await tester.pumpAndSettle();
    expect(find.text('دوربین'), findsOneWidget);
    expect(find.text('گالری'), findsOneWidget);
    expect(find.text('حذف تصویر'), findsNothing);

    await tester.tap(find.text('دوربین'));
    await tester.pump();
    expect(lastSource, ImageSource.camera);
    expect(
      find.byKey(const ValueKey('create-customer-profile-preview')),
      findsOneWidget,
    );

    // A cancelled replacement leaves the previously selected preview intact.
    nextImage = null;
    await tester.tap(find.byKey(const ValueKey('create-customer-profile-avatar')));
    await tester.pumpAndSettle();
    expect(find.text('حذف تصویر'), findsOneWidget);
    await tester.tap(find.text('گالری'));
    await tester.pump();
    expect(lastSource, ImageSource.gallery);
    expect(
      find.byKey(const ValueKey('create-customer-profile-preview')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('create-customer-profile-avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف تصویر'));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('create-customer-profile-preview')),
      findsNothing,
    );
    expect(find.text('افزودن تصویر'), findsOneWidget);
  });
}
