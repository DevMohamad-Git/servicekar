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

final AppRouter appRouter = AppRouter();
