import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/routes/app_router.dart';
import '../../../injection/global_providers.dart';

/// Live-persistent home page placeholder.
///
/// Inherits the live Router from `appRouterProvider` so the button
/// push works even after the user has been to other screens.
/// Navigates to the real Customer flow once tapped.
@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servicar')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Servicar'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(appHelperProvider).displayToast(
                      context,
                      message: 'Opening customers…',
                    );
                context.router.push(const CustomerListRoute());
              },
              child: const Text('Customers'),
            ),
          ],
        ),
      ),
    );
  }
}
