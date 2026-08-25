import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/mock_debtors.dart';

/// Sort options for the debtors list. Default is «بیشترین بدهی».
enum DebtorsSortOrder { highestDebt, lowestDebt }

/// High-level UI phase of the debtors page (loading / data / empty /
/// error). Kept explicit — not an [AsyncValue] — so the selection and
/// sort state below always travels with one coherent snapshot.
enum DebtorsListPhase { loading, data, empty, error }

/// Which mock scenario the page boots into. Flip this constant to
/// review the empty / error states without touching any widget:
/// UI-first simulation only; no Data Layer behind it.
enum DebtorsMockScenario { populated, empty, error }

const DebtorsMockScenario kDebtorsMockScenario = DebtorsMockScenario.populated;

/// Immutable UI state for the debtors-list page.
///
/// Sorting lives here (`sortedDebtors`), never inside widgets, so the
/// order survives selection toggles and recomposes in one place.
class DebtorsListViewState {
  const DebtorsListViewState({
    this.phase = DebtorsListPhase.loading,
    this.debtors = const [],
    this.sortOrder = DebtorsSortOrder.highestDebt,
    this.selectionMode = false,
    this.selectedIds = const {},
  });

  final DebtorsListPhase phase;

  /// Master (unsorted) debtor rows currently held by the page.
  final List<MockDebtor> debtors;

  final DebtorsSortOrder sortOrder;

  /// Whether multi-select mode («ارسال برای چند مشتری») is active.
  final bool selectionMode;

  /// Selected debtor ids while [selectionMode] is active.
  final Set<String> selectedIds;

  bool get isLoading => phase == DebtorsListPhase.loading;
  bool get hasData => phase == DebtorsListPhase.data;

  /// Rows in display order, sorted by the chosen direction.
  List<MockDebtor> get sortedDebtors {
    final rows = [...debtors];
    rows.sort(
      (a, b) => switch (sortOrder) {
        DebtorsSortOrder.highestDebt => b.debtAmount.compareTo(a.debtAmount),
        DebtorsSortOrder.lowestDebt => a.debtAmount.compareTo(b.debtAmount),
      },
    );
    return rows;
  }

  /// True when every visible row is selected (drives «انتخاب همه»).
  bool get allSelected =>
      debtors.isNotEmpty && selectedIds.length == debtors.length;

  DebtorsListViewState copyWith({
    DebtorsListPhase? phase,
    List<MockDebtor>? debtors,
    DebtorsSortOrder? sortOrder,
    bool? selectionMode,
    Set<String>? selectedIds,
  }) {
    return DebtorsListViewState(
      phase: phase ?? this.phase,
      debtors: debtors ?? this.debtors,
      sortOrder: sortOrder ?? this.sortOrder,
      selectionMode: selectionMode ?? this.selectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

/// Controller owning all UI state of the debtors page.
///
/// Deliberately presentation-local (mirrors
/// `service_entry_state.dart`): it reads only the mock list — no Isar,
/// repository or use case — until the Logic/Data phase wires real
/// debtors in.
class DebtorsListController extends Notifier<DebtorsListViewState> {
  static const _mockLatency = Duration(milliseconds: 600);

  @override
  DebtorsListViewState build() {
    // Kick the simulated fetch off after build returns, so the first
    // frame paints the loading state.
    Future.microtask(_load);
    return const DebtorsListViewState();
  }

  /// Simulated fetch → one of the four phases per [kDebtorsMockScenario].
  Future<void> _load() async {
    state = const DebtorsListViewState(phase: DebtorsListPhase.loading);
    await Future<void>.delayed(_mockLatency);

    switch (kDebtorsMockScenario) {
      case DebtorsMockScenario.populated when mockDebtors.isEmpty:
        state = const DebtorsListViewState(phase: DebtorsListPhase.empty);
      case DebtorsMockScenario.populated:
        state = DebtorsListViewState(
          phase: DebtorsListPhase.data,
          debtors: mockDebtors,
        );
      case DebtorsMockScenario.empty:
        state = const DebtorsListViewState(phase: DebtorsListPhase.empty);
      case DebtorsMockScenario.error:
        state = const DebtorsListViewState(phase: DebtorsListPhase.error);
    }
  }

  /// Retry hook for the error state.
  Future<void> retry() => _load();

  void setSortOrder(DebtorsSortOrder order) {
    if (order != state.sortOrder) {
      state = state.copyWith(sortOrder: order);
    }
  }

  void enterSelectionMode() =>
      state = state.copyWith(selectionMode: true, selectedIds: const {});

  void exitSelectionMode() =>
      state = state.copyWith(selectionMode: false, selectedIds: const {});

  void toggleSelected(String id) {
    final next = {...state.selectedIds};
    if (!next.remove(id)) next.add(id);
    state = state.copyWith(selectedIds: next);
  }

  void toggleSelectAll() {
    state = state.copyWith(
      selectedIds: state.allSelected
          ? const {}
          : state.debtors.map((d) => d.id).toSet(),
    );
  }
}

final debtorsListControllerProvider =
    NotifierProvider<DebtorsListController, DebtorsListViewState>(
      DebtorsListController.new,
    );
