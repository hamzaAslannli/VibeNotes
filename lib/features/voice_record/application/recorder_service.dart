import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditionally import native packages
import 'recorder_service_mobile.dart' if (dart.library.html) 'recorder_service_web.dart' as platform;

class RecorderService {
  final platform.PlatformRecorderService _service = platform.PlatformRecorderService();

  Stream<double> get amplitudeStream => _service.amplitudeStream;

  Future<bool> hasPermission() => _service.hasPermission();
  Future<String?> start(String fileName) => _service.start(fileName);
  Future<String?> stop() => _service.stop();
  
  void dispose() => _service.dispose();
}
