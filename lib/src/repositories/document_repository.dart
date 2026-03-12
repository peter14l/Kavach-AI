import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_repository.freezed.dart';
part 'document_repository.g.dart';

@freezed
class DocumentMetadata with _$DocumentMetadata {
  const factory DocumentMetadata({
    required String id,
    required String fileName,
    required DateTime timestamp,
    required String actionType,
    required Duration duration,
    String? summary,
    String? redactedPath,
  }) = _DocumentMetadata;

  factory DocumentMetadata.fromJson(Map<String, dynamic> json) =>
      _$DocumentMetadataFromJson(json);
}

abstract class DocumentRepository {
  Future<List<DocumentMetadata>> getRecentDocuments();
  Future<void> saveDocument(DocumentMetadata metadata);
  Stream<String> processDocument(String path, String systemPrompt);
}
