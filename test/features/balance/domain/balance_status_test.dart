import 'package:flutter_test/flutter_test.dart';

import 'package:servicar/features/balance/domain/entities/balance_status.dart';

void main() {
  group('BalanceStatus', () {
    test('has three canonical values', () {
      expect(BalanceStatus.values, hasLength(3));
      expect(BalanceStatus.values.toSet(), {
        BalanceStatus.debtor,
        BalanceStatus.settled,
        BalanceStatus.creditor,
      });
    });

    test('labels are reasonable English labels', () {
      expect(BalanceStatus.debtor.label, 'Debtor');
      expect(BalanceStatus.settled.label, 'Settled');
      expect(BalanceStatus.creditor.label, 'Creditor');
    });
  });

  group('BalanceClassifier', () {
    const c = BalanceClassifier();

    test('negative balance → debtor', () {
      expect(c.classify(-1.0), BalanceStatus.debtor);
      expect(c.classify(-100_000.0), BalanceStatus.debtor);
    });

    test('zero balance → settled', () {
      expect(c.classify(0.0), BalanceStatus.settled);
    });

    test('positive balance → creditor', () {
      expect(c.classify(1.0), BalanceStatus.creditor);
      expect(c.classify(500_000.0), BalanceStatus.creditor);
    });

    test('epsilon-absorbed near-zero → settled', () {
      expect(c.classify(BalanceClassifier.epsilon / 2), BalanceStatus.settled);
      expect(c.classify(-BalanceClassifier.epsilon / 2), BalanceStatus.settled);
    });

    test('tiny-but-positive balance → creditor', () {
      expect(c.classify(BalanceClassifier.epsilon * 2), BalanceStatus.creditor);
    });

    test('tiny-but-negative balance → debtor', () {
      expect(c.classify(-BalanceClassifier.epsilon * 2), BalanceStatus.debtor);
    });
  });
}
