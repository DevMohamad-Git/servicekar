import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/jalali_date.dart';

/// Focused regression tests for the ±1 day error around Gregorian
/// century boundaries (1900, 2100) plus exhaustive round-trip checks
/// for the conversion and its inverse.
void main() {
  group('century-boundary conversions', () {
    final cases = <(DateTime, int, int, int)>[
      // Around 1899 / 1900 — 1900 is a non-leap century year.
      (DateTime.utc(1899, 3, 21), 1278, 1, 1), // Nowruz 1278
      (DateTime.utc(1900, 2, 28), 1278, 12, 9), // 9 Esfand 1278
      (DateTime.utc(1900, 3, 1), 1278, 12, 10), // 10 Esfand 1278
      (DateTime.utc(1900, 3, 21), 1279, 1, 1), // Nowruz 1279
      // Around 1999 / 2000 — 2000 is a leap year divisible by 400.
      (DateTime.utc(1999, 3, 21), 1378, 1, 1), // Nowruz 1378
      (DateTime.utc(1999, 12, 31), 1378, 10, 10), // 10 Dey 1378
      (DateTime.utc(2000, 1, 1), 1378, 10, 11), // 11 Dey 1378
      (DateTime.utc(2000, 2, 29), 1378, 12, 10), // 10 Esfand 1378
      (DateTime.utc(2000, 3, 20), 1379, 1, 1), // Nowruz 1379 (leap Jalali)
      // Around 2099 / 2100 — 2100 is a non-leap century year.
      (DateTime.utc(2099, 12, 31), 1478, 10, 11), // 11 Dey 1478
      (DateTime.utc(2100, 1, 1), 1478, 10, 12), // 12 Dey 1478
      (DateTime.utc(2100, 2, 28), 1478, 12, 10), // 10 Esfand 1478
      (DateTime.utc(2100, 3, 1), 1478, 12, 11), // 11 Esfand 1478
      (DateTime.utc(2100, 3, 21), 1479, 1, 1), // Nowruz 1479
    ];

    for (final (gregorian, year, month, day) in cases) {
      test('${gregorian.toIso8601String()} → $year/$month/$day', () {
        final j = toJalali(gregorian);
        expect((j.year, j.month, j.day), (year, month, day));
        // The inverse must land back on the same Gregorian day.
        expect(jalaliToGregorian(year, month, day), gregorian);
      });
    }
  });

  group('Gregorian → Jalali → Gregorian round trip', () {
    test('is exact across century boundaries and the practical range', () {
      var start = DateTime.utc(1898, 1, 1);
      final end = DateTime.utc(2102, 12, 31);

      while (!start.isAfter(end)) {
        final j = toJalali(start);
        final back = jalaliToGregorian(j.year, j.month, j.day);
        expect(
          back,
          start,
          reason:
              'round trip failed for ${start.toIso8601String()} '
              '(Jalali ${j.year}/${j.month}/${j.day})',
        );
        start = start.add(const Duration(days: 1));
      }
    });
  });

  group('Jalali → Gregorian → Jalali round trip', () {
    test('is exact for every valid Jalali date in the practical range', () {
      for (var year = 1278; year <= 1578; year++) {
        for (var month = 1; month <= 12; month++) {
          final len = jalaliMonthLength(year, month);
          for (var day = 1; day <= len; day++) {
            final g = jalaliToGregorian(year, month, day);
            final j = toJalali(g);
            expect(
              (j.year, j.month, j.day),
              (year, month, day),
              reason:
                  'round trip failed for Jalali $year/$month/$day '
                  '(Gregorian ${g.toIso8601String()})',
            );
          }
        }
      }
    });
  });

  group('Jalali leap-year boundaries', () {
    // Position within the 33-year cycle: leap years are 0, 4, 8, ... 28
    // (position 32 is not a leap year).
    test('1399 is a leap year (30 Esfand)', () {
      expect(isJalaliLeapYear(1399), isTrue);
      expect(jalaliMonthLength(1399, 12), 30);
    });

    test('1403 is a leap year (30 Esfand)', () {
      expect(isJalaliLeapYear(1403), isTrue);
      expect(jalaliMonthLength(1403, 12), 30);
    });

    test('1404 is not a leap year (29 Esfand)', () {
      expect(isJalaliLeapYear(1404), isFalse);
      expect(jalaliMonthLength(1404, 12), 29);
    });

    test('round trip is exact across a Jalali leap boundary', () {
      // 29 Esfand 1403 → 30 Esfand 1403 → 1 Farvardin 1404.
      final g1 = jalaliToGregorian(1403, 12, 29);
      final g2 = jalaliToGregorian(1403, 12, 30);
      final g3 = jalaliToGregorian(1404, 1, 1);
      expect(g2.difference(g1).inDays, 1);
      expect(g3.difference(g2).inDays, 1);
      expect(
        (toJalali(g1).year, toJalali(g1).month, toJalali(g1).day),
        (1403, 12, 29),
      );
      expect(
        (toJalali(g2).year, toJalali(g2).month, toJalali(g2).day),
        (1403, 12, 30),
      );
      expect(
        (toJalali(g3).year, toJalali(g3).month, toJalali(g3).day),
        (1404, 1, 1),
      );
    });
  });

  group('Nowruz boundaries', () {
    test('Nowruz is the exact inverse across year transitions', () {
      // Cover Nowruz transitions for leap and non-leap Jalali years
      // spanning three Gregorian centuries.
      final nowruz = <(int, DateTime)>[
        (1278, DateTime.utc(1899, 3, 21)),
        (1279, DateTime.utc(1900, 3, 21)),
        (1378, DateTime.utc(1999, 3, 21)),
        (1379, DateTime.utc(2000, 3, 20)),
        (1478, DateTime.utc(2099, 3, 20)),
        (1479, DateTime.utc(2100, 3, 21)),
      ];
      for (final (year, gregorian) in nowruz) {
        final j = toJalali(gregorian);
        expect((j.year, j.month, j.day), (year, 1, 1));
        expect(jalaliToGregorian(year, 1, 1), gregorian);
      }
    });
  });
}
