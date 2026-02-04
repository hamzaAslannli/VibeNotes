import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_notes/features/voice_record/presentation/providers/recorder_provider.dart';
import 'package:vibe_notes/features/notes/presentation/providers/note_provider.dart';

class RecordingSheet extends ConsumerStatefulWidget {
  const RecordingSheet({super.key});

  @override
  ConsumerState<RecordingSheet> createState() => _RecordingSheetState();
}

class _RecordingSheetState extends ConsumerState<RecordingSheet> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRecording = false;

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
    final fileName = 'note_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await ref.read(recorderServiceProvider).start(fileName);
    ref.read(recordingDurationProvider.notifier).startTimer();
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    
    final path = await ref.read(recorderServiceProvider).stop();
    ref.read(recordingDurationProvider.notifier).stopTimer();
    setState(() => _isRecording = false);
    
    if (mounted) {
      final title = await _showTitleDialog();
      if (title != null && title.isNotEmpty) {
        await ref.read(notesControllerProvider).addNote(title, audioPath: path);
      }
      Navigator.pop(context);
    }
  }

  Future<String?> _showTitleDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Name your note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g. Meeting notes, Ideas...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'Untitled Note'),
            child: const Text('Skip', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.isEmpty ? 'Untitled Note' : controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = ref.watch(recordingDurationProvider);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final formattedDuration = "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";

    return Container(
      height: 320,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A1B3D), Color(0xFF1E1E1E)]),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          const SizedBox(height: 24),
          Text(formattedDuration, style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w200, color: Colors.white, letterSpacing: 4, fontFeatures: [FontFeature.tabularFigures()])),
          const SizedBox(height: 32),
          ScaleTransition(
            scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
            child: GestureDetector(
              onTap: _stopRecording,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isRecording ? [Colors.red[400]!, Colors.red[700]!] : [Colors.deepPurple[400]!, Colors.deepPurple[700]!],
                  ),
                  boxShadow: [BoxShadow(color: (_isRecording ? Colors.red : Colors.deepPurpleAccent).withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
                ),
                child: Icon(_isRecording ? Icons.stop_rounded : Icons.mic, size: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(_isRecording ? 'Tap to finish' : '', style: const TextStyle(color: Colors.white30, fontSize: 14)),
        ],
      ),
    );
  }
}
