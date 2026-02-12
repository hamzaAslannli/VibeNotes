import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class PlatformRecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  Stream<double> get amplitudeStream => 
    _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100))
      .map((amp) => ((amp.current + 60) / 60).clamp(0.0, 1.0));

  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  Future<String?> start(String fileName) async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/$fileName';
      await Directory(dir.path).create(recursive: true);

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      
      return path;
    }
    return null;
  }

  Future<String?> stop() async {
    return await _audioRecorder.stop();
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}
