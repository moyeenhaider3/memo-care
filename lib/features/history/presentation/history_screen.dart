import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/history/application/history_notifier.dart';
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
            onPressed: () {
              // TODO: export PDF
            },
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
          // Compute compliance stats from items
          final items = state.items;
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
