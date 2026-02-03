import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_notes/core/database/storage_service.dart';
import 'package:vibe_notes/features/notes/domain/note.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final notesControllerProvider = StateNotifierProvider<NotesController, AsyncValue<List<Note>>>((ref) {
  return NotesController(ref);
});

class NotesController extends StateNotifier<AsyncValue<List<Note>>> {
  final Ref _ref;

  NotesController(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final storage = _ref.read(storageServiceProvider);
      final notes = await storage.getAllNotes();
      state = AsyncValue.data(notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addNote(String content, {String? audioPath}) async {
    final storage = _ref.read(storageServiceProvider);
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      createdAt: DateTime.now(),
      audioPath: audioPath,
    );
    
    await storage.saveNote(note);
    await refresh();
  }

  Future<void> deleteNote(String id) async {
    final storage = _ref.read(storageServiceProvider);
    await storage.deleteNote(id);
    await refresh();
  }
}
