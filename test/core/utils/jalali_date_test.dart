import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/jalali_date.dart';

void main() {
  group('toJalali', () {
    // (Gregorian, expected Jalali year/month/day)
    final cases = <(DateTime, int, int, int)>[
      // Nowruz — 1 Farvardin of each year.
      (DateTime.utc(2026, 3, 21), 1405, 1, 1),
      (DateTime.utc(2025, 3, 21), 1404, 1, 1),
      (DateTime.utc(2024, 3, 20), 1403, 1, 1), // leap Jalali year (1403)
      // Dates across the Gregorian year.
      (DateTime.utc(2026, 1, 1), 1404, 10, 11), // 11 Dey 1404
      (DateTime.utc(2026, 8, 21), 1405, 5, 30), // 30 Mordad 1405
      (DateTime.utc(2026, 12, 31), 1405, 10, 10), // 10 Dey 1405
      (DateTime.utc(2025, 12, 21), 1404, 9, 30), // 30 Azar 1404
      // Older date to cover the 4-year block / leap handling.
      (DateTime.utc(2000, 1, 1), 1378, 10, 11), // 11 Dey 1378
    ];

    for (final (gregorian, expectedYear, expectedMonth, expectedDay) in cases) {
      test('converts ${gregorian.toIso8601String()} correctly', () {
        final jalali = toJalali(gregorian);
        expect(jalali.year, expectedYear);
        expect(jalali.month, expectedMonth);
        expect(jalali.day, expectedDay);
      });
    }

    test('never throws for the current date', () {
      expect(() => toJalali(DateTime.now()), returnsNormally);
    });
  });

  group('JalaliDate.format', () {
    test('renders the Persian month name with Persian digits', () {
      final jalali = toJalali(DateTime.utc(2026, 8, 21)); // 30 Mordad 1405
      expect(jalali.format(), '۳۰ مرداد ۱۴۰۵');
    });
  });

  group('JalaliDate.formatNumeric', () {
    test('renders a zero-padded numeric date', () {
      final jalali = toJalali(DateTime.utc(2026, 8, 21));
      expect(jalali.formatNumeric(), '۱۴۰۵/۰۵/۳۰');
    });

    test('does not over-pad two-digit months and days', () {
      final jalali = toJalali(DateTime.utc(2026, 12, 31)); // 10 Dey 1405
      expect(jalali.formatNumeric(), '۱۴۰۵/۱۰/۱۰');
    });
  });
}
