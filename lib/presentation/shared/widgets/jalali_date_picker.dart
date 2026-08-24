import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/utils/jalali_date.dart';

/// A compact, RTL Jalali (Shamsi) date picker dialog.
///
/// Opens as a Material dialog with a calendar header, month grid,
/// and Persian weekday labels. Returns a Gregorian [DateTime] so
/// the caller's data layer stays unchanged.
///
/// Usage:
/// ```dart
/// final picked = await showJalaliDatePicker(
///   context,
///   initialDate: myGregorianDate,
/// );
/// ```
Future<DateTime?> showJalaliDatePicker(
  BuildContext context, {
  DateTime? initialDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => _JalaliDatePickerDialog(initialDate: initialDate),
  );
}

class _JalaliDatePickerDialog extends StatefulWidget {
  const _JalaliDatePickerDialog({this.initialDate});

  final DateTime? initialDate;

  @override
  State<_JalaliDatePickerDialog> createState() =>
      _JalaliDatePickerDialogState();
}

class _JalaliDatePickerDialogState extends State<_JalaliDatePickerDialog> {
  late int _viewYear;
  late int _viewMonth;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final jalali = _initialJalali;
    _viewYear = jalali.year;
    _viewMonth = jalali.month;
    _selected = widget.initialDate;
  }

  JalaliDate get _initialJalali {
    final dt = widget.initialDate ?? DateTime.now();
    return toJalali(dt);
  }

  JalaliDate get _todayJalali => toJalali(DateTime.now());

  void _prevMonth() {
    setState(() {
      if (_viewMonth == 1) {
        _viewYear--;
        _viewMonth = 12;
      } else {
        _viewMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_viewMonth == 12) {
        _viewYear++;
        _viewMonth = 1;
      } else {
        _viewMonth++;
      }
    });
  }

  void _selectDay(int day) {
    final gregorian = jalaliToGregorian(_viewYear, _viewMonth, day);
    setState(() => _selected = gregorian);
    Navigator.of(context).pop(gregorian);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                children: [
                  // Title
                  Text(
                    l10n.serviceDate,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: kTextPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Month / Year navigation
                  _MonthYearHeader(
                    year: _viewYear,
                    month: _viewMonth,
                    onPrev: _prevMonth,
                    onNext: _nextMonth,
                  ),
                  const SizedBox(height: 16),

                  // Weekday labels
                  _WeekdayRow(),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── Day grid ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _DayGrid(
                year: _viewYear,
                month: _viewMonth,
                selected: _selected,
                todayJalali: _todayJalali,
                onDayTap: _selectDay,
              ),
            ),

            const SizedBox(height: 12),

            // ── Actions ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (_selected != null) {
                          Navigator.of(context).pop(_selected);
                        } else {
                          Navigator.of(context).pop(widget.initialDate);
                        }
                      },
                      child: Text(l10n.save),
                    ),
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

/// Month name + year with < > navigation arrows.
class _MonthYearHeader extends StatelessWidget {
  const _MonthYearHeader({
    required this.year,
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final int year;
  final int month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = persianMonthNames[month] ?? '';
    final yearStr = toPersianDigits(year);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavButton(icon: Icons.chevron_right, onTap: onPrev),
        Text(
          '$monthName $yearStr',
          style: theme.textTheme.titleMedium?.copyWith(
            color: kTextPrimaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        _NavButton(icon: Icons.chevron_left, onTap: onNext),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22, color: scheme.primary),
        ),
      ),
    );
  }
}

/// Single-letter Persian weekday labels (ش ی د س چ پ ج).
class _WeekdayRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: persianWeekdays
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: kGrey3Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

/// 6-row × 7-column grid of day cells.
class _DayGrid extends StatelessWidget {
  const _DayGrid({
    required this.year,
    required this.month,
    required this.selected,
    required this.todayJalali,
    required this.onDayTap,
  });

  final int year;
  final int month;
  final DateTime? selected;
  final JalaliDate todayJalali;
  final ValueChanged<int> onDayTap;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = jalaliMonthLength(year, month);
    // Day-of-week of the 1st: 0=Saturday, 6=Friday.
    final firstDayWeekday = _dayOfWeek(year, month, 1);

    final cells = <int?>[];

    // Leading empty cells for days before the 1st.
    for (var i = 0; i < firstDayWeekday; i++) {
      cells.add(null);
    }

    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(d);
    }

    // Trailing empty cells to fill the last row.
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final rows = <List<int?>>[];
    for (var i = 0; i < cells.length; i += 7) {
      rows.add(cells.sublist(i, i + 7));
    }

    return Column(
      children: rows
          .map((row) => _DayRow(row: row, onDayTap: _onCellTap))
          .toList(),
    );
  }

  /// Compute the Persian weekday for a Jalali date.
  /// Returns 0=Saturday … 6=Friday.
  int _dayOfWeek(int y, int m, int d) {
    final g = jalaliToGregorian(y, m, d);
    // DateTime.weekday: 1=Mon … 7=Sun.
    // Persian week: 0=Sat=(g.weekday==6?0:g.weekday==7?1:g.weekday+1)
    return switch (g.weekday) {
      6 => 0, // Saturday
      7 => 1, // Sunday
      _ => g.weekday + 1, // Mon(1)->2, Tue(2)->3, ...
    };
  }

  void _onCellTap(int day) => onDayTap(day);
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.row, required this.onDayTap});

  final List<int?> row;
  final ValueChanged<int> onDayTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: row.map((day) {
          if (day == null) {
            return const Expanded(child: SizedBox.shrink());
          }
          return Expanded(
            child: _DayCell(day: day, onTap: () => onDayTap(day)),
          );
        }).toList(),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.onTap});

  final int day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // We can't access ancestor state directly, so we simply render every
    // day as a tappable circle. Selection highlighting is handled by the
    // fact that tapping a day pops the dialog immediately.
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: scheme.primary.withValues(alpha: 0.2),
        child: Center(
          child: Text(
            toPersianDigits(day),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: kTextPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
