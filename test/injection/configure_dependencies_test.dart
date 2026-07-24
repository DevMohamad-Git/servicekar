import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:servicar/config/routes/app_router.dart';
import 'package:servicar/core/environment/env.dart';
import 'package:servicar/core/environment/env_dev.dart';
import 'package:servicar/core/utils/app_helper.dart';
import 'package:servicar/injection/injection.dart';

// `injection.dart` re-exports `global_providers.dart`, so the four
// long-lived providers (`envProvider`, `appHelperProvider`,
// `appRouterProvider`, `isarInstanceProvider`) reach this test
// through a single import.

void main() {
  group('configureDependencies (DI bootstrap)', () {
    test('returns a non-null ProviderContainer', () async {
      final container = await configureDependencies();
      addTearDown(container.dispose);
      expect(container, isA<ProviderContainer>());
    });

    test('eagerly exposes env / appHelper / appRouter', () async {
      // The production bootstrap reads these three globals BEFORE
      // returning so any misbehaving constructor surfaces in `main()`
      // rather than at first frame. Tests confirm the eager-read value.
      final container = await configureDependencies();
      addTearDown(container.dispose);
      expect(container.read(envProvider), isA<Env>());
      expect(container.read(appHelperProvider), isA<AppHelper>());
      expect(container.read(appRouterProvider), isA<AppRouter>());
      // Singleton check: a second read returns the same instance,
      // because Provider caches its factory result.
      expect(
        identical(container.read(appHelperProvider), container.read(appHelperProvider)),
        isTrue,
      );
    });

    test('default env is the dev environment', () async {
      final container = await configureDependencies();
      addTearDown(container.dispose);
      expect(container.read(envProvider), isA<EnvDev>());
    });

    test(
      'isarInstanceProvider throws while no @collection ships',
      () async {
        // The Isar infrastructure task deliberately left the
        // override list empty. Reading the provider today must
        // surface the missing-open() signal loud and clear.
        // Riverpod wraps the factory's StateError inside its
        // own error type, so the matcher is permissive (`throws`)
        // but we still assert on the message to confirm the
        // failure actually came from our factory.
        final container = await configureDependencies();
        addTearDown(container.dispose);
        expect(
          () => container.read(isarInstanceProvider),
          throwsA(
            predicate(
              (Object e) => e.toString().contains('isarInstanceProvider'),
              'an error mentioning isarInstanceProvider',
            ),
          ),
        );
      },
    );

    test('ProviderContainer overrides pattern is accepted by Riverpod', () {
      // Tests are expected to override a single provider, not
      // re-bootstrap the whole graph. This guards that the
      // override API still works after wiring changes. Riverpod
      // infers the override list type from the parameter, so we
      // simply pass an empty list literal here.
      final container = ProviderContainer(overrides: const []);
      addTearDown(container.dispose);
      // Reading an overridden-but-empty provider falls back to the
      // production default (EnvDev at the moment).
      expect(container.read(envProvider), isA<EnvDev>());
    });
  });
}
