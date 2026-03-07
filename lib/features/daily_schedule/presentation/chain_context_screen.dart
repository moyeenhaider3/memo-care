import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/features/chain_engine/application/chain_context_providers.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_context.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/status_badge.dart';

/// Chain context detail screen showing upstream/downstream
/// relationships (VIEW-03).
///
/// Displays a vertical timeline:
/// - "Triggered By" section (upstream parents)
/// - "Current" section (highlighted)
/// - "Triggers Next" section (downstream children)
///
/// Each chain node is tappable to navigate to its own
/// chain context.
class ChainContextScreen extends ConsumerWidget {
  const ChainContextScreen({
    required this.reminderId,
    super.key,
  });

  final int reminderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(chainContextProvider(reminderId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
        title: Text(
          'Chain Context',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: contextAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load chain context.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(
                    chainContextProvider(reminderId),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (chainCtx) => _ChainContextBody(
          chainCtx: chainCtx,
          currentReminderId: reminderId,
        ),
      ),
    );
  }
}

class _ChainContextBody extends StatelessWidget {
  const _ChainContextBody({
    required this.chainCtx,
    required this.currentReminderId,
  });

  final ChainContext chainCtx;
  final int currentReminderId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chain name
          Text(
            chainCtx.chainName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),

          // ── UPSTREAM ──
          _sectionHeader(theme, 'TRIGGERED BY'),
          const SizedBox(height: 8),

          if (chainCtx.upstreamReminders.isEmpty)
            _emptyHint(
              theme,
              'This is the first step in the chain',
            )
          else
            ...chainCtx.upstreamReminders.map(
              (r) => _ChainNode(
                reminder: r,
                isCurrent: false,
                showConnector: true,
              ),
            ),

          // ── Connector ──
          if (chainCtx.upstreamReminders.isNotEmpty) const _Connector(),

          // ── CURRENT ──
          _sectionHeader(
            theme,
            'CURRENT',
            isPrimary: true,
          ),
          const SizedBox(height: 8),
          _ChainNode(
            reminder: chainCtx.currentReminder,
            isCurrent: true,
            showConnector: false,
          ),

          // ── Connector ──
          if (chainCtx.downstreamReminders.isNotEmpty) const _Connector(),

          // ── DOWNSTREAM ──
          _sectionHeader(theme, 'TRIGGERS NEXT'),
          const SizedBox(height: 8),

          if (chainCtx.downstreamReminders.isEmpty)
            _emptyHint(
              theme,
              'This is the last step in the chain',
            )
          else
            ...chainCtx.downstreamReminders.map(
              (r) => _ChainNode(
                reminder: r,
                isCurrent: false,
                showConnector: false,
              ),
            ),

          const SizedBox(height: 32),

          // Footer info
          Center(
            child: Text(
              'Part of ${chainCtx.chainName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    ThemeData theme,
    String label, {
    bool isPrimary = false,
  }) {
    return Semantics(
      header: true,
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _emptyHint(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

/// A single node in the chain visualization.
class _ChainNode extends StatelessWidget {
  const _ChainNode({
    required this.reminder,
    required this.isCurrent,
    required this.showConnector,
  });

  final Reminder reminder;
  final bool isCurrent;
  final bool showConnector;

  bool get _isMissed {
    final scheduledAt = reminder.scheduledAt;
    if (scheduledAt == null) return false;
    return scheduledAt.isBefore(DateTime.now().toUtc());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat.jm();
    final timeText = reminder.scheduledAt != null
        ? timeFormat.format(reminder.scheduledAt!.toLocal())
        : '--:--';

    final semanticsLabel =
        '${isCurrent ? "Current" : "Chain"} reminder: '
        '${reminder.medicineName}, '
        '${reminder.dosage ?? ""}, '
        'at $timeText';

    return Semantics(
      label: semanticsLabel,
      button: !isCurrent,
      child: GestureDetector(
        onTap: isCurrent
            ? null
            : () => unawaited(
                context.push(
                  '/reminder/${reminder.id}/chain',
                ),
              ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
            color: isCurrent
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: isCurrent
                ? Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Node indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: 12),

              // Medicine info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.medicineName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isCurrent
                            ? theme.colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    Text(
                      [
                        if (reminder.dosage != null) reminder.dosage!,
                        timeText,
                      ].join(' · '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isCurrent
                            ? theme.colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.8,
                              )
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              StatusBadge(
                status: null,
                isMissed: _isMissed,
              ),

              // Navigate arrow for non-current nodes
              if (!isCurrent) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Vertical connector line between chain nodes.
class _Connector extends StatelessWidget {
  const _Connector();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 21),
      child: Column(
        children: [
          Container(
            width: 2,
            height: 24,
            color: theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
          Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: theme.colorScheme.outline.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
