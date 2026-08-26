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

  /// Subtitle under the app name in the dashboard header.
  ///
  /// In fa, this message translates to:
  /// **'مدیریت کسب‌وکار'**
  String get businessManagement;

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

  /// Delete customer action label in the profile overflow menu.
  ///
  /// In fa, this message translates to:
  /// **'حذف مشتری'**
  String get deleteCustomer;

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
  /// **'مشتریان'**
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

  /// Payments list / navigation tab label.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت‌ها'**
  String get payments;

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

  /// Marker shown beside optional customer form fields.
  ///
  /// In fa, this message translates to:
  /// **'اختیاری'**
  String get optional;

  /// Section heading for the customer's primary identity fields.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات اصلی'**
  String get customerMainInfo;

  /// Section heading for required customer fields.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات ضروری'**
  String get customerRequiredInfo;

  /// Section heading for optional customer fields.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات تکمیلی'**
  String get customerAdditionalInfo;

  /// Label for the customer profile photo placeholder.
  ///
  /// In fa, this message translates to:
  /// **'تصویر پروفایل'**
  String get profilePhoto;

  /// Explains that profile photo selection has no current storage flow.
  ///
  /// In fa, this message translates to:
  /// **'افزودن تصویر پروفایل در این نسخه در دسترس نیست'**
  String get profilePhotoUnavailable;

  /// No description provided for @profilePhotoError.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب تصویر پروفایل با خطا مواجه شد'**
  String get profilePhotoError;

  /// No description provided for @addProfilePhoto.
  ///
  /// In fa, this message translates to:
  /// **'افزودن تصویر'**
  String get addProfilePhoto;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In fa, this message translates to:
  /// **'تغییر تصویر'**
  String get changeProfilePhoto;

  /// No description provided for @removeProfilePhoto.
  ///
  /// In fa, this message translates to:
  /// **'حذف تصویر'**
  String get removeProfilePhoto;

  /// No description provided for @camera.
  ///
  /// In fa, this message translates to:
  /// **'دوربین'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In fa, this message translates to:
  /// **'گالری'**
  String get gallery;

  /// Optional customer notes or description field label.
  ///
  /// In fa, this message translates to:
  /// **'یادداشت / توضیحات'**
  String get notes;

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
  /// **'در حال باز کردن مشتریان…'**
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
  /// **'جستجوی مشتریان'**
  String get searchCustomers;

  /// Dashboard greeting prefix, followed by the local user name.
  ///
  /// In fa, this message translates to:
  /// **'سلام،'**
  String get greeting;

  /// Dashboard welcome subtitle under the greeting.
  ///
  /// In fa, this message translates to:
  /// **'خوش آمدید'**
  String get welcome;

  /// Title of the dashboard debtors summary card.
  ///
  /// In fa, this message translates to:
  /// **'مجموع بدهکاران'**
  String get totalDebtors;

  /// Persian currency unit label shown next to amounts.
  ///
  /// In fa, this message translates to:
  /// **'تومان'**
  String get toman;

  /// Button label on the debtors summary card.
  ///
  /// In fa, this message translates to:
  /// **'مشاهده‌ی بدهکاران'**
  String get viewDebtors;

  /// Section header for the dashboard recent activities list.
  ///
  /// In fa, this message translates to:
  /// **'آخرین فعالیت‌ها'**
  String get recentActivities;

  /// Footer link of the recent activities card.
  ///
  /// In fa, this message translates to:
  /// **'مشاهده‌ی همه فعالیت‌ها'**
  String get viewAllActivities;

  /// Subtitle on recent activity rows meaning the action was done by the local user.
  ///
  /// In fa, this message translates to:
  /// **'توسط شما'**
  String get byYou;

  /// Toast shown for features that are not implemented yet.
  ///
  /// In fa, this message translates to:
  /// **'به‌زودی'**
  String get comingSoon;

  /// Section header for the dashboard business-overview KPI cards.
  ///
  /// In fa, this message translates to:
  /// **'نمای کلی کسب‌وکار'**
  String get businessOverview;

  /// KPI card label for the total number of registered invoices.
  ///
  /// In fa, this message translates to:
  /// **'فاکتورهای ثبت‌شده'**
  String get registeredInvoices;

  /// KPI card label for the total number of customers.
  ///
  /// In fa, this message translates to:
  /// **'مشتریان'**
  String get registeredCustomers;

  /// KPI card label for the total number of registered services.
  ///
  /// In fa, this message translates to:
  /// **'سرویس‌های ثبت‌شده'**
  String get registeredServices;

  /// Bottom-nav / quick-action label for registering a customer.
  ///
  /// In fa, this message translates to:
  /// **'ثبت مشتری'**
  String get registerCustomer;

  /// Bottom-nav label for registering a payment.
  ///
  /// In fa, this message translates to:
  /// **'ثبت پرداخت'**
  String get registerPayment;

  /// Quick-action label for registering an invoice.
  ///
  /// In fa, this message translates to:
  /// **'ثبت فاکتور'**
  String get registerInvoice;

  /// Bottom-nav label for the more-items entry point.
  ///
  /// In fa, this message translates to:
  /// **'موارد بیشتر'**
  String get moreItems;

  /// Title of the quick-action bottom sheet opened from the dashboard FAB.
  ///
  /// In fa, this message translates to:
  /// **'اقدام سریع'**
  String get quickActions;

  /// AppBar title of the customer profile (details) page.
  ///
  /// In fa, this message translates to:
  /// **'پروفایل مشتری'**
  String get customerProfile;

  /// Section header for the customer's service history tab.
  ///
  /// In fa, this message translates to:
  /// **'تاریخچه خدمات'**
  String get serviceHistory;

  /// Section header for the customer's invoice history tab.
  ///
  /// In fa, this message translates to:
  /// **'تاریخچه فاکتورها'**
  String get invoiceHistory;

  /// Section header for the customer's payment history tab.
  ///
  /// In fa, this message translates to:
  /// **'تاریخچه پرداخت‌ها'**
  String get paymentHistory;

  /// Link label to open the full history list.
  ///
  /// In fa, this message translates to:
  /// **'مشاهده همه'**
  String get viewAll;

  /// Empty state for the customer's service history tab.
  ///
  /// In fa, this message translates to:
  /// **'سرویسی برای این مشتری ثبت نشده است.'**
  String get emptyServices;

  /// Empty state for the customer's invoice history tab.
  ///
  /// In fa, this message translates to:
  /// **'فاکتوری برای این مشتری ثبت نشده است.'**
  String get emptyInvoices;

  /// Empty state for the customer's payment history tab.
  ///
  /// In fa, this message translates to:
  /// **'پرداختی برای این مشتری ثبت نشده است.'**
  String get emptyPayments;

  /// Quick-action label for registering a service.
  ///
  /// In fa, this message translates to:
  /// **'ثبت سرویس'**
  String get registerService;

  /// Label for the customer mobile-number field on the create form.
  ///
  /// In fa, this message translates to:
  /// **'شماره موبایل'**
  String get mobileNumber;

  /// Placeholder example for the customer full-name field.
  ///
  /// In fa, this message translates to:
  /// **'مثال: محمد رضایی'**
  String get fullNameHint;

  /// Placeholder example for the mobile-number field; Latin digits per app policy.
  ///
  /// In fa, this message translates to:
  /// **'0912 123 4567'**
  String get mobileNumberHint;

  /// Placeholder example for the customer email field.
  ///
  /// In fa, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// Placeholder example for the customer address field.
  ///
  /// In fa, this message translates to:
  /// **'مثال: تهران، خیابان …'**
  String get addressHint;

  /// Placeholder hint for the customer notes field.
  ///
  /// In fa, this message translates to:
  /// **'توضیحاتی درباره این مشتری بنویسید…'**
  String get notesHint;

  /// Validation error for an empty required form field.
  ///
  /// In fa, this message translates to:
  /// **'این فیلد الزامی است'**
  String get requiredField;

  /// Validation error for a malformed mobile number.
  ///
  /// In fa, this message translates to:
  /// **'شماره موبایل معتبر نیست'**
  String get invalidMobileNumber;

  /// Validation error for a malformed email address.
  ///
  /// In fa, this message translates to:
  /// **'ایمیل معتبر نیست'**
  String get invalidEmail;

  /// Primary submit button label on the create-customer form.
  ///
  /// In fa, this message translates to:
  /// **'ایجاد مشتری'**
  String get createCustomer;

  /// Tooltip for the action that fills the create form with sample values.
  ///
  /// In fa, this message translates to:
  /// **'پر کردن نمونه'**
  String get fillSample;

  /// AppBar title of the service-entry page.
  ///
  /// In fa, this message translates to:
  /// **'ثبت سرویس'**
  String get serviceEntry;

  /// Subtitle under the service-entry page title.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات سرویس و هزینه‌های انجام‌شده را ثبت کنید.'**
  String get serviceEntrySubtitle;

  /// Section heading prompting the user to select a customer.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب مشتری'**
  String get selectCustomer;

  /// Action label to change the selected customer.
  ///
  /// In fa, this message translates to:
  /// **'تغییر مشتری'**
  String get changeCustomer;

  /// Search field hint for the customer selection search bar.
  ///
  /// In fa, this message translates to:
  /// **'جستجوی مشتریان…'**
  String get searchCustomerHint;

  /// Label for the service-type dropdown field.
  ///
  /// In fa, this message translates to:
  /// **'نوع سرویس'**
  String get serviceType;

  /// Dropdown option: periodic service.
  ///
  /// In fa, this message translates to:
  /// **'سرویس دوره‌ای'**
  String get serviceTypePeriodic;

  /// Dropdown option: repair.
  ///
  /// In fa, this message translates to:
  /// **'تعمیر'**
  String get serviceTypeRepair;

  /// Dropdown option: installation.
  ///
  /// In fa, this message translates to:
  /// **'نصب'**
  String get serviceTypeInstallation;

  /// Label for the multi-line service-description field.
  ///
  /// In fa, this message translates to:
  /// **'شرح سرویس'**
  String get serviceDescription;

  /// Placeholder for the service-description text field.
  ///
  /// In fa, this message translates to:
  /// **'مثلاً تعویض پمپ و سرویس کامل دستگاه'**
  String get serviceDescriptionHint;

  /// Label for the labour-cost field.
  ///
  /// In fa, this message translates to:
  /// **'هزینه اجرت'**
  String get serviceFee;

  /// Label for the parts-cost field.
  ///
  /// In fa, this message translates to:
  /// **'هزینه قطعات'**
  String get partsFee;

  /// Label for the service-date picker.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ سرویس'**
  String get serviceDate;

  /// Label for the toggle that enables next-service reminder.
  ///
  /// In fa, this message translates to:
  /// **'یادآوری سرویس بعدی'**
  String get nextServiceReminder;

  /// Label for the next-service-date picker field.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ سرویس بعدی'**
  String get nextServiceDate;

  /// Section heading for the service-photos area.
  ///
  /// In fa, this message translates to:
  /// **'عکس‌های سرویس'**
  String get servicePhotos;

  /// Tooltip / accessibility label for the add-service-photo tile.
  ///
  /// In fa, this message translates to:
  /// **'افزودن عکس سرویس'**
  String get addServicePhoto;

  /// Title of the bottom sheet that lets the user pick camera or gallery.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب منبع تصویر'**
  String get choosePhotoSource;

  /// Snackbar message after a successful mock service submission.
  ///
  /// In fa, this message translates to:
  /// **'سرویس با موفقیت ثبت شد'**
  String get serviceSubmitted;

  /// Mock error message shown when service submission fails.
  ///
  /// In fa, this message translates to:
  /// **'ثبت سرویس با خطا مواجه شد'**
  String get serviceSubmitError;

  /// Card header grouping service type and description fields.
  ///
  /// In fa, this message translates to:
  /// **'جزئیات سرویس'**
  String get serviceDetails;

  /// Card header grouping the fee inputs and the total row.
  ///
  /// In fa, this message translates to:
  /// **'هزینه‌های سرویس'**
  String get serviceCosts;

  /// Snackbar shown when picking a service photo fails or permission is denied.
  ///
  /// In fa, this message translates to:
  /// **'دسترسی به دوربین یا گالری ممکن نیست؛ لطفاً مجوزها را بررسی کنید'**
  String get servicePhotoError;

  /// Label for the read-only field showing the sum of service fee and parts fee.
  ///
  /// In fa, this message translates to:
  /// **'مجموع هزینه'**
  String get totalCost;

  /// Empty state shown when customer search returns no results.
  ///
  /// In fa, this message translates to:
  /// **'مشتری‌ای یافت نشد'**
  String get noCustomersFound;

  /// AppBar title of the payment-entry page.
  ///
  /// In fa, this message translates to:
  /// **'ثبت پرداخت'**
  String get paymentEntry;

  /// Subtitle under the payment-entry page title.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات پرداخت دریافت‌شده از مشتری را ثبت کنید.'**
  String get paymentEntrySubtitle;

  /// Card header for the selected customer's account summary.
  ///
  /// In fa, this message translates to:
  /// **'خلاصه وضعیت حساب'**
  String get accountSummary;

  /// Label for the paid-amount field.
  ///
  /// In fa, this message translates to:
  /// **'مبلغ پرداختی'**
  String get paymentAmount;

  /// Label for the payment-method selector.
  ///
  /// In fa, this message translates to:
  /// **'روش پرداخت'**
  String get paymentMethod;

  /// Payment-method option: cash.
  ///
  /// In fa, this message translates to:
  /// **'نقدی'**
  String get paymentMethodCash;

  /// Payment-method option: card-to-card transfer.
  ///
  /// In fa, this message translates to:
  /// **'کارت به کارت'**
  String get paymentMethodCard;

  /// Optional tracking-number field shown for card-to-card payments.
  ///
  /// In fa, this message translates to:
  /// **'شماره پیگیری'**
  String get trackingNumber;

  /// Placeholder example for the tracking-number field; Latin digits per app policy.
  ///
  /// In fa, this message translates to:
  /// **'مثال: 123456789'**
  String get trackingNumberHint;

  /// Label for the payment-date picker.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ پرداخت'**
  String get paymentDate;

  /// Label for the optional multi-line payment-note field.
  ///
  /// In fa, this message translates to:
  /// **'یادداشت پرداخت'**
  String get paymentNote;

  /// Placeholder hint for the payment-note field.
  ///
  /// In fa, this message translates to:
  /// **'توضیحاتی درباره این پرداخت بنویسید…'**
  String get paymentNoteHint;

  /// Snackbar message after a successful mock payment submission.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت با موفقیت ثبت شد'**
  String get paymentSubmitted;

  /// Mock error message shown when payment submission fails.
  ///
  /// In fa, this message translates to:
  /// **'ثبت پرداخت با خطا مواجه شد'**
  String get paymentSubmitError;

  /// Subtitle under the payments-list page title.
  ///
  /// In fa, this message translates to:
  /// **'پرداخت‌های دریافت‌شده از مشتریان را ببینید.'**
  String get paymentsSubtitle;

  /// Filter pill on the payments list: show every payment.
  ///
  /// In fa, this message translates to:
  /// **'همه'**
  String get allPayments;

  /// Caption before the summed received amount on the payments list.
  ///
  /// In fa, this message translates to:
  /// **'مجموع دریافتی‌ها'**
  String get totalReceived;

  /// Caption under the payment count on the payments-list summary card.
  ///
  /// In fa, this message translates to:
  /// **'درون این ماه'**
  String get withinThisMonth;

  /// Caption above the payment count on the payments-list summary card.
  ///
  /// In fa, this message translates to:
  /// **'تعداد پرداخت‌ها'**
  String get numberOfPayments;

  /// AppBar title of the debtors-list page.
  ///
  /// In fa, this message translates to:
  /// **'بدهکاران'**
  String get debtorsTitle;

  /// Intro paragraph under the debtors page title.
  ///
  /// In fa, this message translates to:
  /// **'شما در این صفحه می‌توانید بدهکاران خود را مشاهده و برای آن‌ها پیامک یادآوری ارسال بکنید.'**
  String get debtorsSubtitle;

  /// Sort segment: descending by outstanding amount.
  ///
  /// In fa, this message translates to:
  /// **'بیشترین بدهی'**
  String get sortByHighestDebt;

  /// Sort segment: ascending by outstanding amount.
  ///
  /// In fa, this message translates to:
  /// **'کمترین بدهی'**
  String get sortByLowestDebt;

  /// Per-card action label for sending one reminder SMS.
  ///
  /// In fa, this message translates to:
  /// **'ارسال پیامک یادآوری'**
  String get sendReminderSms;

  /// Bottom CTA that enters multi-select mode.
  ///
  /// In fa, this message translates to:
  /// **'ارسال پیامک یادآوری برای چند مشتری'**
  String get bulkReminderEntry;

  /// Group-send CTA label while rows are selected.
  ///
  /// In fa, this message translates to:
  /// **'ارسال یادآوری ({count})'**
  String sendBulkReminders(String count);

  /// Empty state of the debtors list.
  ///
  /// In fa, this message translates to:
  /// **'در حال حاضر مشتری بدهکاری ندارید.'**
  String get emptyDebtors;

  /// Error state body of the debtors list.
  ///
  /// In fa, this message translates to:
  /// **'دریافت فهرست بدهکاران با خطا مواجه شد.'**
  String get debtorsLoadError;

  /// Master checkbox label selecting every visible debtor.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب همه'**
  String get selectAll;

  /// Master checkbox label clearing the selection.
  ///
  /// In fa, this message translates to:
  /// **'لغو انتخاب همه'**
  String get deselectAll;

  /// Live selection-count pill; count is pre-formatted Persian digits.
  ///
  /// In fa, this message translates to:
  /// **'{count} مورد انتخاب شد'**
  String selectedCount(String count);

  /// Toast confirming a single reminder SMS for the customer.
  ///
  /// In fa, this message translates to:
  /// **'پیامک یادآوری برای {fullName} ارسال شد'**
  String reminderSmsQueued(String fullName);

  /// Toast explaining group SMS is not available yet.
  ///
  /// In fa, this message translates to:
  /// **'این امکان به زودی از طریق سرشماره‌های ارسال پیامک گروهی، در دسترس قرار می‌گیرد. می‌توانید تا آن موقع از امکان ارسال پیامک به صورت تکی استفاده بکنید.'**
  String get bulkSmsUnavailable;

  /// Meta label above a debtor's last service date.
  ///
  /// In fa, this message translates to:
  /// **'آخرین سرویس'**
  String get lastServiceDateLabel;

  /// One-line summary above the list: debtor count plus the total outstanding amount; count and total are pre-formatted Persian digits.
  ///
  /// In fa, this message translates to:
  /// **'{count} بدهکار · مجموع بدهی {total} تومان'**
  String debtorsSummaryLine(String count, String total);
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
