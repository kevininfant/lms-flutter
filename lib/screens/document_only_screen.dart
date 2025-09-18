import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/scorm/scorm_bloc.dart';
import '../blocs/scorm/scorm_event.dart';
import '../blocs/scorm/scorm_state.dart';
import '../models/scorm.dart';
import '../widgets/scorm_card.dart';
import 'document_viewer_screen.dart';

class DocumentOnlyScreen extends StatefulWidget {
  const DocumentOnlyScreen({super.key});

  @override
  State<DocumentOnlyScreen> createState() => _DocumentOnlyScreenState();
}

class _DocumentOnlyScreenState extends State<DocumentOnlyScreen> {
  @override
  void initState() {
    super.initState();
    // Load document data when screen initializes
    context.read<ScormBloc>().add(LoadDocuments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<ScormBloc, ScormState>(
        builder: (context, state) {
          if (state is DocumentsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ScormError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading documents',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ScormBloc>().add(LoadDocuments());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is DocumentsLoaded) {
            if (state.documents.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No documents available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: state.documents.length,
                itemBuilder: (context, index) {
                  final document = state.documents[index];
                  return DocumentCard(
                    document: document,
                    onTap: () {
                      _navigateToDocumentDetails(context, document);
                    },
                  );
                },
              ),
            );
          }
          return const Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }

  void _navigateToDocumentDetails(BuildContext context, Document document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(document: document),
      ),
    );
  }
}

class DocumentDetailsScreen extends StatelessWidget {
  final Document document;

  const DocumentDetailsScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.docName),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', document.docName),
            _buildDetailRow('Type', document.type),
            _buildDetailRow('File Path', document.filePath),
            _buildDetailRow('Description', document.description),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Document viewer would be launched here'),
                    ),
                  );
                },
                child: const Text('Open Document'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
