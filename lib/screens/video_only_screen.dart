import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/scorm/scorm_bloc.dart';
import '../blocs/scorm/scorm_event.dart';
import '../blocs/scorm/scorm_state.dart';
import '../models/scorm.dart';
import '../widgets/scorm_card.dart';
import 'video_player_screen.dart';

class VideoOnlyScreen extends StatefulWidget {
  const VideoOnlyScreen({super.key});

  @override
  State<VideoOnlyScreen> createState() => _VideoOnlyScreenState();
}

class _VideoOnlyScreenState extends State<VideoOnlyScreen> {
  @override
  void initState() {
    super.initState();
    // Load video data when screen initializes
    context.read<ScormBloc>().add(LoadVideos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Video Content'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<ScormBloc, ScormState>(
        builder: (context, state) {
          if (state is VideoLoading) {
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
                    'Error loading videos',
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
                      context.read<ScormBloc>().add(LoadVideos());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is VideosLoaded) {
            if (state.videos.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No videos available',
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
                itemCount: state.videos.length,
                itemBuilder: (context, index) {
                  final video = state.videos[index];
                  return VideoCard(
                    video: video,
                    onTap: () {
                      _navigateToVideoDetails(context, video);
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

  void _navigateToVideoDetails(BuildContext context, Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(video: video),
      ),
    );
  }
}

class VideoDetailsScreen extends StatelessWidget {
  final Video video;

  const VideoDetailsScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(video.videoName),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Video Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', video.videoName),
            _buildDetailRow('Type', video.type),
            _buildDetailRow('URL', video.videoUrl),
            _buildDetailRow('Description', video.description),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Video player would be launched here'),
                    ),
                  );
                },
                child: const Text('Play Video'),
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
