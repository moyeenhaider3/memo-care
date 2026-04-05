import 'package:connectivity_plus/connectivity_plus.dart';

/// Utility for checking whether the device currently has network access.
class NetworkStatusService {
  const NetworkStatusService._();

  /// Returns true when at least one active connectivity transport exists.
  static Future<bool> hasNetworkConnection({
    Connectivity? connectivity,
  }) async {
    final plugin = connectivity ?? Connectivity();
    final results = await plugin.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }
}
