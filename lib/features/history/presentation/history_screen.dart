import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/history/application/history_export_service.dart';
import 'package:memo_care/features/history/application/history_notifier.dart';
import 'package:memo_care/features/history/domain/models/history_entry.dart';
import 'package:memo_care/features/history/presentation/widgets/compliance_donut_chart.dart';
import 'package:memo_care/features/history/presentation/widgets/day_grouped_log.dart';
import 'package:memo_care/features/history/presentation/widgets/export_pdf_button.dart';
import 'package:memo_care/features/history/presentation/widgets/history_empty_state.dart';
import 'package:memo_care/features/history/presentation/widgets/week_selector_strip.dart';

/// Revamped History & Compliance screen (HIST-01, 10-05).
///
/// Layout: AppBar → WeekSelectorStrip → ComplianceDonutChart →
/// DayGroupedLog list.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late DateTime _weekStart;
  DateTime? _selectedDay;
  bool _isExportingPdf = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Start on Monday of current week
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateTime(_weekStart.year, _weekStart.month, _weekStart.day);
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      _selectedDay = null;
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      _selectedDay = null;
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = day;
    });
  }

  List<HistoryEntry> _visibleHistoryEntries(List<HistoryEntry> allItems) {
    final weekStartLocal = DateTime(
      _weekStart.year,
      _weekStart.month,
      _weekStart.day,
    );
    final weekEndLocal = weekStartLocal.add(const Duration(days: 7));

    final inWeek = allItems.where((entry) {
      final scheduled = entry.scheduledAt.toLocal();
      return !scheduled.isBefore(weekStartLocal) &&
          scheduled.isBefore(weekEndLocal);
    });

    if (_selectedDay == null) {
      return inWeek.toList();
    }

    final selected = _selectedDay!;
    return inWeek.where((entry) {
      final scheduled = entry.scheduledAt.toLocal();
      return scheduled.year == selected.year &&
          scheduled.month == selected.month &&
          scheduled.day == selected.day;
    }).toList();
  }

  Future<void> _exportPdf() async {
    if (_isExportingPdf) return;

    final historyState = ref.read(historyNotifierProvider).asData?.value;
    if (historyState == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('History is still loading. Please try again.'),
        ),
      );
      return;
    }

    final visibleEntries = _visibleHistoryEntries(historyState.items);
    if (visibleEntries.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No history entries in the selected period.'),
        ),
      );
      return;
    }

    setState(() => _isExportingPdf = true);
    try {
      await HistoryExportService.exportPdf(
        entries: visibleEntries,
        weekStart: _weekStart,
        selectedDay: _selectedDay,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF export failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'History',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          ExportPdfButton(
            onPressed: () => unawaited(_exportPdf()),
            isLoading: _isExportingPdf,
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to load history',
                style: AppTypography.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(historyNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (state) {
          final items = _visibleHistoryEntries(state.items);

          // Compute compliance stats from items
          var done = 0;
          var missed = 0;
          var skipped = 0;
          var pending = 0;
          for (final item in items) {
            switch (item.status) {
              case null:
                missed++;
              case _:
                switch (item.status!.name) {
                  case 'done':
                    done++;
                  case 'skipped':
                    skipped++;
                  case 'snoozed':
                    pending++;
                  default:
                    pending++;
                }
            }
          }

          return CustomScrollView(
            slivers: [
              // Week selector
              SliverToBoxAdapter(
                child: WeekSelectorStrip(
                  weekStart: _weekStart,
                  selectedDay: _selectedDay,
                  onDaySelected: _selectDay,
                  onPreviousWeek: _previousWeek,
                  onNextWeek: _nextWeek,
                ),
              ),

              // Compliance donut
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ComplianceDonutChart(
                    done: done,
                    missed: missed,
                    skipped: skipped,
                    pending: pending,
                  ),
                ),
              ),

              // Day-grouped logs or empty state
              if (items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: HistoryEmptyState(),
                )
              else
                DayGroupedLog(entries: items),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
    );
  }
}
