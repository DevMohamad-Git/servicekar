import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../core/environment/env_dev.dart';
import 'pages/temp_customer_list_page.dart';

part 'router.gr.dart';

/// Application router. Routes today:
/// - `/`                     : [HomeRoute] — temporary HomePage
///                             placeholder. Will be replaced by the real
///                             home feature in a follow-up.
/// - `/customers`            : sample route — will be backed by the
///                             customer feature in a follow-up task.
///                             Has an inline redirect guard (built via
///                             [AutoRouteGuard.redirect]): when
///                             [Env.disableCustomerFlow] is `true`,
///                             navigation here is redirected to
///                             `/customers_placeholder`.
/// - `/customers_placeholder`: redirect target — lands on
///                             [TempCustomerListPage].
/// - `/services`             : sample route — placeholder, not yet
///                             backed by a feature module.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, path: '/', initial: true),
        AutoRoute(
          page: CustomersSampleRoute.page,
          path: '/customers',
          guards: [
            // Inline redirect guard scoped to `/customers`. If the env
            // flag flips the customer flow off, the original navigation
            // is aborted and a push to `/customers_placeholder` is issued
            // instead. The placeholder route has no matching guard, so
            // the redirect cannot loop.
            AutoRouteGuard.redirect(
              (_) => appEnv.disableCustomerFlow
                  ? const TempCustomerListRoute()
                  : null,
            ),
          ],
        ),
        AutoRoute(
          page: TempCustomerListRoute.page,
          path: '/customers_placeholder',
        ),
        AutoRoute(page: ServicesSampleRoute.page, path: '/services'),
      ];
}

// ─────────────────────────────────────────────────────────────────────────
// Placeholder pages
//
// Kept inline (single file, no extra files added) so the existing
// `lib/features/customer/...` surface is not touched in this task.
// Each page is annotated with `@RoutePage()` so `auto_route_generator`
// produces the matching `*Route` PageRouteInfo in `router.gr.dart`.
// ─────────────────────────────────────────────────────────────────────────

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Servicar'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  context.router.push(const CustomersSampleRoute()),
              child: const Text('Customers (sample)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  context.router.push(const ServicesSampleRoute()),
              child: const Text('Services (sample)'),
            ),
          ],
        ),
      ),
    );
  }
}

@RoutePage()
class CustomersSamplePage extends StatelessWidget {
  const CustomersSamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: const Center(child: Text('Customers — sample route')),
    );
  }
}

@RoutePage()
class ServicesSamplePage extends StatelessWidget {
  const ServicesSamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: const Center(child: Text('Services — sample route')),
    );
  }
}
