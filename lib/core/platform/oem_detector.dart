import 'package:device_info_plus/device_info_plus.dart';

/// A step in the battery optimization disable guide.
class OemGuidanceStep {
  /// Creates an [OemGuidanceStep].
  const OemGuidanceStep({
    required this.instruction,
    this.subInstruction,
  });

  /// Main instruction text
  /// (e.g., "Open Settings → Apps → MemoCare").
  final String instruction;

  /// Optional sub-instruction or clarification.
  final String? subInstruction;
}

/// Battery optimization guidance for a specific OEM.
class OemGuidance {
  /// Creates an [OemGuidance].
  const OemGuidance({
    required this.oemName,
    required this.severity,
    required this.steps,
    required this.warningText,
  });

  /// Display name of the OEM (e.g., "Xiaomi (MIUI)").
  final String oemName;

  /// Severity of the OEM's battery killing (1-10).
  final int severity;

  /// Step-by-step instructions to disable battery optimization.
  final List<OemGuidanceStep> steps;

  /// Warning text explaining why this matters.
  final String warningText;
}

/// Detects the device OEM and provides battery optimization
/// guidance.
///
/// Covers the top 6 aggressive OEMs plus a generic fallback.
/// All instructions are hardcoded — no network dependency.
class OemDetector {
  /// Creates an [OemDetector].
  OemDetector({DeviceInfoPlugin? deviceInfo})
      : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;
  String? _manufacturer;

  /// Gets the device manufacturer (lowercased), cached after
  /// first call.
  Future<String> getManufacturer() async {
    if (_manufacturer != null) return _manufacturer!;
    final info = await _deviceInfo.androidInfo;
    _manufacturer = info.manufacturer.toLowerCase().trim();
    return _manufacturer!;
  }

  /// Returns device-specific battery optimization guidance.
  Future<OemGuidance> getGuidance() async {
    final mfr = await getManufacturer();
    return _guidanceMap[mfr] ?? _genericGuidance;
  }

  /// Returns true if this OEM is known to aggressively kill
  /// background apps.
  Future<bool> isAggressiveOem() async {
    final mfr = await getManufacturer();
    return _guidanceMap.containsKey(mfr);
  }

  /// Expose for testing — allows checking guidance for any
  /// manufacturer string.
  static OemGuidance getGuidanceForManufacturer(
    String manufacturer,
  ) {
    return _guidanceMap[manufacturer.toLowerCase().trim()] ??
        _genericGuidance;
  }

  // ── OEM-specific guidance database ───────────────────────

