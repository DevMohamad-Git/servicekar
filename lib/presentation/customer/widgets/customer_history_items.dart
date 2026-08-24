import 'package:flutter/material.dart';

import '../../../config/themes/app_themes.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../features/customer/domain/entities/invoice_entity.dart';
import '../../../features/customer/domain/entities/payment_entity.dart';
import '../../../features/customer/domain/entities/service_entity.dart';

// ─── History rows (entity + presentation caption) ─────────────────────
// Each row keeps the domain entity untouched and adds a pre-formatted
// Jalali date caption. The caption is a presentation concern — a real
// Jalali formatter will replace the mock strings when the data layer is
// wired. Service / Invoice / Payment remain independent entities linked
// to the customer only by their `customerUuid` foreign key.

/// Presentation wrapper for one service-history row.
class ServiceHistoryItem {
  const ServiceHistoryItem({required this.service, required this.dateLabel});

  final ServiceEntity service;
  final String dateLabel;
}

/// Presentation wrapper for one invoice-history row.
class InvoiceHistoryItem {
  const InvoiceHistoryItem({required this.invoice, required this.dateLabel});

  final InvoiceEntity invoice;
  final String dateLabel;
}

/// Presentation wrapper for one payment-history row.
class PaymentHistoryItem {
  const PaymentHistoryItem({required this.payment, required this.dateLabel});

  final PaymentEntity payment;
  final String dateLabel;
}

// ─── Service history card ─────────────────────────────────────────────

/// Compact service card from the reference mockup: an image/icon
/// thumbnail on the start side, title + short description + date in the
/// middle, and the amount with a forward chevron on the end side.
class ServiceHistoryCard extends StatelessWidget {
  const ServiceHistoryCard({super.key, required this.item, this.onTap});

  final ServiceHistoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = item.service;

    return _HistoryCardContainer(
      onTap: onTap,
      child: Row(
        children: [
          // Image slot — a tinted service glyph until real photos exist.
          _IconThumbnail(icon: Icons.home_repair_service_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: kTextPrimaryColor,
                  ),
                ),
                if (service.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    service.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                _DateLabel(dateLabel: item.dateLabel),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'مبلغ',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatPersianMoney(service.price),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: kTextPrimaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'تومان',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(width: 2),
          const _Chevron(),
        ],
      ),
    );
  }
}

// ─── Invoice history card ─────────────────────────────────────────────

/// Invoice row: number + date, the total amount and a status chip
/// (پرداخت نشده / پرداخت شده) on the end side, and a forward chevron.
class InvoiceHistoryCard extends StatelessWidget {
  const InvoiceHistoryCard({super.key, required this.item, this.onTap});

  final InvoiceHistoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final invoice = item.invoice;
    final statusColor = _invoiceStatusColor(invoice.status, scheme);

    return _HistoryCardContainer(
      onTap: onTap,
      child: Row(
        children: [
          _IconThumbnail(icon: Icons.receipt_long_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فاکتور ${invoice.invoiceNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: kTextPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                _DateLabel(dateLabel: item.dateLabel),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPersianMoney(invoice.totalAmount),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: kTextPrimaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              _StatusChip(
                label: _invoiceStatusLabel(invoice.status),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(width: 2),
          const _Chevron(),
        ],
      ),
    );
  }
}

// ─── Payment history card ─────────────────────────────────────────────

/// Payment row: amount + method, with the date and a success status chip
/// on the end side.
class PaymentHistoryCard extends StatelessWidget {
  const PaymentHistoryCard({super.key, required this.item, this.onTap});

  final PaymentHistoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final payment = item.payment;

    return _HistoryCardContainer(
      onTap: onTap,
      child: Row(
        children: [
          _IconThumbnail(
            icon: Icons.account_balance_wallet_rounded,
            tint: kSuccessColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatPersianMoney(payment.amount)} تومان',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: kTextPrimaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _paymentMethodLabel(payment.method),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _DateLabel(dateLabel: item.dateLabel),
              const SizedBox(height: 4),
              const _StatusChip(label: 'موفق', color: kSuccessColor),
            ],
          ),
          const SizedBox(width: 2),
          const _Chevron(),
        ],
      ),
    );
  }
}

// ─── Shared card scaffolding ──────────────────────────────────────────

/// White rounded card with a soft shadow — the profile page's standard
/// history-row surface, matching the quick-action tiles (no outline).
class _HistoryCardContainer extends StatelessWidget {
  const _HistoryCardContainer({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(12), child: child),
      ),
    );
  }
}

/// Tinted square thumbnail slot (stands in for the service photo until
/// the data layer ships image paths).
class _IconThumbnail extends StatelessWidget {
  const _IconThumbnail({required this.icon, this.tint});

  final IconData icon;

  /// Accent colour; defaults to the scheme primary.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = tint ?? scheme.primary;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 26, color: color),
    );
  }
}

/// Calendar icon + Jalali date caption — intentionally small and
/// low-contrast so it reads as metadata, never competing with the
/// card's title or description.
class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_month_outlined,
          size: 12,
          color: kGrey3Color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            dateLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: kGrey3Color,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// Small tinted pill used for invoice / payment statuses.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Faint forward chevron at the end edge of a history row.
class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Icon(
      Icons.chevron_left,
      size: 20,
      color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
    );
  }
}

/// Presentation label for one invoice lifecycle state.
String _invoiceStatusLabel(InvoiceStatus status) => switch (status) {
  InvoiceStatus.draft => 'پیش‌نویس',
  InvoiceStatus.issued => 'پرداخت نشده',
  InvoiceStatus.paid => 'پرداخت شده',
  InvoiceStatus.overdue => 'سررسید گذشته',
  InvoiceStatus.cancelled => 'لغو شده',
};

/// Status accent for one invoice lifecycle state.
Color _invoiceStatusColor(InvoiceStatus status, ColorScheme scheme) =>
    switch (status) {
      InvoiceStatus.paid => kSuccessColor,
      InvoiceStatus.issued || InvoiceStatus.overdue => scheme.error,
      _ => kGrey3Color,
    };

/// Presentation label for one payment method.
String _paymentMethodLabel(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => 'نقدی',
  PaymentMethod.card => 'کارت به کارت',
  PaymentMethod.transfer => 'واریز بانکی',
  PaymentMethod.cheque => 'چک',
  PaymentMethod.other => 'سایر',
};