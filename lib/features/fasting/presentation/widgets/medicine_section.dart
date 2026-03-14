import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/features/fasting/domain/fasting_models.dart';

/// Grouped medicine section (Sehri or Iftar) with timeline connector line.
class MedicineSection extends StatelessWidget {
  const MedicineSection({
    required this.section,
    required this.medicines,
    required this.onMarkTaken,
    super.key,
  });

  final FastingSection section;
  final List<FastingMedicine> medicines;
  final ValueChanged<String> onMarkTaken;

  bool get _isSehri => section == FastingSection.sehri;

  Color get _accentColor =>
      _isSehri ? RamadanColors.sehriBlue : RamadanColors.iftarGold;

  String get _sectionTitle => _isSehri ? 'Sehri Medicines' : 'Iftar Medicines';

  IconData get _sectionIcon =>
      _isSehri ? Icons.bedtime_rounded : Icons.wb_twilight_rounded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header.
        Row(
          children: [
            Icon(_sectionIcon, color: _accentColor, size: 22),
            const SizedBox(width: 8),
            Text(
              _sectionTitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (medicines.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              'No medicines scheduled',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          )
        else
          // Timeline-connected cards.
          Stack(
            alignment: Alignment.topLeft,
            children: [
              // Gradient timeline line.
              Positioned(
                left: 20,
                top: 24,
                bottom: 24,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _accentColor.withAlpha(128),
                        _accentColor.withAlpha(25),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  for (var i = 0; i < medicines.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _MedicineCard(
                      medicine: medicines[i],
                      accentColor: _accentColor,
                      onMarkTaken: onMarkTaken,
                    ),
                  ],
                ],
              ),
            ],
          ),
      ],
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({
    required this.medicine,
    required this.accentColor,
    required this.onMarkTaken,
  });

  final FastingMedicine medicine;
  final Color accentColor;
  final ValueChanged<String> onMarkTaken;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: medicine.isTaken ? 0.6 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline node icon.
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: medicine.isTaken
                  ? accentColor.withAlpha(50)
                  : Colors.white.withAlpha(13),
              shape: BoxShape.circle,
              border: medicine.isTaken
                  ? null
                  : Border.all(color: Colors.white.withAlpha(25)),
            ),
            child: Icon(
              Icons.medication_rounded,
              color: medicine.isTaken ? accentColor : Colors.white38,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Card body.
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: RamadanColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(13)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          medicine.notes,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (medicine.isTaken)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Taken',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    )
                  else if (medicine.scheduledTime != null)
                    Text(
                      medicine.scheduledTime!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
