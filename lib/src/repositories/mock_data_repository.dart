import 'dart:async';
import 'document_repository.dart';

class MockDataRepository implements DocumentRepository {
  @override
  Future<List<DocumentMetadata>> getRecentDocuments() async {
    return [
      DocumentMetadata(
        id: '1',
        fileName: 'Acme_vs_State_Legal_Brief.pdf',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        actionType: 'Legal Redaction',
        duration: const Duration(seconds: 45),
        summary: 'Key Arguments: Defendant argues lack of jurisdiction. Plaintiff claims systemic negligence.',
      ),
      DocumentMetadata(
        id: '2',
        fileName: 'CA_Financial_Audit_2025.docx',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        actionType: 'Financial Summary',
        duration: const Duration(seconds: 30),
        summary: 'Audit reveals 15% discrepancy in tax filings between Q1 and Q2.',
      ),
    ];
  }

  @override
  Future<void> saveDocument(DocumentMetadata metadata) async {
    // In demo mode, we don't save anything permanently.
    return;
  }

  @override
  Stream<String> processDocument(String path, String systemPrompt) async* {
    final response = [
      'Initializing local LLM...',
      'Analyzing document structure...',
      'Identifying sensitive entities (PII)...',
      'Applying legal system prompt...',
      'Generating summary: This case involves a complex dispute regarding...',
      'Redacting names and addresses...',
      '[MOCK] Processing complete.',
    ];

    for (final step in response) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield step;
    }
  }
}
