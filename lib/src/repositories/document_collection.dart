import 'package:isar/isar.dart';

part 'document_collection.g.dart';

@collection
class DocumentCollection {
  Id id = Isar.autoIncrement;
  
  late String fileName;
  late DateTime timestamp;
  late String actionType;
  late int durationMs;
  String? summary;
  String? redactedPath;
}
