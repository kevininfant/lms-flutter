import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class VideoProgressService {
  static final VideoProgressService _instance =
      VideoProgressService._internal();
  factory VideoProgressService() => _instance;
  VideoProgressService._internal();

  // Progress tracking variables
  Timer? _progressTimer;
  Timer? _consoleLogTimer;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Duration _lastTrackedPosition = Duration.zero;
  Duration _maxWatchedPosition =
      Duration.zero; // Track the furthest point watched
  String? _currentVideoId;
  bool _isPlaying = false;
  bool _isSeeking = false;
  DateTime? _lastSeekTime;
  String _loadingStatus = 'Not loaded';

  // Configuration
  static const Duration _trackingInterval = Duration(seconds: 30);
  static const Duration _seekThreshold = Duration(seconds: 5);
  static const Duration _consoleLogInterval = Duration(seconds: 5);

  // Callback for showing alerts
  Function(String message)? onShowAlert;

  // Backend configuration
  static const String _baseUrl =
      'https://httpbin.org'; // Using httpbin.org for testing - replace with your actual backend URL
  static const String _progressEndpoint = '/post';

  /// Start tracking video progress
  void startTracking({
    required String videoId,
    required Duration totalDuration,
    Duration? initialPosition,
  }) {
    debugPrint('🎬 Starting video progress tracking for: $videoId');

    _currentVideoId = videoId;
    _totalDuration = totalDuration;
    _currentPosition = initialPosition ?? Duration.zero;
    _lastTrackedPosition = _currentPosition;
    _maxWatchedPosition = _currentPosition; // Reset max watched position
    _isPlaying = true;
    _isSeeking = false;

    // Stop any existing timer
    _stopTracking();

    // Start new timer
    _progressTimer = Timer.periodic(_trackingInterval, (_) {
      _trackProgress();
    });

    // Start console logging timer
    _startConsoleLogging();

    // Send initial progress
    _sendProgressToBackend();
  }

  /// Stop tracking video progress
  void stopTracking() {
    debugPrint('⏹️ Stopping video progress tracking');
    _stopTracking();
    _stopConsoleLogging();
    _isPlaying = false;
  }

  /// Update current video position
  void updatePosition(Duration position) {
    if (_isSeeking) return; // Don't update during seeking

    _currentPosition = position;

    // Update max watched position if we're playing forward
    if (_isPlaying && position > _maxWatchedPosition) {
      _maxWatchedPosition = position;
    }

    // Check if this is a seek operation
    final timeSinceLastSeek = _lastSeekTime != null
        ? DateTime.now().difference(_lastSeekTime!)
        : Duration.zero;

    if (timeSinceLastSeek < _seekThreshold) {
      _isSeeking = true;
      debugPrint('🔄 Seek detected, pausing position updates');
    }
  }

  /// Handle seek operation
  void onSeek(Duration newPosition) {
    debugPrint('⏩ Seek to: ${_formatDuration(newPosition)}');

    _isSeeking = true;
    _lastSeekTime = DateTime.now();
    _currentPosition = newPosition;

    // Check if this is a backward seek (new position is less than last tracked position)
    final bool isBackwardSeek = newPosition < _lastTrackedPosition;
    final bool isSeekingToWatchedContent = newPosition <= _maxWatchedPosition;

    // Show alert if seeking to already watched content
    if (isSeekingToWatchedContent && _maxWatchedPosition > Duration.zero) {
      final watchedTime = _formatDuration(_maxWatchedPosition);
      final seekTime = _formatDuration(newPosition);
      final message =
          'You are seeking to $seekTime, but you have already watched up to $watchedTime.';

      debugPrint('⚠️ $message');
      onShowAlert?.call(message);
    }

    if (isBackwardSeek) {
      debugPrint(
        '⬅️ Backward seek detected - resetting tracking from new position',
      );
      // For backward seek, reset tracking from the new position
      _lastTrackedPosition = newPosition;
    } else {
      debugPrint('➡️ Forward seek detected - continuing from new position');
      // For forward seek, just update the last tracked position
      _lastTrackedPosition = newPosition;
    }

    // Send immediate progress update for seek
    _sendProgressToBackend();

    // Resume normal tracking after seek threshold
    Timer(_seekThreshold, () {
      _isSeeking = false;
      debugPrint(
        '✅ Seek completed, resuming normal tracking from: ${_formatDuration(newPosition)}',
      );
    });
  }

  /// Update play/pause state
  void updatePlayState(bool isPlaying) {
    _isPlaying = isPlaying;
    debugPrint(
      '${isPlaying ? '▶️' : '⏸️'} Video ${isPlaying ? 'playing' : 'paused'}',
    );

    if (isPlaying) {
      // Resume tracking if not already running
      if (_progressTimer == null || !_progressTimer!.isActive) {
        _progressTimer = Timer.periodic(_trackingInterval, (_) {
          _trackProgress();
        });
      }
    } else {
      // Pause tracking
      _stopTracking();
    }
  }

  /// Update total duration
  void updateTotalDuration(Duration duration) {
    _totalDuration = duration;
    _loadingStatus = 'Loaded';
    debugPrint('📏 Total duration updated: ${_formatDuration(duration)}');
  }

  /// Update loading status
  void updateLoadingStatus(String status) {
    _loadingStatus = status;
    debugPrint('📥 Loading status: $status');
  }

  /// Track progress and send to backend
  void _trackProgress() {
    if (!_isPlaying || _isSeeking || _currentVideoId == null) return;

    final progressSinceLastTrack = _currentPosition - _lastTrackedPosition;

    // Only track if we've made meaningful progress (at least 30 seconds)
    if (progressSinceLastTrack.inSeconds >= 30) {
      debugPrint(
        '📊 Tracking progress: ${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
      );
      debugPrint(
        '📈 Progress since last track: ${_formatDuration(progressSinceLastTrack)}',
      );
      _lastTrackedPosition = _currentPosition;
      _sendProgressToBackend();
    } else {
      debugPrint(
        '⏳ Progress too small to track: ${_formatDuration(progressSinceLastTrack)} (need 30s)',
      );
    }
  }

  /// Start console logging timer
  void _startConsoleLogging() {
    _stopConsoleLogging(); // Stop any existing timer

    _consoleLogTimer = Timer.periodic(_consoleLogInterval, (_) {
      _logConsoleData();
    });

    debugPrint('🖥️ Started console logging every 5 seconds');
  }

  /// Stop console logging timer
  void _stopConsoleLogging() {
    _consoleLogTimer?.cancel();
    _consoleLogTimer = null;
  }

  /// Log console data every 5 seconds
  void _logConsoleData() {
    if (_currentVideoId == null) return;

    final currentTime = DateTime.now();
    final progressPercentage = _totalDuration.inSeconds > 0
        ? (_currentPosition.inSeconds / _totalDuration.inSeconds * 100).round()
        : 0;

    // Console log data
    final consoleData = {
      'timestamp': currentTime.toIso8601String(),
      'videoId': _currentVideoId,
      'videoName': _currentVideoId?.replaceAll('_', ' ') ?? 'Unknown Video',
      'currentPosition': _formatDuration(_currentPosition),
      'totalDuration': _formatDuration(_totalDuration),
      'progressPercentage': '$progressPercentage%',
      'isPlaying': _isPlaying,
      'isSeeking': _isSeeking,
      'loadingStatus': _loadingStatus,
      'bufferedSeconds': _calculateBufferedSeconds(),
      'playbackRate': _isPlaying ? '1.0x' : '0.0x',
    };

    // Print detailed console log
    debugPrint('🎬 ===== VIDEO CONSOLE DATA (Every 5s) =====');
    debugPrint('⏰ Time: ${consoleData['timestamp']}');
    debugPrint('📹 Video: ${consoleData['videoName']}');
    debugPrint(
      '⏱️ Position: ${consoleData['currentPosition']} / ${consoleData['totalDuration']}',
    );
    debugPrint('📊 Progress: ${consoleData['progressPercentage']}');
    debugPrint('▶️ Status: ${_isPlaying ? 'Playing' : 'Paused'}');
    debugPrint('📥 Loading: ${consoleData['loadingStatus']}');
    debugPrint('🔄 Seeking: ${_isSeeking ? 'Yes' : 'No'}');
    debugPrint('💾 Buffered: ${consoleData['bufferedSeconds']}');
    debugPrint('⚡ Rate: ${consoleData['playbackRate']}');
    debugPrint('==========================================');
  }

  /// Calculate buffered seconds (simplified)
  String _calculateBufferedSeconds() {
    // This is a simplified calculation - in a real implementation,
    // you would get this from the video element's buffered ranges
    if (_isPlaying && _currentPosition.inSeconds > 0) {
      final buffered =
          _currentPosition.inSeconds + 10; // Assume 10 seconds ahead
      return '${buffered}s';
    }
    return '0s';
  }

  /// Send progress data to backend
  Future<void> _sendProgressToBackend() async {
    if (_currentVideoId == null) return;

    try {
      final progressData = {
        'videoId': _currentVideoId,
        'currentPosition': _currentPosition.inSeconds,
        'totalDuration': _totalDuration.inSeconds,
        'progressPercentage': _totalDuration.inSeconds > 0
            ? (_currentPosition.inSeconds / _totalDuration.inSeconds * 100)
                  .round()
            : 0,
        'timestamp': DateTime.now().toIso8601String(),
        'isSeeking': _isSeeking,
        'isPlaying': _isPlaying,
        'lastTrackedPosition': _lastTrackedPosition.inSeconds,
        'seekDirection': _currentPosition < _lastTrackedPosition
            ? 'backward'
            : 'forward',
      };

      debugPrint('📤 Sending progress to backend: ${jsonEncode(progressData)}');

      final response = await http.post(
        Uri.parse('$_baseUrl$_progressEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(progressData),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Progress sent successfully');
      } else {
        debugPrint(
          '❌ Failed to send progress: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending progress to backend: $e');
    }
  }

  /// Stop the progress tracking timer
  void _stopTracking() {
    _progressTimer?.cancel();
    _progressTimer = null;
    _stopConsoleLogging();
  }

  /// Format duration for logging
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get current progress information
  Map<String, dynamic> getCurrentProgress() {
    return {
      'videoId': _currentVideoId,
      'currentPosition': _currentPosition.inSeconds,
      'totalDuration': _totalDuration.inSeconds,
      'progressPercentage': _totalDuration.inSeconds > 0
          ? (_currentPosition.inSeconds / _totalDuration.inSeconds * 100)
                .round()
          : 0,
      'isPlaying': _isPlaying,
      'isSeeking': _isSeeking,
      'lastTrackedPosition': _lastTrackedPosition.inSeconds,
      'maxWatchedPosition': _maxWatchedPosition.inSeconds,
      'progressSinceLastTrack':
          (_currentPosition - _lastTrackedPosition).inSeconds,
      'formattedCurrentPosition': _formatDuration(_currentPosition),
      'formattedTotalDuration': _formatDuration(_totalDuration),
      'formattedLastTrackedPosition': _formatDuration(_lastTrackedPosition),
      'formattedMaxWatchedPosition': _formatDuration(_maxWatchedPosition),
    };
  }

  /// Print current progress status for debugging
  void printProgressStatus() {
    final progress = getCurrentProgress();
    debugPrint('🎬 === VIDEO PROGRESS STATUS ===');
    debugPrint('📹 Video ID: ${progress['videoId']}');
    debugPrint('⏱️ Current Position: ${progress['formattedCurrentPosition']}');
    debugPrint('📏 Total Duration: ${progress['formattedTotalDuration']}');
    debugPrint('📊 Progress: ${progress['progressPercentage']}%');
    debugPrint('📍 Last Tracked: ${progress['formattedLastTrackedPosition']}');
    debugPrint('🎯 Max Watched: ${progress['formattedMaxWatchedPosition']}');
    debugPrint('📈 Since Last Track: ${progress['progressSinceLastTrack']}s');
    debugPrint('▶️ Playing: ${progress['isPlaying']}');
    debugPrint('🔄 Seeking: ${progress['isSeeking']}');
    debugPrint('===============================');
  }

  /// Dispose resources
  void dispose() {
    _stopTracking();
    _stopConsoleLogging();
    _currentVideoId = null;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    _lastTrackedPosition = Duration.zero;
    _maxWatchedPosition = Duration.zero;
    _isPlaying = false;
    _isSeeking = false;
    _lastSeekTime = null;
    _loadingStatus = 'Not loaded';
  }
}
