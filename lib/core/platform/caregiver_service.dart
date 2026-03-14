import 'package:url_launcher/url_launcher.dart';

/// Service for sending WhatsApp notifications to a caregiver.
class CaregiverService {
  /// Sends a WhatsApp message to the caregiver about a missed reminder.
  /// Returns true if WhatsApp was successfully launched.
  static Future<bool> sendMissedReminderAlert({
    required String phoneNumber,
    required String medicineName,
    required String? dosage,
    required DateTime scheduledAt,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final timeStr =
        '${scheduledAt.hour}:${scheduledAt.minute.toString().padLeft(2, '0')}';
    final doseText = dosage != null ? ' ($dosage)' : '';
    final message =
        'MemoCare Alert: Your loved one missed their '
        '$medicineName$doseText reminder scheduled at $timeStr. '
        'Please check on them.';

    final uri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Sends a test alert to verify the caregiver link works.
  static Future<bool> sendTestAlert({required String phoneNumber}) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    const message =
        'MemoCare Test: This is a test message to verify '
        'your caregiver link is working. No action needed!';

    final uri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
