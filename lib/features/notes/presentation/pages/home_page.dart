import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:vibe_notes/features/voice_record/presentation/widgets/recording_sheet.dart';
import 'package:vibe_notes/features/notes/domain/note.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vibe Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_none_outlined, size: 64, color: Colors.white12),
                  const SizedBox(height: 16),
                  Text(
                    'No vibes yet.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white30),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return _buildNoteCard(context, note, ref);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => const RecordingSheet(),
          );
        },
        child: const Icon(Icons.mic),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note, WidgetRef ref) {
    return Dismissible(
      key: Key(note.id.toString()),
      background: Container(
        color: Colors.red.withOpacity(0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
         ref.read(notesControllerProvider.notifier).deleteNote(note.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (note.audioPath != null)
                     const Icon(Icons.graphic_eq, color: Colors.deepPurpleAccent, size: 16),
                  Text(
                    DateFormat('MMM d, h:mm a').format(note.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12, 
                      color: Colors.white38
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    children: note.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    )).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
