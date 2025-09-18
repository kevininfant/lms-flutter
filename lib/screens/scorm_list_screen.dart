import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/scorm/scorm_bloc.dart';
import '../blocs/scorm/scorm_event.dart';
import '../blocs/scorm/scorm_state.dart';
import '../models/scorm.dart';
import '../widgets/scorm_card.dart';

class ScormListScreen extends StatefulWidget {
  const ScormListScreen({super.key});

  @override
  State<ScormListScreen> createState() => _ScormListScreenState();
}

class _ScormListScreenState extends State<ScormListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Load all course data when screen initializes
    context.read<ScormBloc>().add(LoadAllCourseData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Course Content'),
        backgroundColor: Colors.yellow.shade400,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'SCORM'),
            Tab(text: 'Videos'),
            Tab(text: 'Music'),
            Tab(text: 'H5P'),
            Tab(text: 'Documents'),
          ],
        ),
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
                    'Error loading content',
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
                      context.read<ScormBloc>().add(LoadAllCourseData());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is AllCourseDataLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildScormTab(state.courseData.scorms),
                _buildVideoTab(state.courseData.videos),
                _buildMusicTab(state.courseData.music),
                _buildH5PTab(state.courseData.h5p),
                _buildDocumentTab(state.courseData.docs),
              ],
            );
          }
          return const Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }

  Widget _buildScormTab(List<Scorm> scorms) {
    if (scorms.isEmpty) {
      return const Center(
        child: Text('No SCORM content available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: scorms.length,
        itemBuilder: (context, index) {
          final scorm = scorms[index];
          return ScormCard(
            scorm: scorm,
            onTap: () {
              _navigateToScormDetails(scorm);
            },
          );
        },
      ),
    );
  }

  Widget _buildVideoTab(List<Video> videos) {
    if (videos.isEmpty) {
      return const Center(
        child: Text('No video content available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return VideoCard(
            video: video,
            onTap: () {
              _navigateToVideoDetails(video);
            },
          );
        },
      ),
    );
  }

  Widget _buildMusicTab(List<Music> music) {
    if (music.isEmpty) {
      return const Center(
        child: Text('No music content available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: music.length,
        itemBuilder: (context, index) {
          final musicItem = music[index];
          return MusicCard(
            music: musicItem,
            onTap: () {
              _navigateToMusicDetails(musicItem);
            },
          );
        },
      ),
    );
  }

  Widget _buildH5PTab(List<H5P> h5p) {
    if (h5p.isEmpty) {
      return const Center(
        child: Text('No H5P content available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: h5p.length,
        itemBuilder: (context, index) {
          final h5pItem = h5p[index];
          return H5PCard(
            h5p: h5pItem,
            onTap: () {
              _navigateToH5PDetails(h5pItem);
            },
          );
        },
      ),
    );
  }

  Widget _buildDocumentTab(List<Document> documents) {
    if (documents.isEmpty) {
      return const Center(
        child: Text('No document content available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final document = documents[index];
          return DocumentCard(
            document: document,
            onTap: () {
              _navigateToDocumentDetails(document);
            },
          );
        },
      ),
    );
  }

  void _navigateToScormDetails(Scorm scorm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScormDetailsScreen(scorm: scorm),
      ),
    );
  }

  void _navigateToVideoDetails(Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoDetailsScreen(video: video),
      ),
    );
  }

  void _navigateToMusicDetails(Music music) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicDetailsScreen(music: music),
      ),
    );
  }

  void _navigateToH5PDetails(H5P h5p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => H5PDetailsScreen(h5p: h5p),
      ),
    );
  }

  void _navigateToDocumentDetails(Document document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentDetailsScreen(document: document),
      ),
    );
  }
}

// Placeholder detail screens - you can implement these based on your needs
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
