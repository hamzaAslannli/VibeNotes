import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_notes/features/voice_record/application/recorder_service.dart';

final recorderServiceProvider = Provider<RecorderService>((ref) {
  final service = RecorderService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Simple timer provider for recording duration
final recordingDurationProvider = StateNotifierProvider<RecordingTimerNotifier, Duration>((ref) {
  return RecordingTimerNotifier();
});

class RecordingTimerNotifier extends StateNotifier<Duration> {
  Timer? _timer;

  RecordingTimerNotifier() : super(Duration.zero);

  void startTimer() {
    _timer?.cancel();
    state = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = Duration(seconds: timer.tick);
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
  
  void reset() {
    stopTimer();
    state = Duration.zero;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
