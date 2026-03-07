import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/history/application/history_notifier.dart';
import 'package:memo_care/features/history/presentation/widgets/history_card.dart';
import 'package:memo_care/features/history/presentation/widgets/medication_filter_bar.dart';

/// Paginated medication history screen
/// (HIST-01, HIST-02, HIST-03).
///
/// Uses infinite scroll with [ScrollController] to load pages
/// of 20 entries. [MedicationFilterBar] at top for filtering
/// by medicine name. [RefreshIndicator] for pull-to-refresh.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      unawaited(
        ref.read(historyNotifierProvider.notifier).loadNextPage(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medication History',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load history.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(
                    historyNotifierProvider,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (state) => Column(
          children: [
            // Filter bar
            if (state.availableFilters.isNotEmpty)
              MedicationFilterBar(
                availableFilters: state.availableFilters,
                activeFilter: state.activeFilter,
                onFilterChanged: (filter) {
                  unawaited(
                    ref
                        .read(
                          historyNotifierProvider.notifier,
                        )
                        .setFilter(filter),
                  );
                },
              ),

            // History list
            Expanded(
              child: state.items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(
                                    alpha: 0.4,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.activeFilter != null
                                  ? 'No history for '
                                        '"${state.activeFilter}"'
                                  : 'No medication '
                                        'history yet',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(
                            historyNotifierProvider.notifier,
                          )
                          .refresh(),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 80,
                        ),
                        itemCount:
                            state.items.length + (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.items.length) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return HistoryCard(
                            entry: state.items[index],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
