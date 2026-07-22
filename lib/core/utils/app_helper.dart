import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'util_extensions.dart';

/// App-wide helper for UI plumbing: toasts, bottom sheets, dialogs,
/// keyboard management, and human-readable formatting.
///
/// This is the Servicar-flavored port of
/// `lalafen/lib/core/utils/app_helper.dart`:
///   * The Toastification dependency is intentionally **dropped** —
///     Servicar uses Flutter's built-in `ScaffoldMessenger` so the
///     surface stays dependency-free.
///   * `launchAndroidIntent` is **dropped** — Servicar does not yet
///     need to talk to platform intents. Re-add with an adapter when
///     the use case actually appears.
///   * Every other method (displayBottomSheet, displayDialog,
///     displayAdaptiveModal, closeSoftKeyboard, humanReadableDuration)
///     keeps the Lalafen contract verbatim.
///
/// Instantiated once via `appHelperProvider` in
/// `lib/injection/global_providers.dart` and consumed through Riverpod.
class AppHelper {
  AppHelper(this.ref);

  final Ref ref;

  /// Show a short message at the bottom of the screen via the platform
  /// [ScaffoldMessenger]. Replaces Lalafen's Toastification toast to
  /// keep the dependency surface minimal.
  void displayToast(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 4, overflow: TextOverflow.ellipsis),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Open a modal bottom sheet. Mirrors Lalafen's signature 1:1 so the
  /// future migration of `displayAdaptiveModal` is mechanical.
  FutureOr<void> displayBottomSheet(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isRounded = false,
    bool isFullScreen = false,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: isRounded
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            )
          : const Border(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      elevation: 10,
      showDragHandle: false,
      useSafeArea: true,
      constraints: BoxConstraints(
        minWidth: double.infinity,
        minHeight: isFullScreen ? context.deviceHeightFactor(0.95) : 0.0,
        maxHeight: isFullScreen
            ? context.deviceHeightFactor(0.95)
            : double.infinity,
      ),
      builder: (_) => child,
    );
  }

  /// Open a generic, centered dialog. Same signature as Lalafen minus
  /// the dashed-border wrapper (drop, since Servicar has no
  /// `DashedBottomSheetContainer` yet).
  Future<T?> displayDialog<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(type: MaterialType.transparency, child: child),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.slowMiddle;
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
          reverseCurve: curve,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(scale: curvedAnimation, child: child),
        );
      },
    );
  }

  /// Show a bottom sheet on phones, a centered dialog on tablets/desktops.
  /// Keeps the Lalafen contract — Servicar does not yet use the
  /// responsive_framework breakpoint, so this branches on the shortest
  /// side using a sensible 600 px cutoff.
  void displayAdaptiveModal(
    BuildContext context, {
    required Widget child,
    bool isDismissible = false,
    bool enableDrag = false,
    bool isRounded = true,
    bool isFullScreen = false,
  }) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final isCompact = shortestSide < 600;
    if (isCompact) {
      displayBottomSheet(
        context,
        child: child,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        isRounded: isRounded,
        isFullScreen: isFullScreen,
      );
    } else {
      displayDialog<void>(context, child: child, isDismissible: isDismissible);
    }
  }

  /// Format a [Duration] as `HH:MM:SS`. Same as Lalafen without the
  /// Persian digit conversion (Servicar has no Persian locale yet).
  String humanReadableDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  /// Dismiss the soft keyboard if one is currently open.
  void closeSoftKeyboard(BuildContext context) {
    context.focusScope.unfocus();
  }
}
