import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Data export section with PDF and CSV export buttons.
class DataExportSection extends StatelessWidget {
  const DataExportSection({
    required this.onExportPdf,
    required this.onExportCsv,
    this.isExporting = false,
    super.key,
  });

  final VoidCallback onExportPdf;
  final VoidCallback onExportCsv;
  final bool isExporting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'DATA EXPORT',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSpacing.buttonHeight,
                  child: FilledButton.icon(
                    onPressed: isExporting ? null : onExportPdf,
                    icon: isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.buttonRadius,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: AppSpacing.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: isExporting ? null : onExportCsv,
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Export CSV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.buttonRadius,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
