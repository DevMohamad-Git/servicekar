import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:servicar/presentation/debt/logic/debtors_list_controller.dart';
import 'package:servicar/presentation/debt/models/mock_debtors.dart';

void main() {
  group('DebtorsListViewState (pure state logic)', () {
    final rows = List<MockDebtor>.generate(3, (i) {
      // Deliberately unsorted amounts: 200, 300, 100.
      final amount = switch (i) { 0 => 200.0, 1 => 300.0, _ => 100.0 };
      return MockDebtor(
        id: 'c$i',
        fullName: 'مشتری $i',
        phoneNumber: '0912000000$i',
        debtAmount: amount,
        lastServiceDate: DateTime(2026, 1, 1),
      );
    });

    test('highestDebt sorts descending', () {
      final state = DebtorsListViewState(debtors: rows);
      expect(
        state.sortedDebtors.map((d) => d.id).toList(),
        ['c1', 'c0', 'c2'],
      );
    });

    test('lowestDebt sorts ascending', () {
      final state = DebtorsListViewState(
        debtors: rows,
        sortOrder: DebtorsSortOrder.lowestDebt,
      );
      expect(
        state.sortedDebtors.map((d) => d.id).toList(),
        ['c2', 'c0', 'c1'],
      );
    });

    test('allSelected is false for empty and partial selections', () {
      expect(const DebtorsListViewState().allSelected, isFalse);
      final partial = DebtorsListViewState(
        debtors: rows,
        selectedIds: const {'c0'},
      );
      expect(partial.allSelected, isFalse);
    });
  });

  group('DebtorsListController', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    /// Waits out the controller's simulated mock latency so the state
    /// settles into its data phase.
    Future<DebtorsListViewState> loadedState() async {
      var state = container.read(debtorsListControllerProvider);
      final deadline = DateTime.now().add(const Duration(seconds: 3));
      while (!state.hasData && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        state = container.read(debtorsListControllerProvider);
      }
      return state;
    }

    test('boots into loading then lands on the populated data phase',
        () async {
      expect(
        container.read(debtorsListControllerProvider).phase,
        DebtorsListPhase.loading,
      );
      final state = await loadedState();
      expect(state.phase, DebtorsListPhase.data);
      expect(state.debtors.length, mockDebtors.length);
    });

    test('toggleSelected adds and removes ids', () async {
      await loadedState();
      final notifier = container.read(debtorsListControllerProvider.notifier);

      notifier.toggleSelected(mockDebtors.first.id);
      expect(
        container.read(debtorsListControllerProvider).selectedIds,
        {mockDebtors.first.id},
      );

      notifier.toggleSelected(mockDebtors.first.id);
      expect(
        container.read(debtorsListControllerProvider).selectedIds,
        isEmpty,
      );
    });

    test('select all then deselect all round-trips', () async {
      await loadedState();
      final notifier = container.read(debtorsListControllerProvider.notifier);

      notifier.toggleSelectAll();
      var state = container.read(debtorsListControllerProvider);
      expect(state.allSelected, isTrue);
      expect(state.selectedIds.length, state.debtors.length);

      notifier.toggleSelectAll();
      state = container.read(debtorsListControllerProvider);
      expect(state.selectedIds, isEmpty);
    });

    test('exiting selection mode clears the selection', () async {
      await loadedState();
      final notifier = container.read(debtorsListControllerProvider.notifier);

      notifier.enterSelectionMode();
      notifier.toggleSelected(mockDebtors.first.id);
      notifier.exitSelectionMode();

      final state = container.read(debtorsListControllerProvider);
      expect(state.selectionMode, isFalse);
      expect(state.selectedIds, isEmpty);
    });

    test('setSortOrder flips the direction and re-sorts', () async {
      await loadedState();
      final notifier = container.read(debtorsListControllerProvider.notifier);

      notifier.setSortOrder(DebtorsSortOrder.lowestDebt);
      final state = container.read(debtorsListControllerProvider);
      expect(state.sortOrder, DebtorsSortOrder.lowestDebt);

      final amounts = state.sortedDebtors.map((d) => d.debtAmount).toList();
      expect(amounts, equals([...amounts]..sort()));
    });
  });
}
