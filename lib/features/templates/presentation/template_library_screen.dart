import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/templates/application/template_providers.dart';
import 'package:memo_care/features/templates/domain/models/template_packs.dart';
import 'package:memo_care/features/templates/presentation/widgets/category_filter_chips.dart';
import 'package:memo_care/features/templates/presentation/widgets/template_card.dart';
import 'package:memo_care/features/templates/presentation/widgets/template_detail_sheet.dart';
import 'package:memo_care/features/templates/presentation/widgets/template_search_bar.dart';

/// Standalone browsable template library screen (10-06).
///
/// AppBar → SearchBar → CategoryFilterChips → 2-column grid.
class TemplateLibraryScreen extends ConsumerStatefulWidget {
  const TemplateLibraryScreen({super.key});

  @override
  ConsumerState<TemplateLibraryScreen> createState() =>
      _TemplateLibraryScreenState();
}

class _TemplateLibraryScreenState extends ConsumerState<TemplateLibraryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const _categories = [
    'All',
    'Diabetes',
    'Blood Pressure',
    'Heart',
    'Hydration',
    'Wellness',
    'Eye Care',
    'School',
  ];

  @override
  Widget build(BuildContext context) {
    const allPacks = kTemplatePacks;

    // Filter by category
    final categoryFiltered = _selectedCategory == 'All'
        ? allPacks
        : allPacks.where((p) {
            final cond = p.condition.toLowerCase().replaceAll('_', ' ');
            return cond.contains(_selectedCategory.toLowerCase());
          }).toList();

    // Filter by search
    final filtered = _searchQuery.isEmpty
        ? categoryFiltered
        : categoryFiltered
              .where(
                (p) =>
                    p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Templates',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          TemplateSearchBar(
            onChanged: (q) => setState(() => _searchQuery = q),
          ),
          const SizedBox(height: 8),
          CategoryFilterChips(
            categories: _categories,
            selected: _selectedCategory,
            onSelected: (c) => setState(() => _selectedCategory = c),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No templates found',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.cardGap,
                          crossAxisSpacing: AppSpacing.cardGap,
                          childAspectRatio: 1.3,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final pack = filtered[index];
                      return TemplateCard(
                        pack: pack,
                        onTap: () => TemplateDetailSheet.show(
                          context,
                          pack: pack,
                          onApply: () async {
                            final service = ref.read(
                              templateServiceProvider,
                            );
                            final result = await service.apply(pack: pack);
                            result.fold(
                              (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed: ${error.message}',
                                      ),
                                    ),
                                  );
                                }
                              },
                              (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${pack.name} applied!',
                                      ),
                                    ),
                                  );
                                  context.go('/home');
                                }
                              },
                            );
                          },
                          onCustomize: () {
                            // TODO: navigate to customization
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
