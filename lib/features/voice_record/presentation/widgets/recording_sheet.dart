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
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-start recording when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRecording();
    });
  }

  Future<void> _startRecording() async {
    final fileName = 'note_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await ref.read(recorderServiceProvider).start(fileName);
    ref.read(recordingDurationProvider.notifier).startTimer();
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    
    final path = await ref.read(recorderServiceProvider).stop();
    ref.read(recordingDurationProvider.notifier).stopTimer();
    
    setState(() {
      _isRecording = false;
    });
    
    if (mounted) {
      // Create a new note automatically
      await ref.read(notesControllerProvider.notifier).addNote(
        "Voice Note ${DateTime.now().toString().substring(0, 16)}",
        audioPath: path,
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = ref.watch(recordingDurationProvider);

    // Format duration nicely
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final formattedDuration = "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";

    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isRecording ? 'Recording...' : 'Tap to Record',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            formattedDuration,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 40),
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurpleAccent.withOpacity(0.3),
              ),
              child: FloatingActionButton(
                onPressed: _stopRecording,
                backgroundColor: _isRecording ? Colors.red : Colors.deepPurpleAccent,
                shape: const CircleBorder(),
                child: Icon(_isRecording ? Icons.stop : Icons.mic, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isRecording ? 'Tap to stop recording' : '',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
