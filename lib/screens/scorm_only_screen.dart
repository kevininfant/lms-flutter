import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/scorm/scorm_bloc.dart';
import '../blocs/scorm/scorm_event.dart';
import '../blocs/scorm/scorm_state.dart';
import '../models/scorm.dart';
import '../widgets/scorm_card.dart';
import 'scorm_player_screen.dart';
import '../utils/scorm_test.dart';

class ScormOnlyScreen extends StatefulWidget {
  const ScormOnlyScreen({super.key});

  @override
  State<ScormOnlyScreen> createState() => _ScormOnlyScreenState();
}

class _ScormOnlyScreenState extends State<ScormOnlyScreen> {
  @override
  void initState() {
    super.initState();
    // Load SCORM data when screen initializes
    context.read<ScormBloc>().add(LoadScormData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('SCORM Packages'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Testing SCORM files... Check console for results'),
                ),
              );
              await ScormTest.testAllScormFiles();
            },
            tooltip: 'Test SCORM Files',
          ),
        ],
      ),
      body: BlocBuilder<ScormBloc, ScormState>(
        builder: (context, state) {
          if (state is ScormLoading) {
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
                    'Error loading SCORM packages',
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
                      context.read<ScormBloc>().add(LoadScormData());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is ScormLoaded) {
            if (state.scorms.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No SCORM packages available',
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
                itemCount: state.scorms.length,
                itemBuilder: (context, index) {
                  final scorm = state.scorms[index];
                  return ScormCard(
                    scorm: scorm,
                    onTap: () {
                      _navigateToScormDetails(context, scorm);
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

  void _navigateToScormDetails(BuildContext context, Scorm scorm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScormPlayerScreen(scorm: scorm),
      ),
    );
  }
}

class ScormDetailsScreen extends StatelessWidget {
  final Scorm scorm;

  const ScormDetailsScreen({super.key, required this.scorm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scorm.scormName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SCORM Package Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', scorm.scormName),
            if (scorm.courseName != null)
              _buildDetailRow('Course', scorm.courseName!),
            _buildDetailRow('File Link', scorm.scormFileLink),
            _buildDetailRow('Description', scorm.description),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SCORM package would be launched here'),
                    ),
                  );
                },
                child: const Text('Launch SCORM Package'),
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
