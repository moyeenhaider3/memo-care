import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/ramadan_theme.dart';
import 'package:memo_care/features/fasting/application/fasting_notifier.dart';
import 'package:memo_care/features/fasting/domain/fasting_models.dart';
import 'package:memo_care/features/fasting/presentation/widgets/fasting_progress_bar.dart';
import 'package:memo_care/features/fasting/presentation/widgets/medicine_section.dart';
import 'package:memo_care/features/fasting/presentation/widgets/ramadan_header.dart';
import 'package:memo_care/features/fasting/presentation/widgets/sehri_iftar_cards.dart';
import 'package:memo_care/features/fasting/presentation/widgets/star_dot_pattern.dart';

/// Standalone Ramadan/Fasting Mode screen.
///
/// Wrapped in [RamadanTheme] so the dark gold palette is applied automatically.
/// Accessible from Settings via fasting toggle or the home dashboard link.
class RamadanScreen extends ConsumerWidget {
  const RamadanScreen({super.key});

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final h = dt.hour;
    final m = dt.minute;
    final ampm = h < 12 ? 'AM' : 'PM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${hour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fastingState = ref.watch(fastingNotifierProvider);
    final notifier = ref.read(fastingNotifierProvider.notifier);

    return Theme(
      data: RamadanTheme.data,
      child: Scaffold(
        backgroundColor: RamadanColors.background,
        body: Stack(
          children: [
            // Star-dot background pattern.
            const Positioned.fill(child: StarDotPattern()),
            // Content.
            SafeArea(
              child: Column(
                children: [
                  // App bar area.
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        RamadanHeader(
                          fastingDay: fastingState.fastingDay,
                          totalDays: fastingState.totalDays,
                        ),
                        const Spacer(),
                        _IconButton(
                          icon: Icons.notifications_rounded,
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _IconButton(
                          icon: Icons.settings_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // Location chip.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withAlpha(25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: RamadanColors.iftarGold,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              fastingState.locationName.isEmpty
                                  ? 'Select Location'
                                  : fastingState.locationName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.expand_more_rounded,
                              color: Colors.white38,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Scrollable body.
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sehri / Iftar cards.
                          if (fastingState.sehriTime != null &&
                              fastingState.iftarTime != null)
                            SehriIftarCards(
                              sehriTime: fastingState.sehriTime!,
                              iftarTime: fastingState.iftarTime!,
                            ),
                          const SizedBox(height: 24),
                          // Fasting progress bar.
                          FastingProgressBar(
                            progress: fastingState.progressPercent,
                            sehriLabel:
                                'Sehri ${_formatTime(fastingState.sehriTime)}',
                            iftarLabel:
                                'Iftar ${_formatTime(fastingState.iftarTime)}',
                          ),
                          const SizedBox(height: 32),
                          // Sehri medicine section.
                          MedicineSection(
                            section: FastingSection.sehri,
                            medicines: fastingState.sehriMedicines,
                            onMarkTaken: notifier.markSehriMedicineTaken,
                          ),
                          const SizedBox(height: 36),
                          // Iftar medicine section.
                          MedicineSection(
                            section: FastingSection.iftar,
                            medicines: fastingState.iftarMedicines,
                            onMarkTaken: notifier.markIftarMedicineTaken,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
