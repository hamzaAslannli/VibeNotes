import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class RecorderService {
  final Record _audioRecorder = Record();
  
  Stream<RecordState> get stateStream => _audioRecorder.onStateChanged();
  Stream<Amplitude> get amplitudeStream => _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100));

  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  Future<String?> start(String fileName) async {
    if (await _audioRecorder.hasPermission()) {
      String? path;
      
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        path = '${dir.path}/$fileName';
        await Directory(dir.path).create(recursive: true);
      }

      await _audioRecorder.start(
        path: path,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );
      
      return path;
    }
    return null;
  }

  Future<String?> stop() async {
    return await _audioRecorder.stop();
  }

  Future<void> pause() async {
    await _audioRecorder.pause();
  }

  Future<void> resume() async {
    await _audioRecorder.resume();
  }

  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}
