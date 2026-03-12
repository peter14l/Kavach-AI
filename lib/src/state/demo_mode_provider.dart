import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/document_repository.dart';
import '../repositories/mock_data_repository.dart';
import '../repositories/local_database_repository.dart';
import 'package:isar/isar.dart';

// State to track if we are in Demo Mode
final isDemoModeProvider = StateProvider<bool>((ref) => false);

// Provider for Isar instance (must be initialized at startup)
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar must be initialized and overridden in ProviderScope');
});

// The dynamic repository provider that switches based on isDemoMode
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final isDemo = ref.watch(isDemoModeProvider);
  if (isDemo) {
    return MockDataRepository();
  } else {
    final isar = ref.watch(isarProvider);
    return LocalDatabaseRepository(isar);
  }
});
