import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/themes/app_themes.dart';

/// Custom dashboard bottom navigation from the approved design.
///
/// Rendered as a floating, rounded dock inset from the bottom edge, with
/// a soft grey gradient so it reads as a raised, prominent control bar
/// without competing with the page content.
/// Only "ثبت مشتری" is wired to a real screen today; the other tabs show a
/// "coming soon" toast until their features land. The centre FAB opens a
/// quick-action sheet with three actions: ثبت مشتری routes to the customer
/// form, while ثبت پرداختی and ثبت فاکتور show a "coming soon" toast.
///
/// Order (start → end, i.e. right → left in RTL): موارد بیشتر، فاکتورها،
/// FAB، ثبت پرداخت، ثبت مشتری.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key, required this.onComingSoon});

  final VoidCallback onComingSoon;

  void _openQuickActions(BuildContext context) {
    final router = context.router;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _QuickActionSheet(
          onRegisterCustomer: () {
            Navigator.of(sheetContext).pop();
            router.push(const CreateCustomerRoute());
          },
          onRegisterPayment: () {
            Navigator.of(sheetContext).pop();
            onComingSoon();
          },
          onRegisterInvoice: () {
            Navigator.of(sheetContext).pop();
            onComingSoon();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        // Float the dock off the bottom edge (~slightly less than 1 cm) and
        // inset it horizontally so it reads as a rounded, floating bar.
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF1F3F5), kGrey4Color],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kGrey2Color.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.grid_view_outlined,
                      label: context.l10n.moreItems,
                      onTap: onComingSoon,
                    ),
                    _NavItem(
                      icon: Icons.description_outlined,
                      label: context.l10n.invoices,
                      onTap: onComingSoon,
                    ),
                    const SizedBox(width: 64),
                    _NavItem(
                      icon: Icons.credit_card_outlined,
                      label: context.l10n.payments,
                      onTap: onComingSoon,
                    ),
                    _NavItem(
                      icon: Icons.people_outline,
                      label: context.l10n.customers,
                      onTap: () =>
                          context.router.push(const CreateCustomerRoute()),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -26,
                child: FloatingActionButton(
                  heroTag: 'dashboard_quick_action_fab',
                  elevation: 4,
                  backgroundColor: kDebtorsGradientStart,
                  // White ring separates the blue FAB from the blue dock.
                  shape: const CircleBorder(
                    side: BorderSide(color: Colors.white, width: 3),
                  ),
                  onPressed: () => _openQuickActions(context),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kGrey2Color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: kGrey2Color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Content of the dashboard "+" quick-action sheet.
///
/// Pure presentation: it renders three large tappable rows and delegates
/// navigation / toast behavior to the callbacks passed from
/// [HomeBottomNav]. The soft grey gradient sits a touch darker than the
/// page background so the white rows read as distinct surfaces.
class _QuickActionSheet extends StatelessWidget {
  const _QuickActionSheet({
    required this.onRegisterCustomer,
    required this.onRegisterPayment,
    required this.onRegisterInvoice,
  });

  final VoidCallback onRegisterCustomer;
  final VoidCallback onRegisterPayment;
  final VoidCallback onRegisterInvoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF1F3F5), kGrey4Color],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom M3-style drag handle: the default handle is disabled
            // so the gradient owns the whole surface, but the swipe-to-
            // dismiss affordance is preserved.
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kGrey3Color.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  _QuickActionTile(
                    icon: Icons.person_add_alt_1_rounded,
                    accent: kActivityCustomer,
                    accentBackground: kActivityCustomerBackground,
                    label: context.l10n.registerCustomer,
                    onTap: onRegisterCustomer,
                  ),
                  const SizedBox(height: 10),
                  _QuickActionTile(
                    icon: Icons.payments_rounded,
                    accent: kActivityIncome,
                    accentBackground: kActivityIncomeBackground,
                    label: context.l10n.registerPayment,
                    onTap: onRegisterPayment,
                  ),
                  const SizedBox(height: 10),
                  _QuickActionTile(
                    icon: Icons.receipt_long_rounded,
                    accent: kActivityInvoice,
                    accentBackground: kActivityInvoiceBackground,
                    label: context.l10n.registerInvoice,
                    onTap: onRegisterInvoice,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One large, fully-tappable row in the quick-action sheet.
///
/// All three actions share this single visual pattern: a tinted icon chip
/// whose accent colour follows the dashboard's activity semantics
/// (customer = purple, payment = green, invoice = blue), a bold readable
/// label, and a faint trailing chevron. No shadow — the sheet gradient
/// supplies the depth.
class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.accent,
    required this.accentBackground,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final Color accentBackground;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: kTextPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_left,
                size: 22,
                color: kGrey3Color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
