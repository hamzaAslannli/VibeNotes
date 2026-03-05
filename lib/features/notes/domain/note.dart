import 'dart:convert';

enum NoteCategory {
  work,      // 💼 Blue
  personal,  // 💜 Purple  
  ideas,     // 💡 Yellow
  meetings,  // 📅 Green
  other,     // ⚪ Gray
}

extension NoteCategoryExtension on NoteCategory {
  String get displayName {
    switch (this) {
      case NoteCategory.work: return 'Work';
      case NoteCategory.personal: return 'Personal';
      case NoteCategory.ideas: return 'Ideas';
      case NoteCategory.meetings: return 'Meetings';
      case NoteCategory.other: return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case NoteCategory.work: return '💼';
      case NoteCategory.personal: return '💜';
      case NoteCategory.ideas: return '💡';
      case NoteCategory.meetings: return '📅';
      case NoteCategory.other: return '📝';
    }
  }

  int get colorValue {
    switch (this) {
      case NoteCategory.work: return 0xFF2196F3;      // Blue
      case NoteCategory.personal: return 0xFF9C27B0;  // Purple
      case NoteCategory.ideas: return 0xFFFFEB3B;     // Yellow
      case NoteCategory.meetings: return 0xFF4CAF50;  // Green
      case NoteCategory.other: return 0xFF9E9E9E;     // Gray
    }
  }

  static NoteCategory fromString(String? name) {
    switch (name?.toLowerCase()) {
      case 'work': return NoteCategory.work;
      case 'personal': return NoteCategory.personal;
      case 'ideas': return NoteCategory.ideas;
      case 'meetings': return NoteCategory.meetings;
      default: return NoteCategory.other;
    }
  }
}

class Note {
  final String id;
  String content;
  DateTime createdAt;
  List<String> tags;
  String? audioPath;
  bool isSummarized;
  NoteCategory category;
  String? transcript;     // AI transcription of audio
  String? summary;        // AI-generated summary
  List<String> keywords;  // AI-extracted keywords
  String? actionItems;    // AI-generated action items
  String? expandedIdea;   // AI-expanded idea

  Note({
    required this.id,
    required this.content,
    required this.createdAt,
    this.tags = const [],
    this.audioPath,
    this.isSummarized = false,
    this.category = NoteCategory.other,
    this.transcript,
    this.summary,
    this.keywords = const [],
    this.actionItems,
    this.expandedIdea,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'tags': tags,
    'audioPath': audioPath,
    'isSummarized': isSummarized,
    'category': category.index,
    'transcript': transcript,
    'summary': summary,
    'keywords': keywords,
    'actionItems': actionItems,
    'expandedIdea': expandedIdea,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    tags: List<String>.from(json['tags'] ?? []),
    audioPath: json['audioPath'] as String?,
    isSummarized: json['isSummarized'] as bool? ?? false,
    category: NoteCategory.values[json['category'] as int? ?? 4],
    transcript: json['transcript'] as String?,
    summary: json['summary'] as String?,
    keywords: List<String>.from(json['keywords'] ?? []),
    actionItems: json['actionItems'] as String?,
    expandedIdea: json['expandedIdea'] as String?,
  );
}
