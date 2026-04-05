import 'package:memo_care/core/platform/caregiver_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for launching phone dialer intents.
class PhoneCallService {
  /// Opens the dialer with [phoneNumber] pre-filled.
  ///
  /// Returns true when a dialer app is available and launch succeeds.
  static Future<bool> openDialer({required String phoneNumber}) async {
    final normalized = CaregiverService.normalizeE164Phone(phoneNumber);
    if (!CaregiverService.isValidE164(normalized)) return false;

    final dialUri = Uri(
      scheme: 'tel',
      path: normalized,
    );
    if (!await canLaunchUrl(dialUri)) return false;

    return launchUrl(dialUri, mode: LaunchMode.externalApplication);
  }
}
