import 'package:flutter/material.dart';
import '../services/video_progress_service.dart';

class AlertDemoScreen extends StatefulWidget {
  const AlertDemoScreen({super.key});

  @override
  State<AlertDemoScreen> createState() => _AlertDemoScreenState();
}

class _AlertDemoScreenState extends State<AlertDemoScreen> {
  final VideoProgressService _progressService = VideoProgressService();
  String _status = 'Ready to test alerts';

  @override
  void initState() {
    super.initState();
    _setupProgressService();
  }

  void _setupProgressService() {
    // Set up alert callback
    _progressService.onShowAlert = (String message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    };

    // Start tracking with a 10-minute video
    _progressService.startTracking(
      videoId: 'demo_video',
      totalDuration: const Duration(minutes: 10),
    );
  }

  void _simulateWatching() {
    setState(() {
      _status = 'Simulating watching video...';
    });

    // Simulate watching for 5 minutes
    _progressService.updatePosition(const Duration(minutes: 5));
    _progressService.updatePlayState(true);

    setState(() {
      _status = 'Watched up to 5:00 minutes';
    });
  }

  void _simulateSeekToWatchedContent() {
    setState(() {
      _status = 'Seeking to 3:00 (already watched content)';
    });

    // Seek to 3 minutes (which is less than the 5 minutes we watched)
    _progressService.onSeek(const Duration(minutes: 3));
  }

  void _simulateSeekToNewContent() {
    setState(() {
      _status = 'Seeking to 7:00 (new content)';
    });

    // Seek to 7 minutes (which is more than the 5 minutes we watched)
    _progressService.onSeek(const Duration(minutes: 7));
  }

  void _showProgressStatus() {
    _progressService.printProgressStatus();
    setState(() {
      _status = 'Progress status printed to console';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Video Progress Alert Demo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This demo shows how the alert system works when users seek to already watched content.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Status: $_status',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _simulateWatching,
              child: const Text('1. Simulate Watching 5 Minutes'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _simulateSeekToWatchedContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('2. Seek to 3:00 (Should Show Alert)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _simulateSeekToNewContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('3. Seek to 7:00 (No Alert)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _showProgressStatus,
              child: const Text('4. Show Progress Status'),
            ),
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How it works:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Watch some video content (simulates watching up to 5:00)',
                    ),
                    Text(
                      '2. Seek backward to 3:00 → Shows alert (already watched)',
                    ),
                    Text('3. Seek forward to 7:00 → No alert (new content)'),
                    Text('4. Check console for detailed progress tracking'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressService.dispose();
    super.dispose();
  }
}
