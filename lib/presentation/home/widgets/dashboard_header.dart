import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';

/// Dashboard header: a profile avatar on the start side (right in RTL),
/// the app name with a subtitle centered between it and the notification
/// bell on the end side (left in RTL).
///
/// The MVP deliberately ships no user profile and no server auth, so the
/// avatar and the bell are decorative placeholders with no action.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile icon — replaces the former greeting text and sits at
        // the start (right) in RTL.
        const _Avatar(),
        // App name + subtitle, centered between the two icons.
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: kTextPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.businessManagement,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: kGrey3Color),
              ),
            ],
          ),
        ),
        const _Bell(),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 22,
      backgroundColor: kActivityInvoiceBackground,
      child: Icon(Icons.person_outline, color: kActivityInvoice, size: 18),
    );
  }
}

class _Bell extends StatelessWidget {
  const _Bell();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.notifications_none, color: kGrey2Color, size: 26),
        Positioned(
          top: -2,
          right: -1,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: kActivityInvoice,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
