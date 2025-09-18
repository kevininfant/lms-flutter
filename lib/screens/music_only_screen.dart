import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/scorm/scorm_bloc.dart';
import '../blocs/scorm/scorm_event.dart';
import '../blocs/scorm/scorm_state.dart';
import '../models/scorm.dart';
import '../widgets/scorm_card.dart';
import 'audio_player_screen.dart';

class MusicOnlyScreen extends StatefulWidget {
  const MusicOnlyScreen({super.key});

  @override
  State<MusicOnlyScreen> createState() => _MusicOnlyScreenState();
}

class _MusicOnlyScreenState extends State<MusicOnlyScreen> {
  @override
  void initState() {
    super.initState();
    // Load music data when screen initializes
    context.read<ScormBloc>().add(LoadMusic());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Music Content'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<ScormBloc, ScormState>(
        builder: (context, state) {
          if (state is MusicLoading) {
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
                    'Error loading music',
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
                      context.read<ScormBloc>().add(LoadMusic());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is MusicLoaded) {
            if (state.music.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.headphones_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No music available',
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
                itemCount: state.music.length,
                itemBuilder: (context, index) {
                  final music = state.music[index];
                  return MusicCard(
                    music: music,
                    onTap: () {
                      _navigateToMusicDetails(context, music);
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

  void _navigateToMusicDetails(BuildContext context, Music music) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(music: music),
      ),
    );
  }
}

class MusicDetailsScreen extends StatelessWidget {
  final Music music;

  const MusicDetailsScreen({super.key, required this.music});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(music.musicName),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Music Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', music.musicName),
            _buildDetailRow('Type', music.type),
            _buildDetailRow('URL', music.musicUrl),
            _buildDetailRow('Description', music.description),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Music player would be launched here'),
                    ),
                  );
                },
                child: const Text('Play Music'),
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
