import 'package:flutter/material.dart';
import 'services/music_progress_service.dart';

/// Test file to demonstrate music tracking functionality
/// This can be used to test the MusicProgressService independently
class MusicTrackingTest extends StatefulWidget {
  const MusicTrackingTest({super.key});

  @override
  State<MusicTrackingTest> createState() => _MusicTrackingTestState();
}

class _MusicTrackingTestState extends State<MusicTrackingTest> {
  final MusicProgressService _progressService = MusicProgressService();
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    // Set up alert callback for testing
    _progressService.onShowAlert = (message) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    };
  }

  @override
  void dispose() {
    _progressService.stopTracking();
    super.dispose();
  }

  void _startTracking() {
    _progressService.startTracking(
      musicId: 'test_music_track',
      totalDuration: const Duration(minutes: 3, seconds: 45),
    );
    setState(() {
      _isTracking = true;
    });
  }

  void _stopTracking() {
    _progressService.stopTracking();
    setState(() {
      _isTracking = false;
    });
  }

  void _simulatePlay() {
    _progressService.updatePlayState(true);
  }

  void _simulatePause() {
    _progressService.updatePlayState(false);
  }

  void _simulateSeek() {
    _progressService.onSeek(const Duration(minutes: 1, seconds: 30));
  }

  void _simulateProgress() {
    _progressService.updatePosition(const Duration(minutes: 2, seconds: 15));
  }

  void _printStatus() {
    _progressService.printProgressStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Tracking Test'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Music Progress Tracking Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'This test demonstrates the music tracking functionality that logs progress every 5 seconds.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isTracking ? _stopTracking : _startTracking,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTracking ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
            ),
            const SizedBox(height: 20),
            if (_isTracking) ...[
              const Text(
                'Simulate Music Events:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _simulatePlay,
                      child: const Text('▶️ Play'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _simulatePause,
                      child: const Text('⏸️ Pause'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _simulateSeek,
                      child: const Text('⏩ Seek'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _simulateProgress,
                      child: const Text('📈 Progress'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _printStatus,
                child: const Text('📊 Print Status'),
              ),
            ],
            const SizedBox(height: 30),
            const Text(
              'Check the console/debug output for detailed tracking logs every 5 seconds.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Features being tracked:\n'
              '• Play/Pause state\n'
              '• Current position and duration\n'
              '• Seek operations (with backward seek detection)\n'
              '• Volume and playback rate changes\n'
              '• Progress percentage\n'
              '• Console logging every 5 seconds\n'
              '• Backend progress updates every 30 seconds',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
