import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/features/dashboard/presentation/dashboard_screen.dart';
import 'src/state/demo_mode_provider.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'src/repositories/document_collection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar (mocking the directory for now since we can't run tests easily)
  // In a real app, we'd use getApplicationDocumentsDirectory()
  // final dir = await getApplicationDocumentsDirectory();
  // final isar = await Isar.open([DocumentCollectionSchema], directory: dir.path);

  runApp(
    ProviderScope(
      overrides: [
        // isarProvider.overrideWithValue(isar),
      ],
      child: const AegisVaultApp(),
    ),
  );
}

class AegisVaultApp extends StatelessWidget {
  const AegisVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis-Vault',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