  static const _guidanceMap = <String, OemGuidance>{
    'xiaomi': OemGuidance(
      oemName: 'Xiaomi (MIUI)',
      severity: 10,
      steps: [
        OemGuidanceStep(
          instruction:
              'Open Settings → Apps → Manage apps',
          subInstruction: 'Find and tap "MemoCare"',
        ),
        OemGuidanceStep(
          instruction: 'Tap "Autostart" and enable it',
          subInstruction:
              'This allows MemoCare to start automatically '
              'and run in the background',
        ),
        OemGuidanceStep(
          instruction:
              'Go back, tap "Battery saver"',
          subInstruction: 'Select "No restrictions"',
        ),
        OemGuidanceStep(
          instruction: 'In MIUI Settings → Battery '
              '→ App battery saver',
          subInstruction:
              'Find MemoCare and set to "No restrictions"',
        ),
      ],
      warningText:
          'Xiaomi phones aggressively stop background apps. '
          'Without these steps, your medication reminders '
          'may not work.',
    ),
    'samsung': OemGuidance(
      oemName: 'Samsung (OneUI)',
      severity: 8,
      steps: [
        OemGuidanceStep(
          instruction:
              'Open Settings → Apps → MemoCare',
        ),
        OemGuidanceStep(
          instruction:
              'Tap "Battery" → Select "Unrestricted"',
          subInstruction:
              'This prevents Samsung from putting '
              'MemoCare to sleep',
        ),
        OemGuidanceStep(
          instruction: 'Settings → Device care → Battery '
              '→ Background usage limits',
          subInstruction:
              'Make sure MemoCare is NOT in '
              '"Sleeping apps" or "Deep sleeping apps"',
        ),
      ],
      warningText:
          'Samsung may put MemoCare to sleep after a few '
          'days of low use, which will stop your reminders.',
    ),
    'huawei': OemGuidance(
      oemName: 'Huawei (EMUI)',
      severity: 9,
      steps: [
        OemGuidanceStep(
          instruction: 'Open Settings → Apps → Apps',
          subInstruction: 'Find and tap "MemoCare"',
        ),
        OemGuidanceStep(
          instruction:
              'Tap "Battery" → "App launch"',
          subInstruction:
              'Disable "Manage automatically" and enable '
              'all three toggles manually',
        ),
        OemGuidanceStep(
          instruction: 'Settings → Battery → More '
              'battery settings',
          subInstruction:
              'Disable "Ultra power saving" if enabled',
        ),
      ],
      warningText:
          'Huawei phones have strict power management. '
          'Without these settings, reminders will stop '
          'working after the screen is off.',
    ),
    'oppo': OemGuidance(
      oemName: 'Oppo (ColorOS)',
      severity: 8,
      steps: [
        OemGuidanceStep(
          instruction: 'Open Settings → App management '
              '→ App list',
          subInstruction: 'Find and tap "MemoCare"',
        ),
        OemGuidanceStep(
          instruction: 'Tap "Battery usage" → '
              '"Allow background activity"',
        ),
        OemGuidanceStep(
          instruction:
              'Also enable "Auto-launch" for MemoCare',
          subInstruction: 'Settings → Battery → More '
              'settings → Auto-launch',
        ),
      ],
      warningText:
          'Oppo restricts background apps by default. '
          'Enable background activity to keep your '
          'reminders working.',
    ),
    'vivo': OemGuidance(
      oemName: 'Vivo (FuntouchOS)',
      severity: 8,
      steps: [
        OemGuidanceStep(
          instruction: 'Open Settings → Battery '
              '→ Background power consumption',
          subInstruction:
              'Find "MemoCare" and allow background '
              'power consumption',
        ),
        OemGuidanceStep(
          instruction:
              'Settings → Apps → Autostart manager',
          subInstruction:
              'Enable autostart for MemoCare',
        ),
      ],
      warningText:
          'Vivo limits background apps aggressively. '
          'These steps are required for reliable '
          'reminders.',
    ),
    'oneplus': OemGuidance(
      oemName: 'OnePlus (OxygenOS)',
      severity: 6,
      steps: [
        OemGuidanceStep(
          instruction:
              'Open Settings → Apps → MemoCare',
        ),
        OemGuidanceStep(
          instruction: 'Tap "Battery" → '
              'Select "Don\'t optimize"',
        ),
        OemGuidanceStep(
          instruction: 'Settings → Battery '
              '→ Battery optimization',
          subInstruction:
              'Find MemoCare in the "All apps" list '
              'and select "Don\'t optimize"',
        ),
      ],
      warningText:
          'OnePlus may restrict MemoCare after extended '
          'screen-off periods. Disable battery optimization '
          'to prevent this.',
    ),
  };

  static const _genericGuidance = OemGuidance(
    oemName: 'Your device',
    severity: 5,
    steps: [
      OemGuidanceStep(
        instruction: 'Open Settings → Apps → MemoCare',
      ),
      OemGuidanceStep(
        instruction: 'Tap "Battery" → Select '
            '"Unrestricted" or "Don\'t optimize"',
        subInstruction:
            'The exact wording varies by device. Look for '
            'an option that allows MemoCare to run in the '
            'background.',
      ),
      OemGuidanceStep(
        instruction: 'If available, enable "Autostart" '
            'for MemoCare',
        subInstruction:
            'Check Settings → Battery → Background or '
            'Settings → Apps → Autostart',
      ),
    ],
    warningText:
        'Your device may stop background apps to save '
        'battery. Please ensure MemoCare is allowed to run '
        'in the background for reliable reminders.',
  );
}
