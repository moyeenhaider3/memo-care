import 'package:flutter/material.dart';

/// Horizontal filter bar for medication history (HIST-03).
///
/// Shows [FilterChip] options for each available medication name
/// plus an "All" option. Tapping a chip calls [onFilterChanged]
/// with the medicine name (or null for All).
///
/// Accessibility: chips have >= 48 dp touch target, Semantics.
class MedicationFilterBar extends StatelessWidget {
  const MedicationFilterBar({
    required this.availableFilters,
    required this.activeFilter,
    required this.onFilterChanged,
    super.key,
  });

  /// List of medication names available for filtering.
  final List<String> availableFilters;

  /// Currently selected filter (null = show all).
  final String? activeFilter;

  /// Called when the user selects a filter chip.
  final ValueChanged<String?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              label: 'Filter: Show all medications',
              selected: activeFilter == null,
              child: FilterChip(
                label: const Text(
                  'All',
                  style: TextStyle(fontSize: 16),
                ),
                selected: activeFilter == null,
                onSelected: (_) =>
                    onFilterChanged(null),
                selectedColor:
                    theme.colorScheme.primaryContainer,
                materialTapTargetSize:
                    MaterialTapTargetSize.padded,
              ),
            ),
          ),

          // Per-medicine chips
          ...availableFilters.map(
            (name) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Semantics(
                label: 'Filter: Show only $name',
                selected: activeFilter == name,
                child: FilterChip(
                  label: Text(
                    name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  selected: activeFilter == name,
                  onSelected: (_) => onFilterChanged(
                    activeFilter == name ? null : name,
                  ),
                  selectedColor:
                      theme.colorScheme.primaryContainer,
                  materialTapTargetSize:
                      MaterialTapTargetSize.padded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
