import 'package:flutter/foundation.dart';

/// Paired enter/exit logs for bootstrap and feature debugging.
/// Grep for [kTracePrefix] in console to follow a flow.
const String kTracePrefix = 'MemoCareTrace';

void traceEnter(String scope, String step) {
  if (kDebugMode) {
    debugPrint('$kTracePrefix ▸ enter $scope::$step');
  }
}

void traceExit(String scope, String step, [Object? error]) {
  if (kDebugMode) {
    if (error != null) {
      debugPrint('$kTracePrefix ▸ exit  $scope::$step error=$error');
    } else {
      debugPrint('$kTracePrefix ▸ exit  $scope::$step');
    }
  }
}

/// Runs [body] and logs enter/exit; rethrows after logging on failure.
Future<T> traceAsync<T>(
  String scope,
  String step,
  Future<T> Function() body,
) async {
  traceEnter(scope, step);
  try {
    final result = await body();
    traceExit(scope, step);
    return result;
  } catch (e, st) {
    traceExit(scope, step, e);
    Error.throwWithStackTrace(e, st);
  }
}

/// Same as [traceAsync] for synchronous work.
T traceSync<T>(String scope, String step, T Function() body) {
  traceEnter(scope, step);
  try {
    final result = body();
    traceExit(scope, step);
    return result;
  } catch (e, st) {
    traceExit(scope, step, e);
    Error.throwWithStackTrace(e, st);
  }
}
