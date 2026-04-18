import 'package:flutter/foundation.dart';

class TelemetryService {
  const TelemetryService();

  void track(String event, [Map<String, Object?> params = const <String, Object?>{}]) {
    debugPrint('[telemetry] $event ${params.isEmpty ? '' : params}');
  }
}
