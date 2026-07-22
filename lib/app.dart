import 'package:flutter/material.dart';

import 'app/router.dart';

class ServicarApp extends StatelessWidget {
  const ServicarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter.config(),
    );
  }
}

/// Single, reused AppRouter instance. Holding it at top level (rather
/// than re-creating it inside `ServicarApp.build`) keeps the
/// navigation stack stable across rebuilds. When this grows into a
/// Riverpod-driven setup, lift it into an `appRouterProvider`.
final AppRouter appRouter = AppRouter();
