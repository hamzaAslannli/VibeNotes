import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_notes/core/database/isar_service.dart';
import 'package:vibe_notes/features/notes/domain/note.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final notesProvider = FutureProvider<List<Note>>((ref) async {
  final isarService = ref.watch(isarServiceProvider);
  return await isarService.getAllNotes();
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
      final isarService = _ref.read(isarServiceProvider);
      final notes = await isarService.getAllNotes();
      state = AsyncValue.data(notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addNote(String content, {String? audioPath}) async {
    final isarService = _ref.read(isarServiceProvider);
    final note = Note()
      ..content = content
      ..createdAt = DateTime.now()
      ..audioPath = audioPath;
    
    await isarService.saveNote(note);
    await refresh();
  }

  Future<void> deleteNote(int id) async {
    final isarService = _ref.read(isarServiceProvider);
    await isarService.deleteNote(id);
    await refresh();
  }
}
