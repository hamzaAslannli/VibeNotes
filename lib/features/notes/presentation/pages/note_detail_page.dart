import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibe_notes/features/notes/domain/note.dart';
import 'package:vibe_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:vibe_notes/features/voice_record/application/audio_player_service.dart';
import 'package:vibe_notes/core/services/ai_service.dart';
import 'package:vibe_notes/core/utils/date_helper.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  late TextEditingController _titleController;
  bool _isEditing = false;
  bool _hasChanges = false;

  // Audio player state
  AudioPlayerService? _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlayerReady = false;
  double _playbackSpeed = 1.0;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _stateSub;

  // AI state
  bool _isSummarizing = false;
  bool _isExtractingKeywords = false;
  bool _isGeneratingActions = false;
  bool _isExpandingIdea = false;
  final AIService _aiService = AIService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.content);
    if (!kIsWeb && widget.note.audioPath != null) {
      _initAudioPlayer();
    }
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer = AudioPlayerService();
    try {
      await _audioPlayer!.setFilePath(widget.note.audioPath!);
      _isPlayerReady = true;

      _durationSub = _audioPlayer!.durationStream.listen((d) {
        if (d != null && mounted) setState(() => _duration = d);
      });

      _positionSub = _audioPlayer!.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });

      _stateSub = _audioPlayer!.playerStateStream.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state.playing);
          if (state.processingState.toString().contains('completed')) {
            _audioPlayer!.seek(Duration.zero);
            setState(() => _isPlaying = false);
          }
        }
      });

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Audio player error: $e');
      _isPlayerReady = false;
      if (mounted) setState(() {});
    }
  }

  void _togglePlayback() {
    if (_audioPlayer == null || !_isPlayerReady) return;
    if (_isPlaying) {
      _audioPlayer!.pause();
    } else {
      _audioPlayer!.play();
    }
  }

  // AI Methods
  Future<void> _summarizeNote() async {
    if (!(await AIService.hasApiKey())) {
      _showApiKeyNeeded();
      return;
    }

    setState(() => _isSummarizing = true);
    
    final text = widget.note.transcript ?? widget.note.content;
    final summary = await _aiService.summarizeText(text);
    
    if (summary != null && mounted) {
      setState(() {
        widget.note.summary = summary;
        widget.note.isSummarized = true;
        _isSummarizing = false;
      });
      await ref.read(notesControllerProvider).updateNote(widget.note);
    } else {
      setState(() => _isSummarizing = false);
    }
  }

  Future<void> _extractKeywords() async {
    if (!(await AIService.hasApiKey())) {
      _showApiKeyNeeded();
      return;
    }

    setState(() => _isExtractingKeywords = true);
    
    final text = widget.note.transcript ?? widget.note.content;
    final keywords = await _aiService.extractKeywords(text);
    
    if (keywords.isNotEmpty && mounted) {
      setState(() {
        widget.note.keywords = keywords;
        _isExtractingKeywords = false;
      });
      await ref.read(notesControllerProvider).updateNote(widget.note);
    } else {
      setState(() => _isExtractingKeywords = false);
    }
  }

  Future<void> _generateActionItems() async {
    if (!(await AIService.hasApiKey())) {
      _showApiKeyNeeded();
      return;
    }

    setState(() => _isGeneratingActions = true);
    
    final text = widget.note.transcript ?? widget.note.content;
    final actions = await _aiService.generateActionItems(text);
    
    if (actions != null && mounted) {
      setState(() {
        widget.note.actionItems = actions;
        _isGeneratingActions = false;
      });
      await ref.read(notesControllerProvider).updateNote(widget.note);
    } else {
      setState(() => _isGeneratingActions = false);
    }
  }

  void _showApiKeyNeeded() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.key, color: Colors.amber, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text('API Key gerekli! Settings\'ten ekleyin.')),
          ],
        ),
        backgroundColor: const Color(0xFF2A2A2A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(label: 'Settings', textColor: Colors.deepPurpleAccent, onPressed: () {
          Navigator.pushNamed(context, '/settings');
        }),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _audioPlayer?.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_hasChanges) {
      widget.note.content = _titleController.text;
      await ref.read(storageServiceProvider).saveNote(widget.note);
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () {
            if (_hasChanges) {
              _saveChanges().then((_) => Navigator.pop(context));
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: _shareNote,
          ),
          if (_isEditing)
            TextButton(onPressed: _saveChanges, child: const Text('Save', style: TextStyle(color: Colors.deepPurpleAccent)))
          else
            IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.white70), onPressed: () => setState(() => _isEditing = true)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Delete Note?', style: TextStyle(color: Colors.white)),
                    content: const Text('This action cannot be undone.', style: TextStyle(color: Colors.white54)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete', style: TextStyle(color: Colors.white))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(notesControllerProvider).deleteNote(widget.note.id);
                  Navigator.pop(context);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'delete', child: Row(children: const [Icon(Icons.delete_outline, color: Colors.red, size: 20), SizedBox(width: 12), Text('Delete', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Color(widget.note.category.colorValue).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.note.category.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(widget.note.category.displayName, style: TextStyle(color: Color(widget.note.category.colorValue), fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            if (_isEditing)
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Note title...', hintStyle: TextStyle(color: Colors.white30)),
                onChanged: (_) => setState(() => _hasChanges = true),
              )
            else
              Text(widget.note.content, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 16),
            
            // Date info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, color: Colors.white38, size: 16),
                  const SizedBox(width: 8),
                  Text(DateHelper.getRelativeTime(widget.note.createdAt), style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today_outlined, color: Colors.white38, size: 14),
                  const SizedBox(width: 8),
                  Text('${widget.note.createdAt.day}/${widget.note.createdAt.month}/${widget.note.createdAt.year}', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Audio Player Section
            if (widget.note.audioPath != null)
              _buildAudioPlayer(),

            const SizedBox(height: 24),

            // AI Action Buttons
            _buildAIButtons(),

            // AI Summary
            if (widget.note.summary != null) ...[
              const SizedBox(height: 20),
              _buildAISummaryCard(),
            ],

            // Keywords
            if (widget.note.keywords.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildKeywordsSection(),
            ],

            // Action Items
            if (widget.note.actionItems != null) ...[
              const SizedBox(height: 16),
              _buildActionItemsCard(),
            ],

            // Expanded Idea
            if (widget.note.expandedIdea != null) ...[
              const SizedBox(height: 16),
              _buildExpandedIdeaCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    if (kIsWeb) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.deepPurple.withOpacity(0.2), Colors.purple.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.headset_off, color: Colors.white38, size: 24),
            ),
            const SizedBox(width: 16),
            const Text('Audio playback available on mobile', style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple.withOpacity(0.25), Colors.purple.withOpacity(0.12), Colors.deepPurple.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Voice Recording', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      _isPlayerReady ? '${_formatDuration(_position)} / ${_formatDuration(_duration)}' : 'Loading...',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _isPlayerReady ? _togglePlayback : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: _isPlayerReady
                      ? LinearGradient(colors: _isPlaying ? [Colors.orange, Colors.deepOrange] : [Colors.deepPurpleAccent, Colors.purpleAccent])
                      : null,
                    color: _isPlayerReady ? null : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isPlayerReady ? [BoxShadow(color: (_isPlaying ? Colors.orange : Colors.deepPurpleAccent).withOpacity(0.4), blurRadius: 12, spreadRadius: 1)] : null,
                  ),
                  child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Colors.deepPurpleAccent,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: Colors.white,
              overlayColor: Colors.deepPurpleAccent.withOpacity(0.2),
            ),
            child: Slider(
              value: _duration.inMilliseconds > 0 ? _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()) : 0,
              max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1,
              onChanged: _isPlayerReady ? (value) { _audioPlayer?.seek(Duration(milliseconds: value.toInt())); } : null,
            ),
          ),
          if (_isPlayerReady)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildSpeedChip(0.5), _buildSpeedChip(1.0), _buildSpeedChip(1.5), _buildSpeedChip(2.0)],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpeedChip(double speed) {
    final isSelected = _playbackSpeed == speed;
    return GestureDetector(
      onTap: () {
        setState(() => _playbackSpeed = speed);
        _audioPlayer?.setSpeed(speed);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurpleAccent.withOpacity(0.4) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.deepPurpleAccent, width: 1) : null,
        ),
        child: Text('${speed}x', style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  Widget _buildAIButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.08), Colors.cyan.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.cyanAccent.withOpacity(0.8), size: 18),
              const SizedBox(width: 8),
              const Text('AI Tools', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildAIActionButton(
                icon: Icons.summarize_rounded,
                label: 'Özetle',
                isLoading: _isSummarizing,
                onTap: _summarizeNote,
                color: Colors.cyan,
              )),
              const SizedBox(width: 8),
              Expanded(child: _buildAIActionButton(
                icon: Icons.tag,
                label: 'Keywords',
                isLoading: _isExtractingKeywords,
                onTap: _extractKeywords,
                color: Colors.amber,
              )),
              const SizedBox(width: 8),
              Expanded(child: _buildAIActionButton(
                icon: Icons.checklist_rounded,
                label: 'Görevler',
                isLoading: _isGeneratingActions,
                onTap: _generateActionItems,
                color: Colors.orange,
              )),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _buildAIActionButton(
              icon: Icons.lightbulb_rounded,
              label: '💡 Fikri Genişlet',
              isLoading: _isExpandingIdea,
              onTap: _expandIdea,
              color: Colors.purpleAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIActionButton({
    required IconData icon,
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            isLoading 
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: color, strokeWidth: 2))
              : Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildAISummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.cyan.withOpacity(0.12), Colors.blue.withOpacity(0.06)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.cyanAccent.withOpacity(0.8), size: 18),
              const SizedBox(width: 8),
              const Text('AI Summary', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(),
              GestureDetector(
                onTap: _summarizeNote,
                child: Icon(Icons.refresh, color: Colors.white.withOpacity(0.3), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.note.summary!, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildKeywordsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.note.keywords.map((keyword) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tag, color: Colors.amber.withOpacity(0.7), size: 14),
            const SizedBox(width: 4),
            Text(keyword, style: TextStyle(color: Colors.amber.withOpacity(0.8), fontSize: 13)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildActionItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.withOpacity(0.1), Colors.deepOrange.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist_rounded, color: Colors.orange.withOpacity(0.8), size: 18),
              const SizedBox(width: 8),
              const Text('Action Items', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.note.actionItems!, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  void _shareNote() {
    final buffer = StringBuffer();
    buffer.writeln('📝 ${widget.note.content}');
    buffer.writeln();
    if (widget.note.summary != null) {
      buffer.writeln('✨ AI Summary:');
      buffer.writeln(widget.note.summary);
      buffer.writeln();
    }
    if (widget.note.keywords.isNotEmpty) {
      buffer.writeln('🏷️ Keywords: ${widget.note.keywords.join(", ")}');
      buffer.writeln();
    }
    if (widget.note.expandedIdea != null) {
      buffer.writeln('💡 Expanded Idea:');
      buffer.writeln(widget.note.expandedIdea);
      buffer.writeln();
    }
    buffer.writeln('— Shared via Vibe Notes 🎙️');
    Share.share(buffer.toString());
  }

  Future<void> _expandIdea() async {
    if (!(await AIService.hasApiKey())) {
      _showApiKeyNeeded();
      return;
    }

    setState(() => _isExpandingIdea = true);
    
    final text = widget.note.transcript ?? widget.note.content;
    final expanded = await _aiService.expandIdea(text);
    
    if (expanded != null && mounted) {
      setState(() {
        widget.note.expandedIdea = expanded;
        _isExpandingIdea = false;
      });
      await ref.read(notesControllerProvider).updateNote(widget.note);
    } else {
      setState(() => _isExpandingIdea = false);
    }
  }

  Widget _buildExpandedIdeaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.purpleAccent.withOpacity(0.12), Colors.deepPurple.withOpacity(0.06)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Colors.purpleAccent.withOpacity(0.8), size: 18),
              const SizedBox(width: 8),
              const Text('Expanded Idea', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(),
              GestureDetector(
                onTap: _expandIdea,
                child: Icon(Icons.refresh, color: Colors.white.withOpacity(0.3), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.note.expandedIdea!, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
