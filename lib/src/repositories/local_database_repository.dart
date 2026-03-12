import 'package:isar/isar.dart';
import 'document_repository.dart';
import 'document_collection.dart';

class LocalDatabaseRepository implements DocumentRepository {
  final Isar isar;

  LocalDatabaseRepository(this.isar);

  @override
  Future<List<DocumentMetadata>> getRecentDocuments() async {
    final docs = await isar.documentCollections.where().sortByTimestampDesc().limit(10).findAll();
    return docs.map((d) => DocumentMetadata(
      id: d.id.toString(),
      fileName: d.fileName,
      timestamp: d.timestamp,
      actionType: d.actionType,
      duration: Duration(milliseconds: d.durationMs),
      summary: d.summary,
      redactedPath: d.redactedPath,
    )).toList();
  }

  @override
  Future<void> saveDocument(DocumentMetadata metadata) async {
    final doc = DocumentCollection()
      ..fileName = metadata.fileName
      ..timestamp = metadata.timestamp
      ..actionType = metadata.actionType
      ..durationMs = metadata.duration.inMilliseconds
      ..summary = metadata.summary
      ..redactedPath = metadata.redactedPath;

    await isar.writeTxn(() async {
      await isar.documentCollections.put(doc);
    });
  }

  @override
  Stream<String> processDocument(String path, String systemPrompt) async* {
    // This will be implemented by calling the Rust backend.
    // For now, it's a placeholder that throws or returns a basic message.
    yield 'Rust backend processing not yet connected.';
  }
}
