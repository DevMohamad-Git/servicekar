import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

part 'router.gr.dart';

/// Application router. Three routes today:
/// - `/`          : landing page (sample).
/// - `/customers` : sample route — will be backed by the customer feature
///                  in a follow-up task. Kept as a placeholder so the
///                  router can be wired and exercised end-to-end.
/// - `/services`  : sample route — placeholder, not yet backed by a
///                  feature module.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: MainRoute.page, path: '/', initial: true),
        AutoRoute(page: CustomersSampleRoute.page, path: '/customers'),
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
class MainPage extends StatelessWidget {
  const MainPage({super.key});

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
