import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_notes/core/database/storage_service.dart';
import 'package:vibe_notes/features/notes/domain/note.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final notesListProvider = StateProvider<List<Note>>((ref) => []);
final notesLoadingProvider = StateProvider<bool>((ref) => true);
final categoryFilterProvider = StateProvider<NoteCategory?>((ref) => null);

class NotesController {
  final Ref _ref;
  
  NotesController(this._ref);

  Future<void> loadNotes() async {
    _ref.read(notesLoadingProvider.notifier).state = true;
    try {
      final storage = _ref.read(storageServiceProvider);
      final notes = await storage.getAllNotes();
      _ref.read(notesListProvider.notifier).state = notes;
    } finally {
      _ref.read(notesLoadingProvider.notifier).state = false;
    }
  }

  Future<void> addNote(String content, {String? audioPath, NoteCategory category = NoteCategory.other}) async {
    final storage = _ref.read(storageServiceProvider);
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      createdAt: DateTime.now(),
      audioPath: audioPath,
      category: category,
    );
    
    await storage.saveNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    final storage = _ref.read(storageServiceProvider);
    await storage.deleteNote(id);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    final storage = _ref.read(storageServiceProvider);
    await storage.saveNote(note);
    await loadNotes();
  }
}

final notesControllerProvider = Provider<NotesController>((ref) {
  return NotesController(ref);
});
