import 'dart:convert';

class Note {
  final String id;
  String content;
  DateTime createdAt;
  List<String> tags;
  String? audioPath;
  bool isSummarized;

  Note({
    required this.id,
    required this.content,
    required this.createdAt,
    this.tags = const [],
    this.audioPath,
    this.isSummarized = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'tags': tags,
    'audioPath': audioPath,
    'isSummarized': isSummarized,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    tags: List<String>.from(json['tags'] ?? []),
    audioPath: json['audioPath'] as String?,
    isSummarized: json['isSummarized'] as bool? ?? false,
  );
}
