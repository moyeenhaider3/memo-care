import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

/// Twin side-by-side cards showing Sehri End time and Iftar time
/// with live countdown timers.
class SehriIftarCards extends StatefulWidget {
  const SehriIftarCards({
    required this.sehriTime,
    required this.iftarTime,
    super.key,
  });

  final DateTime sehriTime;
  final DateTime iftarTime;

  @override
  State<SehriIftarCards> createState() => _SehriIftarCardsState();
}

class _SehriIftarCardsState extends State<SehriIftarCards> {
  Timer? _timer;
  Duration _sehriRemaining = Duration.zero;
  Duration _iftarRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(_update);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _update() {
    final now = DateTime.now();
    _sehriRemaining = widget.sehriTime.isAfter(now)
        ? widget.sehriTime.difference(now)
        : Duration.zero;
    _iftarRemaining = widget.iftarTime.isAfter(now)
        ? widget.iftarTime.difference(now)
        : Duration.zero;
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute;
    final ampm = h < 12 ? 'AM' : 'PM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    // ignore: lines_longer_than_ // workaround
    // ignore: lines_longer_than_80_chars // workaround
    return '${hour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $ampm';
  }

  String _countdown(Duration d) {
    if (d == Duration.zero) return 'Now';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return 'in ${h}h ${m}m';
    return 'in ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeCard(
            label: 'Sehri Ends',
            time: _formatTime(widget.sehriTime),
            countdown: _countdown(_sehriRemaining),
            borderColor: RamadanColors.sehriBlue,
            icon: Icons.nights_stay_rounded,
            iconColor: RamadanColors.sehriBlue,
            countdownColor: Colors.amber.withAlpha(230),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TimeCard(
            label: 'Iftar Today',
            time: _formatTime(widget.iftarTime),
            countdown: _countdown(_iftarRemaining),
            borderColor: RamadanColors.iftarGold,
            icon: Icons.wb_twilight_rounded,
            iconColor: RamadanColors.iftarGold,
            countdownColor: RamadanColors.iftarGold,
          ),
        ),
      ],
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.time,
    required this.countdown,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.countdownColor,
  });

  final String label;
  final String time;
  final String countdown;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final Color countdownColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RamadanColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(color: borderColor, width: 2.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: countdownColor,
              ),
              const SizedBox(width: 4),
              Text(
                countdown,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: countdownColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
