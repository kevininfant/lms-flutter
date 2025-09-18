import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/scorm/scorm_bloc.dart';
import '../blocs/scorm/scorm_event.dart';
import '../blocs/scorm/scorm_state.dart';
import '../models/scorm.dart';
import '../widgets/scorm_card.dart';
import 'h5p_player_screen.dart';

class H5POnlyScreen extends StatefulWidget {
  const H5POnlyScreen({super.key});

  @override
  State<H5POnlyScreen> createState() => _H5POnlyScreenState();
}

class _H5POnlyScreenState extends State<H5POnlyScreen> {
  @override
  void initState() {
    super.initState();
    // Load H5P data when screen initializes
    context.read<ScormBloc>().add(LoadH5P());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('H5P Interactive Content'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<ScormBloc, ScormState>(
        builder: (context, state) {
          if (state is H5PLoading) {
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
                    'Error loading H5P content',
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
                      context.read<ScormBloc>().add(LoadH5P());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is H5PLoaded) {
            if (state.h5p.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No H5P content available',
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
                itemCount: state.h5p.length,
                itemBuilder: (context, index) {
                  final h5p = state.h5p[index];
                  return H5PCard(
                    h5p: h5p,
                    onTap: () {
                      _navigateToH5PDetails(context, h5p);
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

  void _navigateToH5PDetails(BuildContext context, H5P h5p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => H5POnlinePlayerScreen(h5p: h5p),
      ),
    );
  }
}

class H5PDetailsScreen extends StatelessWidget {
  final H5P h5p;

  const H5PDetailsScreen({super.key, required this.h5p});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(h5p.h5pName),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'H5P Interactive Content',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', h5p.h5pName),
            _buildDetailRow('Type', h5p.type),
            _buildDetailRow('File', h5p.h5pFile),
            _buildDetailRow('Description', h5p.description),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('H5P content would be launched here'),
                    ),
                  );
                },
                child: const Text('Launch H5P Content'),
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
