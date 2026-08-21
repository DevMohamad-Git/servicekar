import 'package:flutter/material.dart';

import '../../../config/themes/app_themes.dart';
import '../../../gen/fonts.gen.dart';

/// Customer identity card shown at the top of the profile page.
///
/// Mirrors the reference mockup: a circular avatar placeholder on the
/// start side (right in RTL) with the name beside it, then the phone and
/// address rows stacked underneath. A compact «ویرایش» pencil sits in the
/// top-start corner (left in RTL). Every line stays on a single line and
/// auto-shrinks (via [FittedBox]) instead of wrapping or being clipped when
/// the text is too long for the available width.
///
/// The avatar is a tinted person placeholder — the domain stores only a
/// profile-image *path* ([`CustomerEntity.profileImagePath`]), so a real
/// image loader can plug into the [CircleAvatar.foregroundImage] slot
/// later without touching the layout.
class CustomerInfoCardWidget extends StatelessWidget {
  const CustomerInfoCardWidget({
    super.key,
    required this.fullName,
    required this.phoneNumber,
    this.address,
    required this.onEdit,
  });

  final String fullName;
  final String phoneNumber;
  final String? address;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = scheme.primary;

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar placeholder (start side — right in RTL), a touch larger.
          CircleAvatar(
            radius: 36,
            backgroundColor: accent.withValues(alpha: 0.12),
            child: Icon(Icons.person_rounded, size: 40, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name — beside the avatar, a step smaller than before.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    fullName,
                    maxLines: 1,
                    softWrap: false,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: kTextPrimaryColor,
                      fontWeight: FontWeight.w700,
                      fontFamily: FontFamily.vazirmatn,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Phone — Iran-style 0912 grouping, kept LTR so the digits
                // never reorder under the RTL layout.
                _InfoRow(
                  icon: Icons.phone_outlined,
                  text: _formatPhone(phoneNumber),
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFamily: FontFamily.vazirmatn,
                  ),
                ),
                if (address != null) ...[
                  const SizedBox(height: 10),
                  // Address — a rung smaller than the name font.
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: address!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontFamily: FontFamily.vazirmatn,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Edit action pinned to the top-start corner (left in RTL).
          IconButton(
            tooltip: 'ویرایش',
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 20, color: accent),
          ),
        ],
      ),
    );
  }
}

/// One icon + text row (phone, address) under the customer name. The text
/// is always a single line; when it exceeds the available width the font
/// scales down instead of wrapping or being clipped.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.style,
    this.textDirection,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
              textDirection: textDirection,
              style: style,
            ),
          ),
        ),
      ],
    );
  }
}

/// Groups an 11-digit mobile number for readability: "09121234567" →
/// "0912 123 4567". Longer/shorter numbers are left untouched.
String _formatPhone(String phone) {
  if (phone.length != 11) return phone;
  return '${phone.substring(0, 4)} ${phone.substring(4, 7)} '
      '${phone.substring(7)}';
}
