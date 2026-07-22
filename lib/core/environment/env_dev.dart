import 'env.dart';

/// Dev-environment configuration. Currently flips the customer flow
/// off so the router's `CustomerFlowGuard` redirects `/customers`
/// to `/customers_placeholder`. Production environments should
/// override `disableCustomerFlow` to return `false`.
class EnvDev extends Env {
  EnvDev();

  @override
  bool get disableCustomerFlow => true;
}

/// Process-wide dev environment instance. Held at top-level so the
/// router (and any other consumer) can read flags without injecting
/// through constructors or going through Riverpod yet. Move behind
/// a provider once more than one consumer needs to read it.
final Env appEnv = EnvDev();
