import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
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
  }

  Future<void> _stopRecording() async {
    final path = await ref.read(recorderServiceProvider).stop();
    ref.read(recordingDurationProvider.notifier).stopTimer();
    
    if (path != null) {
      if (mounted) {
         // Create a new note automatically
         await ref.read(notesControllerProvider.notifier).addNote(
           "New Voice Note ${DateTime.now().toString()}", // Placeholder until AI summary
           audioPath: path
         );
         Navigator.pop(context);
      }
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
    final amplitudeAsync = ref.watch(amplitudeProvider);

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
            'Listening...',
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
                backgroundColor: Colors.deepPurpleAccent,
                shape: const CircleBorder(),
                child: const Icon(Icons.stop, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Simple visualizer bar based on amplitude could go here
          amplitudeAsync.when(
            data: (amp) => Text(
              "Level: ${amp.current.toStringAsFixed(1)} dB",
              style: const TextStyle(color: Colors.white24, fontSize: 10),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}
