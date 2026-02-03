import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:vibe_notes/features/notes/domain/note.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [NoteSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> saveNote(Note note) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
  }

  Future<List<Note>> getAllNotes() async {
    final isar = await db;
    return await isar.notes.where().sortByCreatedAtDesc().findAll();
  }
  
  Future<void> deleteNote(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.notes.delete(id);
    });
  }
}
