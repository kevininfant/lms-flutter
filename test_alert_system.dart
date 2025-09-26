import 'lib/services/video_progress_service.dart';

void main() {
  print('🎬 Testing Video Progress Alert System');
  print('=====================================\n');

  final progressService = VideoProgressService();

  // Set up alert callback
  progressService.onShowAlert = (String message) {
    print('🚨 ALERT: $message');
  };

  // Start tracking a 10-minute video
  print('1. Starting video tracking (10-minute video)...');
  progressService.startTracking(
    videoId: 'test_video',
    totalDuration: const Duration(minutes: 10),
  );

  // Simulate watching for 5 minutes
  print('\n2. Simulating watching video for 5 minutes...');
  progressService.updatePosition(const Duration(minutes: 5));
  progressService.updatePlayState(true);
  progressService.printProgressStatus();

  // Test seeking to already watched content (should show alert)
  print('\n3. Seeking to 3:00 (already watched content)...');
  progressService.onSeek(const Duration(minutes: 3));

  // Test seeking to new content (should not show alert)
  print('\n4. Seeking to 7:00 (new content)...');
  progressService.onSeek(const Duration(minutes: 7));

  // Test seeking to already watched content again
  print('\n5. Seeking to 2:00 (already watched content)...');
  progressService.onSeek(const Duration(minutes: 2));

  // Show final status
  print('\n6. Final progress status:');
  progressService.printProgressStatus();

  // Clean up
  progressService.dispose();

  print('\n✅ Test completed!');
  print('\nSummary:');
  print('- Alerts should have appeared when seeking to 3:00 and 2:00');
  print('- No alert should have appeared when seeking to 7:00');
  print('- The system tracks the maximum watched position (5:00)');
  print('- Seeking to any position ≤ 5:00 triggers an alert');
}
