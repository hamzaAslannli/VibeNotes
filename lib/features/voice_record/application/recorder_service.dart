import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

// Simplified recorder that works on Web (mock) and Mobile (real)
class RecorderService {
  bool _isRecording = false;
  DateTime? _startTime;
  Timer? _durationTimer;
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();

  Stream<Duration> get durationStream => _durationController.stream;
  bool get isRecording => _isRecording;

  Future<bool> hasPermission() async {
    // On web, we'll just return true for demo purposes
    return true;
  }

  Future<void> start(String fileName) async {
    if (_isRecording) return;
    
    _isRecording = true;
    _startTime = DateTime.now();
    
    // Start a timer to emit duration updates
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!);
        _durationController.add(elapsed);
      }
    });
  }

  Future<String?> stop() async {
    if (!_isRecording) return null;
    
    _isRecording = false;
    _durationTimer?.cancel();
    _durationTimer = null;
    
    // Return a mock path for Web, or could be real path for mobile later
    final mockPath = kIsWeb ? 'web_recording_${DateTime.now().millisecondsSinceEpoch}.m4a' : null;
    _startTime = null;
    
    return mockPath;
  }

  void dispose() {
    _durationTimer?.cancel();
    _durationController.close();
  }
}
