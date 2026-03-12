import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/demo_mode_provider.dart';
import '../../../repositories/document_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemoMode = ref.watch(isDemoModeProvider);
    final repo = ref.watch(documentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aegis-Vault — The Vault'),
        actions: [
          Row(
            children: [
              const Text('Demo Mode'),
              Switch(
                value: isDemoMode,
                onChanged: (val) => ref.read(isDemoModeProvider.notifier).state = val,
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Sidebar / Recent Files
          SizedBox(
            width: 300,
            child: FutureBuilder<List<DocumentMetadata>>(
              future: repo.getRecentDocuments(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return ListTile(
                      title: Text(doc.fileName),
                      subtitle: Text('${doc.actionType} • ${doc.duration.inSeconds}s'),
                      onTap: () {
                        // Open review screen
                      },
                    );
                  },
                );
              },
            ),
          ),
          const VerticalDivider(),
          // Main Content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upload_file, size: 80, color: Colors.blueGrey),
                const SizedBox(height: 24),
                const Text(
                  'Drag and drop document here',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('PDF or DOCX (max 100MB)'),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Pick file
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Select Document'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(height: 48),
                const _StatsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatCard(label: 'Hours Saved', value: '124'),
        _StatCard(label: 'Files Processed', value: '45'),
        _StatCard(label: 'Compliance Status', value: '100%'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
