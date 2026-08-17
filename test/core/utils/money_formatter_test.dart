import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/core/utils/money_formatter.dart';

void main() {
  group('formatPersianMoney', () {
    test('renders Persian digits with comma grouping', () {
      expect(formatPersianMoney(5600000), '۵,۶۰۰,۰۰۰');
      expect(formatPersianMoney(3200000), '۳,۲۰۰,۰۰۰');
      expect(formatPersianMoney(1234), '۱,۲۳۴');
      expect(formatPersianMoney(999), '۹۹۹');
    });

    test('renders zero', () {
      expect(formatPersianMoney(0), '۰');
    });

    test('preserves the sign for negative values', () {
      expect(formatPersianMoney(-1200), '-۱,۲۰۰');
    });
  });

  group('formatPersianNumber', () {
    test('converts single digits to Persian', () {
      expect(formatPersianNumber(0), '۰');
      expect(formatPersianNumber(5), '۵');
    });

    test('converts multi-digit counts without separators', () {
      expect(formatPersianNumber(124), '۱۲۴');
      expect(formatPersianNumber(1000000), '۱۰۰۰۰۰۰');
    });

    test('preserves the sign for negative values', () {
      expect(formatPersianNumber(-12), '-۱۲');
    });
  });
}
