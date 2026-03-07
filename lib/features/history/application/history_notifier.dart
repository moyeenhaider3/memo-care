import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/history/domain/models/history_entry.dart';
import 'package:memo_care/features/reminders/application/providers.dart';

/// Paginated history state (HIST-01, HIST-02, HIST-03).
class HistoryState {
  /// Creates a [HistoryState].
  const HistoryState({
    required this.items,
    required this.hasMore,
    required this.currentPage,
    required this.availableFilters,
    this.activeFilter,
    this.isLoadingMore = false,
  });

  /// Currently loaded history entries.
  final List<HistoryEntry> items;

  /// Whether more pages are available.
  final bool hasMore;

  /// Current page index (0-based).
  final int currentPage;

  /// Active medication name filter (null = all).
  final String? activeFilter;

  /// Available medication names for the filter dropdown.
  final List<String> availableFilters;

  /// Whether a page load is in progress.
  final bool isLoadingMore;

  /// Creates a copy with the given overrides.
  HistoryState copyWith({
    List<HistoryEntry>? items,
    bool? hasMore,
    int? currentPage,
    String? activeFilter,
    bool clearFilter = false,
    List<String>? availableFilters,
    bool? isLoadingMore,
  }) {
    return HistoryState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
      availableFilters: availableFilters ?? this.availableFilters,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Manages paginated medication history with optional
/// filter (HIST-02, HIST-03).
///
/// Page size is 20 to avoid loading 1000+ rows
/// (PITFALLS.md — Drift query in UI thread).
/// [loadNextPage] appends results; [setFilter] resets and
/// reloads.
class HistoryNotifier extends AsyncNotifier<HistoryState> {
  static const _pageSize = 20;

  @override
  Future<HistoryState> build() async {
    final repo = ref.watch(reminderRepositoryProvider);

    // Load available filter options.
    final filters = await repo.getDistinctMedicineNames();

    // Load first page.
    final rows = await repo.getHistoryPage(
      limit: _pageSize,
      offset: 0,
    );
    final items = rows.map(HistoryEntry.fromQueryRow).toList();

    return HistoryState(
      items: items,
      hasMore: items.length >= _pageSize,
      currentPage: 0,
      availableFilters: filters,
    );
  }

  /// Loads the next page of history entries.
  ///
  /// No-op if already loading or no more pages available.
  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true),
    );

    final repo = ref.read(reminderRepositoryProvider);
    final nextPage = current.currentPage + 1;
    final offset = nextPage * _pageSize;

    final rows = await repo.getHistoryPage(
      limit: _pageSize,
      offset: offset,
      medicineNameFilter: current.activeFilter,
    );
    final newItems = rows.map(HistoryEntry.fromQueryRow).toList();

    state = AsyncData(
      current.copyWith(
        items: [...current.items, ...newItems],
        hasMore: newItems.length >= _pageSize,
        currentPage: nextPage,
        isLoadingMore: false,
      ),
    );
  }

  /// Sets the medication name filter and reloads from page 0.
  ///
  /// Pass null to clear the filter.
  Future<void> setFilter(String? medicineFilter) async {
    state = const AsyncLoading();

    final repo = ref.read(reminderRepositoryProvider);
    final rows = await repo.getHistoryPage(
      limit: _pageSize,
      offset: 0,
      medicineNameFilter: medicineFilter,
    );
    final items = rows.map(HistoryEntry.fromQueryRow).toList();

    final filters = await repo.getDistinctMedicineNames();

    state = AsyncData(
      HistoryState(
        items: items,
        hasMore: items.length >= _pageSize,
        currentPage: 0,
        activeFilter: medicineFilter,
        availableFilters: filters,
      ),
    );
  }

  /// Refreshes from page 0 with current filter.
  Future<void> refresh() async {
    final currentFilter = state.value?.activeFilter;
    await setFilter(currentFilter);
  }
}

/// Provider for [HistoryNotifier].
final historyNotifierProvider =
    AsyncNotifierProvider<HistoryNotifier, HistoryState>(
      HistoryNotifier.new,
    );
