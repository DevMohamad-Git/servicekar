import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../presentation/customer/pages/create_customer_page.dart';
import '../../presentation/customer/pages/customer_details_page.dart';
import '../../presentation/customer/pages/customer_list_page.dart';
import '../../presentation/customer/pages/edit_customer_page.dart';
import '../../presentation/debt/pages/debtors_list_page.dart';
import '../../presentation/home/pages/home_page.dart';
import '../../presentation/payment/pages/payments_list_page.dart';
import '../../presentation/payment/pages/payment_entry_page.dart';
import '../../presentation/customer/pages/create_customer_submit.dart';
import '../../presentation/customer/services/profile_image_picker.dart';
import '../../presentation/service/pages/service_entry_page.dart';
import '../../presentation/service/services/service_photo_picker.dart';

part 'app_router.gr.dart';

/// Application router. Replaces the inline `lib/app/router.dart` so
/// the router lives next to the rest of the configuration under
/// `lib/config/routes/` (Lalafen's layout).
///
/// All [Page] widgets are imported from `lib/presentation/<feature>/`
/// per Lalafen's layout. The gen companion (`app_router.gr.dart`) is
/// hand-authored: pub.dev is unreachable in this sandbox, so
/// `dart run build_runner build` cannot run. The companion mirrors
/// `auto_route_generator` 10.5.0 output for `auto_route: 11.1.0`.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, path: '/', initial: true),
    AutoRoute(page: CustomerListRoute.page, path: '/customers'),
    AutoRoute(page: CustomerDetailsRoute.page, path: '/customers/:customerId'),
    AutoRoute(page: CreateCustomerRoute.page, path: '/customers/new'),
    AutoRoute(
      page: EditCustomerRoute.page,
      path: '/customers/:customerId/edit',
    ),
    AutoRoute(page: ServiceEntryRoute.page, path: '/services/new'),
    AutoRoute(page: PaymentsListRoute.page, path: '/payments'),
    AutoRoute(page: PaymentEntryRoute.page, path: '/payments/new'),
    AutoRoute(page: DebtorsListRoute.page, path: '/debtors'),
  ];
}
