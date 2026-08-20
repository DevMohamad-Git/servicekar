/// Cross-cutting constants used across multiple features. Mirrors
/// `lalafen/lib/core/constants/general_constants.dart`. The body is
/// intentionally minimal today; add values here as soon as two or more
/// features start sharing them, **not** before.
class GeneralConstants {
  const GeneralConstants._();

  /// Animation duration used by helper dialogs / sheets when they
  /// don't otherwise override it. Matches Lalafen.
  static const Duration kDefaultModalAnimationDuration =
      Duration(milliseconds: 300);

  /// Key used by `MaterialApp.router` for restoration scope.
  /// Mirrors Lalafen's literal but made discoverable.
  static const String kRestorationScopeId = 'servicar-root';

  /// Hero tag shared by the dashboard's centre "+" FAB and the customer
  /// list's corner "+" FAB so the two morph into one another (flying in an
  /// arc) while navigating between those pages.
  static const String kAddFabHeroTag = 'add-fab';
}
