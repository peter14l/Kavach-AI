import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  final String documentPath;
  
  const ReviewScreen({super.key, required this.documentPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Export'),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              // Export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting securely...')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Export Secure PDF'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Original Document View (Left)
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.blueGrey.shade800,
                    child: const Text('Original Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'PDF Viewer Placeholder\n(Requires pdfx to render bytes)', 
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const VerticalDivider(width: 1, thickness: 1),

          // Redacted/Processed View (Right)
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.green.shade800,
                    child: const Text('Redacted Output', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      child: const SelectableText(
                        'SUMMARY:\n'
                        'This document outlines a legal dispute regarding [REDACTED] operating in [REDACTED].\n\n'
                        'KEY ENTITIES:\n'
                        '- Plaintiff: [REDACTED]\n'
                        '- Defendant: [REDACTED]\n\n'
                        'The core argument presented is that the defendant failed to provide adequate notice under section 4.2 of the agreement signed on [REDACTED].',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
