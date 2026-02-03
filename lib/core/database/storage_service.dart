import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_notes/features/notes/domain/note.dart';

class StorageService {
  static const String _notesKey = 'vibe_notes_data';

  Future<List<Note>> getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_notesKey);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => Note.fromJson(j)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveNote(Note note) async {
    final notes = await getAllNotes();
    final existingIndex = notes.indexWhere((n) => n.id == note.id);
    if (existingIndex >= 0) {
      notes[existingIndex] = note;
    } else {
      notes.add(note);
    }
    await _saveAll(notes);
  }

  Future<void> deleteNote(String id) async {
    final notes = await getAllNotes();
    notes.removeWhere((n) => n.id == id);
    await _saveAll(notes);
  }

  Future<void> _saveAll(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_notesKey, jsonString);
  }
}
