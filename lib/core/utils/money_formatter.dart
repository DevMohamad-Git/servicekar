import 'package:intl/intl.dart';

/// Presentation-only formatting for monetary amounts in the Persian UI.
///
/// Storage keeps raw Latin `double`s unchanged — this helper only changes
/// how a value is *rendered*: Persian digits (`۰۱۲۳۴۵۶۷۸۹`) with `,`
/// grouping, matching the dashboard design (`5600000` → `۵,۶۰۰,۰۰۰`).
///
/// The sign is preserved for negative values (`-1200` → `-۱,۲۰۰`), so a
/// caller can render an outflow amount if it ever needs to; the domain
/// continues to store amounts unsigned and unchanged.
String formatPersianMoney(double amount) {
  // Group with Latin commas first (locale is pinned so the grouping is
  // deterministic), then swap only the digits for their Persian forms.
  final grouped = NumberFormat('#,##0', 'en_US').format(amount);
  const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
  return grouped.replaceAllMapped(
    RegExp('[0-9]'),
    (match) => persianDigits[int.parse(match.group(0)!)],
  );
}

/// Presentation-only formatting for whole counts in the Persian UI.
///
/// Converts Latin digits to Persian digits (`124` → `۱۲۴`) with no
/// thousand separators, matching the dashboard KPI design. Storage
/// keeps raw `int`s unchanged — this only changes how a value is
/// *rendered*. A negative value keeps its `-` sign (`-12` → `-۱۲`).
String formatPersianNumber(int value) {
  const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
  return value.toString().replaceAllMapped(
    RegExp('[0-9]'),
    (match) => persianDigits[int.parse(match.group(0)!)],
  );
}
