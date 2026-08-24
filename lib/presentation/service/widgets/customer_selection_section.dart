import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../../customer/widgets/customer_card_widget.dart';
import '../logic/service_entry_state.dart';

/// Customer-selection section for the service-entry page.
///
/// Follows the page's modern-minimal grouped-form language:
///   * **not selected** — white card with a rounded-square icon chip,
///     separated search input, and a customer list with hairline
///     dividers and initials avatars (Slack/Linear-style);
///   * **selected** — primary-tinted card with a solid initials avatar
///     and a glass-style "تغییر مشتری" pill action.
///
/// No heavy gradients. Visual hierarchy comes from typography, spacing,
/// and semantic color use.
class CustomerSelectionSection extends StatelessWidget {
  const CustomerSelectionSection({
    super.key,
    required this.selectedCustomer,
    required this.searchQuery,
    required this.searchController,
    required this.onSelectCustomer,
    required this.onChangeCustomer,
    required this.onSearchChanged,
  });

  final MockCustomer? selectedCustomer;
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<MockCustomer> onSelectCustomer;
  final VoidCallback onChangeCustomer;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: selectedCustomer == null
          ? _buildSearchState(context)
          : _buildSelectedState(context),
    );
  }

  // ─── Search (not-selected) state ────────────────────────────

  Widget _buildSearchState(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final filtered = searchQuery.trim().isEmpty
        ? mockCustomers
        : mockCustomers
              .where(
                (c) =>
                    c.name.contains(searchQuery.trim()) ||
                    c.phoneNumber.contains(searchQuery.trim()),
              )
              .toList();

    return Container(
      key: const ValueKey('search'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGrey4Color.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header row ──
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_add_outlined,
                  size: 22,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.selectCustomer,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: kTextPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Search input (separated card) ──
          Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.search,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: kTextPrimaryColor,
              ),
              decoration: InputDecoration(
                hintText: l10n.searchCustomerHint,
                hintStyle: TextStyle(color: kGrey3Color),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: scheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Customer list with hairline dividers ──
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  l10n.noCustomersFound,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            for (final (index, customer) in filtered.indexed) ...[
              if (index > 0)
                Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 8,
                  color: kGrey4Color.withValues(alpha: 0.6),
                ),
              _CustomerRow(
                customer: customer,
                onTap: () => onSelectCustomer(customer),
              ),
            ],
        ],
      ),
    );
  }

  // ─── Selected state ────────────────────────────────────────

  Widget _buildSelectedState(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final customer = selectedCustomer!;

    return Container(
      key: const ValueKey('selected'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Soft primary tint — not a gradient, just a tinted surface.
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // Solid initials avatar with a primary ring.
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CustomerAvatar(
              color: _accentFor(customer.name),
              radius: 19,
            ),
          ),
          const SizedBox(width: 12),

          // Customer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: kTextPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Phone in a white pill — reads as tappable metadata
                // without being a real action yet.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call_rounded, size: 14, color: scheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        customer.phoneNumber,
                        textDirection: TextDirection.ltr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: kGrey2Color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Change-customer pill action.
          TextButton.icon(
            onPressed: onChangeCustomer,
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: Text(l10n.changeCustomer),
            style: TextButton.styleFrom(
              backgroundColor: scheme.primary.withValues(alpha: 0.1),
              foregroundColor: scheme.primary,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: theme.textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Customer row in search list ─────────────────────────────

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.customer, required this.onTap});

  final MockCustomer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              CustomerAvatar(color: _accentFor(customer.name), radius: 19),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: kTextPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                customer.phoneNumber,
                textDirection: TextDirection.ltr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Person avatar ───────────────────────────────────────────

/// Soft accent colors for the avatars. Values mirror the
/// dashboard KPI palette (navy / teal / purple / amber / green) so no
/// new saturated hue enters the app.
const List<Color> _kAvatarAccents = [
  Color(0xFF2563EB),
  Color(0xFF00838F),
  Color(0xFF8B5CF6),
  Color(0xFFD97706),
  Color(0xFF16A34A),
  Color(0xFFDB2777),
];

/// Deterministic accent for a customer name, stable across rebuilds.
Color _accentFor(String name) =>
    _kAvatarAccents[name.trim().hashCode % _kAvatarAccents.length];
