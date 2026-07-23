import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
  ];

  /// Application name (AppBar title, splash, install metadata).
  ///
  /// In fa, this message translates to:
  /// **'سرویس‌کار'**
  String get appName;

  /// Submit button label for forms (Save in Edit pages).
  ///
  /// In fa, this message translates to:
  /// **'ذخیره'**
  String get save;

  /// Cancel button on dialogs and edit pages.
  ///
  /// In fa, this message translates to:
  /// **'لغو'**
  String get cancel;

  /// Delete action label / dialog button.
  ///
  /// In fa, this message translates to:
  /// **'حذف'**
  String get delete;

  /// Edit action label / AppBar tooltip.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش'**
  String get edit;

  /// Generic add verb.
  ///
  /// In fa, this message translates to:
  /// **'افزودن'**
  String get add;

  /// Generic search verb (hint placeholder).
  ///
  /// In fa, this message translates to:
  /// **'جستجو'**
  String get search;

  /// Customer-list page title and navigation tab.
  ///
  /// In fa, this message translates to:
  /// **'مشتری‌ها'**
  String get customers;

  /// Service-list page title and navigation tab.
  ///
  /// In fa, this message translates to:
  /// **'سرویس‌ها'**
  String get services;

  /// Invoice-list page title and navigation tab.
  ///
  /// In fa, this message translates to:
  /// **'فاکتورها'**
  String get invoices;

  /// Settings page title (reserved — not yet implemented in MVP).
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get settings;

  /// Generic error label for snackbar and dialog title.
  ///
  /// In fa, this message translates to:
  /// **'خطا'**
  String get error;

  /// Retry button label on failed async states.
  ///
  /// In fa, this message translates to:
  /// **'تلاش دوباره'**
  String get retry;

  /// Default empty-state placeholder body text.
  ///
  /// In fa, this message translates to:
  /// **'موردی برای نمایش نیست'**
  String get emptyState;

  /// Refresh action label (IconButton tooltip on list pages).
  ///
  /// In fa, this message translates to:
  /// **'تازه‌سازی'**
  String get refresh;

  /// Add customer action label (FAB tooltip, empty-state CTA).
  ///
  /// In fa, this message translates to:
  /// **'افزودن مشتری'**
  String get addCustomer;

  /// Customer form label for the full-name field.
  ///
  /// In fa, this message translates to:
  /// **'نام و نام خانوادگی'**
  String get fullName;

  /// Customer form label for the phone-number field.
  ///
  /// In fa, this message translates to:
  /// **'شماره تلفن'**
  String get phoneNumber;

  /// Customer form label for the email field.
  ///
  /// In fa, this message translates to:
  /// **'ایمیل'**
  String get email;

  /// Customer form label for the postal-address field.
  ///
  /// In fa, this message translates to:
  /// **'آدرس'**
  String get address;

  /// Form validator error message for empty mandatory fields.
  ///
  /// In fa, this message translates to:
  /// **'الزامی'**
  String get required;

  /// AppBar title of the new-customer page.
  ///
  /// In fa, this message translates to:
  /// **'مشتری جدید'**
  String get newCustomer;

  /// AppBar title of the edit-customer page.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش مشتری'**
  String get editCustomer;

  /// AppBar title of the customer-details page.
  ///
  /// In fa, this message translates to:
  /// **'جزئیات مشتری'**
  String get customerDetails;

  /// Confirmation dialog title for delete-customer action.
  ///
  /// In fa, this message translates to:
  /// **'حذف مشتری؟'**
  String get deleteCustomerDialogTitle;

  /// Confirmation dialog body explaining irreversibility.
  ///
  /// In fa, this message translates to:
  /// **'این عمل قابل بازگشت نیست.'**
  String get deleteCustomerDialogBody;

  /// Snackbar message after a successful customer creation.
  ///
  /// In fa, this message translates to:
  /// **'مشتری ایجاد شد'**
  String get customerCreated;

  /// Snackbar message after a successful customer update.
  ///
  /// In fa, this message translates to:
  /// **'مشتری به‌روز شد'**
  String get customerUpdated;

  /// Snackbar message after a successful customer deletion.
  ///
  /// In fa, this message translates to:
  /// **'مشتری حذف شد'**
  String get customerDeleted;

  /// Snackbar message on the home page before navigating to the customer list.
  ///
  /// In fa, this message translates to:
  /// **'در حال باز کردن مشتری‌ها…'**
  String get openingCustomers;

  /// Create button label (new-customer form submit).
  ///
  /// In fa, this message translates to:
  /// **'ایجاد'**
  String get create;

  /// Title of the empty customer-list state.
  ///
  /// In fa, this message translates to:
  /// **'هنوز مشتری ندارید'**
  String get emptyCustomersTitle;

  /// Body of the empty customer-list state — explains how to start.
  ///
  /// In fa, this message translates to:
  /// **'برای شروع ردگیری تاریخچه‌ی سرویس، اولین مشتری خود را ایجاد کنید.'**
  String get emptyCustomersBody;

  /// Customer-search bar hint text.
  ///
  /// In fa, this message translates to:
  /// **'جستجوی مشتری‌ها'**
  String get searchCustomers;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
