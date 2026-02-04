import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_notes/features/notes/domain/note.dart';
import 'package:vibe_notes/features/notes/presentation/providers/note_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_hasChanges) {
      widget.note.content = _titleController.text;
      await ref.read(storageServiceProvider).saveNote(widget.note);
      await ref.read(notesControllerProvider.notifier).refresh();
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
          if (_isEditing)
            TextButton(
              onPressed: _saveChanges,
              child: const Text('Save', style: TextStyle(color: Colors.deepPurpleAccent)),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white70),
              onPressed: () => setState(() => _isEditing = true),
            ),
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
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(notesControllerProvider.notifier).deleteNote(widget.note.id);
                  Navigator.pop(context);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: const [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            if (_isEditing)
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Note title...',
                  hintStyle: TextStyle(color: Colors.white30),
                ),
                onChanged: (_) => setState(() => _hasChanges = true),
              )
            else
              Text(
                widget.note.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Date & time info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, color: Colors.white38, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    DateHelper.getRelativeTime(widget.note.createdAt),
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today_outlined, color: Colors.white38, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.note.createdAt.day}/${widget.note.createdAt.month}/${widget.note.createdAt.year}',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Audio indicator (if has audio)
            if (widget.note.audioPath != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.2),
                      Colors.purple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.graphic_eq, color: Colors.deepPurpleAccent, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Voice Recording',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Recorded ${DateHelper.getRelativeTime(widget.note.createdAt)}',
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    // Play button (placeholder for future)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
