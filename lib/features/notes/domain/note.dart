import 'package:isar/isar.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  late String content;

  late DateTime createdAt;

  List<String> tags = [];

  String? audioPath;

  bool isSummarized = false;
}
