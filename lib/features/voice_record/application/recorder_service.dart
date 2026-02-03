import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RecorderService {
  final Record _audioRecorder; // Record 4.x uses 'Record' class, not 'AudioRecorder'
  StreamSubscription<RecordState>? _recordStateSubscription;
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  RecorderService({Record? audioRecorder})
      : _audioRecorder = audioRecorder ?? Record();

  Future<void> dispose() async {
    await _recordStateSubscription?.cancel();
    await _amplitudeSubscription?.cancel();
    _audioRecorder.dispose();
  }

  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  Future<Stream<RecordState>> get onStateChanged async {
    return _audioRecorder.onStateChanged(_audioRecorder.onStateChanged); // Re-exposing stream
  }
  
 // Helper to expose the pure stream directly if needed, or better, just expose state 
  Stream<RecordState> get stateStream => _audioRecorder.onStateChanged;
  Stream<Amplitude> get amplitudeStream => _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 160));

  Future<void> start(String fileName) async {
    if (await _audioRecorder.hasPermission()) {
      String path;
      if (kIsWeb) {
        // On web, path is not used/supported in the same way for saving files directly via the record package often
        // but we can pass a dummy or let the browser handle the blob.
        // For simplicity in this Vibe coding session, we won't specify a path which triggers Memory/Blob recording.
        path = ''; 
      } else {
        final dir = await getApplicationDocumentsDirectory();
        path = '${dir.path}/$fileName';
        await Directory(dir.path).create(recursive: true);
      }

      // Record 4.x uses different start signature
      // encoder: AudioEncoder.aacLc is default usually or passed differently
      await _audioRecorder.start(
        path: path.isEmpty ? null : path, // Record 4.x supports null path for stream/temp
        encoder: AudioEncoder.aacLc,
      );
    }
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
}
