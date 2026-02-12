import 'dart:async';
import 'dart:math';

/// Web-compatible mock recorder service.
/// On web, we simulate recording (no native mic access).
class PlatformRecorderService {
  bool _isRecording = false;
  Timer? _timer;
  final _amplitudeController = StreamController<double>.broadcast();
  final _random = Random();

  Stream<double> get amplitudeStream => _amplitudeController.stream;

  Future<bool> hasPermission() async => true;

  Future<String?> start(String fileName) async {
    _isRecording = true;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isRecording) {
        _amplitudeController.add(0.3 + _random.nextDouble() * 0.6);
      }
    });
    return 'web_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  Future<String?> stop() async {
    _isRecording = false;
    _timer?.cancel();
    _timer = null;
    return 'web_recording.m4a';
  }

  void dispose() {
    _timer?.cancel();
    _amplitudeController.close();
  }
}
