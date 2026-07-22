import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../config/routes/app_router.dart';
import '../core/environment/env.dart';
import '../core/environment/env_dev.dart';
import '../core/utils/app_helper.dart';

/// Global providers — process-wide, never disposed while the app is
/// alive. Mirrors the Lalafen layout (`lib/injection/global_providers.dart`)
/// exactly: every global is long-lived.
///
/// This file uses the *manual* `Provider`/`Provider` API rather than
/// `@Riverpod(keepAlive: true)` because `build_runner` cannot run in
/// this sandbox (no `pub.dev` access). Manual `Provider`s here are
/// effectively `keepAlive` for the app's lifetime because they are
/// instantiated lazily and never auto-disposed by the container
/// until the container itself is torn down — and the container here
/// outlives every page navigation by construction.

/// Active [Env]. Defaults to [EnvDev]; swap for [EnvProd] once a real
/// release environment exists.
final envProvider = Provider<Env>((ref) => EnvDev());

/// [AppHelper] instance injected into every page through Riverpod.
/// Lifetime equals the app's.
final appHelperProvider = Provider<AppHelper>((ref) => AppHelper(ref));

/// Single [AppRouter] bound to the app's lifetime.
final appRouterProvider = Provider<AppRouter>((ref) => AppRouter());
