import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/fasting/domain/prayer_times.dart';

/// Simplified prayer time service with city-based defaults.
class PrayerTimeService {
  const PrayerTimeService();

  PrayerTimes calculateForDate({
    required DateTime date,
    String city = 'Dhaka',
  }) {
    final month = date.month;

    // Approximate seasonal offsets in minutes for a lightweight offline model.
    final seasonalOffset = switch (month) {
      11 || 12 || 1 => -10,
      2 || 3 => -5,
      4 || 5 => 0,
      6 || 7 => 8,
      8 || 9 => 4,
      _ => 0,
    };

    final base = _cityProfiles[city] ?? _cityProfiles['Dhaka']!;

    DateTime at(int hour, int minute) {
      final t = DateTime(date.year, date.month, date.day, hour, minute);
      return t.add(Duration(minutes: seasonalOffset));
    }

    return PrayerTimes(
      fajr: at(base.fajrHour, base.fajrMinute),
      sunrise: at(base.sunriseHour, base.sunriseMinute),
      dhuhr: at(base.dhuhrHour, base.dhuhrMinute),
      asr: at(base.asrHour, base.asrMinute),
      maghrib: at(base.maghribHour, base.maghribMinute),
      isha: at(base.ishaHour, base.ishaMinute),
    );
  }
}

class _CityPrayerProfile {
  const _CityPrayerProfile({
    required this.fajrHour,
    required this.fajrMinute,
    required this.sunriseHour,
    required this.sunriseMinute,
    required this.dhuhrHour,
    required this.dhuhrMinute,
    required this.asrHour,
    required this.asrMinute,
    required this.maghribHour,
    required this.maghribMinute,
    required this.ishaHour,
    required this.ishaMinute,
  });

  final int fajrHour;
  final int fajrMinute;
  final int sunriseHour;
  final int sunriseMinute;
  final int dhuhrHour;
  final int dhuhrMinute;
  final int asrHour;
  final int asrMinute;
  final int maghribHour;
  final int maghribMinute;
  final int ishaHour;
  final int ishaMinute;
}

const _cityProfiles = <String, _CityPrayerProfile>{
  'Dhaka': _CityPrayerProfile(
    fajrHour: 4,
    fajrMinute: 38,
    sunriseHour: 5,
    sunriseMinute: 58,
    dhuhrHour: 12,
    dhuhrMinute: 2,
    asrHour: 15,
    asrMinute: 32,
    maghribHour: 18,
    maghribMinute: 24,
    ishaHour: 19,
    ishaMinute: 40,
  ),
};

final prayerTimeServiceProvider = Provider<PrayerTimeService>(
  (ref) => const PrayerTimeService(),
);
