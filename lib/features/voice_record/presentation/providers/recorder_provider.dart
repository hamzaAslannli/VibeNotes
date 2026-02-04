import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_notes/features/voice_record/application/recorder_service.dart';

final recorderServiceProvider = Provider<RecorderService>((ref) {
  final service = RecorderService();
  ref.onDispose(() => service.dispose());
  return service;
});

final recordingDurationProvider = StateNotifierProvider<RecordingDurationNotifier, Duration>((ref) {
  return RecordingDurationNotifier();
});

class RecordingDurationNotifier extends StateNotifier<Duration> {
  RecordingDurationNotifier() : super(Duration.zero);
  
  Timer? _timer;
  DateTime? _startTime;

  void startTimer() {
    _startTime = DateTime.now();
    state = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null) {
        state = DateTime.now().difference(_startTime!);
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    state = Duration.zero;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
