import 'package:memo_care/core/platform/network_status_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for sending WhatsApp notifications to a caregiver.
class CaregiverService {
  /// Normalizes an input phone string into E.164 digits-only format.
  ///
  /// Example: `+91 98765 43210` -> `919876543210`.
  static String normalizeE164Phone(String input) {
    return input.replaceAll(RegExp(r'\D'), '');
  }

  /// Validates E.164 phone number format.
  ///
  /// The number must include country code and contain 8-15 digits.
  static bool isValidE164(String input) {
    final normalized = normalizeE164Phone(input);
    final matched = RegExp(r'^[1-9]\d{7,14}').stringMatch(normalized);
    return matched == normalized;
  }

  /// Returns true if the device currently has network connectivity.
  static Future<bool> hasNetworkConnection() {
    return NetworkStatusService.hasNetworkConnection();
  }

  static Future<bool> _launchWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    if (!await hasNetworkConnection()) return false;

    final normalizedPhone = normalizeE164Phone(phoneNumber);
    if (!isValidE164(normalizedPhone)) return false;

    final encoded = Uri.encodeComponent(message);
    final nativeUri = Uri.parse(
      'whatsapp://send?phone=$normalizedPhone&text=$encoded',
    );
    if (await canLaunchUrl(nativeUri)) {
      return launchUrl(nativeUri, mode: LaunchMode.externalApplication);
    }

    // Browser fallback when WhatsApp app isn't installed.
    final waMeUri = Uri.parse('https://wa.me/$normalizedPhone?text=$encoded');
    if (await canLaunchUrl(waMeUri)) {
      return launchUrl(waMeUri, mode: LaunchMode.externalApplication);
    }

    return false;
  }

  /// Sends a WhatsApp message to the caregiver about a missed reminder.
  /// Returns true if WhatsApp was successfully launched.
  static Future<bool> sendMissedReminderAlert({
    required String phoneNumber,
    required String medicineName,
    required String? dosage,
    required DateTime scheduledAt,
  }) async {
    final timeStr =
        '${scheduledAt.hour}:${scheduledAt.minute.toString().padLeft(2, '0')}';
    final doseText = dosage != null ? ' ($dosage)' : '';
    final message =
        'Hi, your loved one missed their $medicineName$doseText reminder '
        'at $timeStr. Please check on them.';

    return _launchWhatsAppMessage(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  /// Sends a test alert to verify the caregiver link works.
  static Future<bool> sendTestAlert({required String phoneNumber}) async {
    const message =
        'MemoCare Test: This is a test message to verify '
        'your caregiver link is working. No action needed!';

    return _launchWhatsAppMessage(
      phoneNumber: phoneNumber,
      message: message,
    );
  }
}
