import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_notes/features/voice_record/presentation/providers/recorder_provider.dart';
import 'package:vibe_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:vibe_notes/features/notes/domain/note.dart';
import 'package:vibe_notes/features/voice_record/presentation/widgets/waveform_widget.dart';
import 'package:record/record.dart';

class RecordingSheet extends ConsumerStatefulWidget {
  const RecordingSheet({super.key});

  @override
  ConsumerState<RecordingSheet> createState() => _RecordingSheetState();
}

class _RecordingSheetState extends ConsumerState<RecordingSheet> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRecording = false;
  double _amplitude = 0.0;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRecording();
    });
  }

  Future<void> _startRecording() async {
    final recorder = ref.read(recorderServiceProvider);
    final hasPermission = await recorder.hasPermission();
    
    if (hasPermission) {
      final fileName = 'vibe_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _recordingPath = await recorder.start(fileName);
      
      // Listen to amplitude
      _amplitudeSubscription = recorder.amplitudeStream.listen((amp) {
        if (mounted) {
          setState(() {
            // Normalize amplitude (usually -160 to 0 dB)
            _amplitude = ((amp.current + 60) / 60).clamp(0.0, 1.0);
          });
        }
      });
      
      ref.read(recordingDurationProvider.notifier).startTimer();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    
    _amplitudeSubscription?.cancel();
    final path = await ref.read(recorderServiceProvider).stop();
    ref.read(recordingDurationProvider.notifier).stopTimer();
    setState(() => _isRecording = false);
    
    if (mounted) {
      final result = await _showTitleAndCategoryDialog();
      if (result != null) {
        await ref.read(notesControllerProvider).addNote(
          result['title'] as String,
          audioPath: path ?? _recordingPath,
          category: result['category'] as NoteCategory,
        );
      }
      Navigator.pop(context);
    }
  }

  Future<Map<String, dynamic>?> _showTitleAndCategoryDialog() async {
    final controller = TextEditingController();
    NoteCategory selectedCategory = NoteCategory.other;
    
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Save your note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Note title...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Category', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: NoteCategory.values.map((category) {
                  final isSelected = category == selectedCategory;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedCategory = category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(category.colorValue).withOpacity(0.3) : Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? Border.all(color: Color(category.colorValue), width: 2) : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category.emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(category.displayName, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'title': controller.text.isEmpty ? 'Untitled Note' : controller.text,
                'category': selectedCategory,
              }),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = ref.watch(recordingDurationProvider);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final formattedDuration = "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";

    return Container(
      height: 380,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A1B3D), Color(0xFF1E1E1E)]),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red.withOpacity(0.2) : Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isRecording)
                  Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 8), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                Text(_isRecording ? 'Recording' : 'Ready', style: TextStyle(color: _isRecording ? Colors.red[300] : Colors.white54, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Waveform
          WaveformWidget(isRecording: _isRecording, amplitude: _amplitude),
          const SizedBox(height: 16),
          
          // Timer
          Text(formattedDuration, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w200, color: Colors.white, letterSpacing: 4, fontFeatures: [FontFeature.tabularFigures()])),
          const SizedBox(height: 24),
          
          // Stop button
          ScaleTransition(
            scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
            child: GestureDetector(
              onTap: _stopRecording,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isRecording ? [Colors.red[400]!, Colors.red[700]!] : [Colors.deepPurple[400]!, Colors.deepPurple[700]!],
                  ),
                  boxShadow: [BoxShadow(color: (_isRecording ? Colors.red : Colors.deepPurpleAccent).withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
                ),
                child: Icon(_isRecording ? Icons.stop_rounded : Icons.mic, size: 36, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(_isRecording ? 'Tap to finish' : '', style: const TextStyle(color: Colors.white30, fontSize: 14)),
        ],
      ),
    );
  }
}
