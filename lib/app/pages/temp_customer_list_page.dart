import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Temporary stand-in for the customer list. Lives at the app layer
/// (rather than inside `lib/features/customer/...`) so it does not
/// collide with the existing feature-level `CustomerListPage`. The
/// real screen will replace this one in a follow-up.
///
/// Annotated with `@RoutePage()` so the auto_route generator can
/// produce a `TempCustomerListRoute` PageRouteInfo the moment
/// `dart run build_runner build` is runnable again (pub.dev is
/// currently blocked by HTTP 403 in this sandbox). The router wiring
/// itself is intentionally deferred to a separate task — this page
/// only exists as the place a future route will land on.
@RoutePage()
class TempCustomerListPage extends StatelessWidget {
  const TempCustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: const Center(
        child: Text('Customers list — temporary placeholder'),
      ),
    );
  }
}
