import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DocumentProgressService {
  static final DocumentProgressService _instance =
      DocumentProgressService._internal();
  factory DocumentProgressService() => _instance;
  DocumentProgressService._internal();

  // Progress tracking variables
  Timer? _progressTimer;
  Timer? _consoleLogTimer;
  Duration _currentViewTime = Duration.zero;
  Duration _totalViewTime = Duration.zero;
  Duration _lastTrackedTime = Duration.zero;
  Duration _maxViewedTime = Duration.zero; // Track the furthest point viewed
  String? _currentDocumentId;
  bool _isViewing = false;
  bool _isScrolling = false;
  DateTime? _lastScrollTime;
  String _loadingStatus = 'Not loaded';
  int _currentPage = 1;
  int _totalPages = 1;
  double _scrollPosition = 0.0; // 0.0 to 1.0

  // Configuration
  static const Duration _trackingInterval = Duration(seconds: 30);
  static const Duration _scrollThreshold = Duration(seconds: 5);
  static const Duration _consoleLogInterval = Duration(seconds: 5);

  // Callback for showing alerts
  Function(String message)? onShowAlert;

  // Backend configuration
  static const String _baseUrl =
      'https://httpbin.org'; // Using httpbin.org for testing - replace with your actual backend URL
  static const String _progressEndpoint = '/post';

  /// Start tracking document progress
  void startTracking({
    required String documentId,
    required String documentName,
    int? totalPages,
    Duration? initialViewTime,
  }) {
    debugPrint('📄 Starting document progress tracking for: $documentId');

    _currentDocumentId = documentId;
    _totalPages = totalPages ?? 1;
    _currentViewTime = initialViewTime ?? Duration.zero;
    _lastTrackedTime = _currentViewTime;
    _maxViewedTime = _currentViewTime; // Reset max viewed time
    _isViewing = true;
    _isScrolling = false;
    _currentPage = 1;
    _scrollPosition = 0.0;

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

  /// Stop tracking document progress
  void stopTracking() {
    debugPrint('⏹️ Stopping document progress tracking');
    _stopTracking();
    _stopConsoleLogging();
    _isViewing = false;
  }

  /// Update current document view time
  void updateViewTime(Duration viewTime) {
    if (_isScrolling) return; // Don't update during scrolling

    _currentViewTime = viewTime;
    _totalViewTime =
        _totalViewTime + Duration(seconds: 1); // Increment total view time

    // Update max viewed time if we're viewing forward
    if (_isViewing && viewTime > _maxViewedTime) {
      _maxViewedTime = viewTime;
    }

    // Check if this is a scroll operation
    final timeSinceLastScroll = _lastScrollTime != null
        ? DateTime.now().difference(_lastScrollTime!)
        : Duration.zero;

    if (timeSinceLastScroll < _scrollThreshold) {
      _isScrolling = true;
      debugPrint(
        '🔄 Document scrolling detected, pausing tracking for ${_scrollThreshold.inSeconds}s',
      );
    }
  }

  /// Update scroll position
  void updateScrollPosition(double position, int currentPage) {
    _lastScrollTime = DateTime.now();
    _isScrolling = true;
    _scrollPosition = position.clamp(0.0, 1.0);
    _currentPage = currentPage;

    debugPrint(
      '📜 Document scroll: Page $currentPage, Position ${(_scrollPosition * 100).round()}%',
    );

    // Resume tracking after scroll threshold
    Timer(_scrollThreshold, () {
      _isScrolling = false;
      debugPrint(
        '✅ Scroll completed, resuming normal tracking from page: $currentPage',
      );
    });
  }

  /// Update viewing state
  void updateViewingState(bool isViewing) {
    _isViewing = isViewing;
    debugPrint(
      '${isViewing ? '👁️' : '👁️‍🗨️'} Document ${isViewing ? 'viewing' : 'not viewing'}',
    );

    if (isViewing) {
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

  /// Update total pages
  void updateTotalPages(int totalPages) {
    _totalPages = totalPages;
    _loadingStatus = 'Loaded';
    debugPrint('📏 Total pages updated: $totalPages');
  }

  /// Update loading status
  void updateLoadingStatus(String status) {
    _loadingStatus = status;
    debugPrint('📥 Loading status: $status');
  }

  /// Track progress and send to backend
  void _trackProgress() {
    if (!_isViewing || _isScrolling || _currentDocumentId == null) return;

    final progressSinceLastTrack = _currentViewTime - _lastTrackedTime;

    // Only track if we've made meaningful progress (at least 30 seconds)
    if (progressSinceLastTrack.inSeconds >= 30) {
      debugPrint(
        '📊 Tracking progress: ${_formatDuration(_currentViewTime)} / ${_formatDuration(_totalViewTime)}',
      );
      debugPrint(
        '📈 Progress since last track: ${_formatDuration(progressSinceLastTrack)}',
      );
      _lastTrackedTime = _currentViewTime;
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
    if (_currentDocumentId == null) return;

    final currentTime = DateTime.now();
    final progressPercentage = _totalPages > 0
        ? (_currentPage / _totalPages * 100).round()
        : 0;

    // Console log data
    final consoleData = {
      'timestamp': currentTime.toIso8601String(),
      'documentId': _currentDocumentId,
      'documentName':
          _currentDocumentId?.replaceAll('_', ' ') ?? 'Unknown Document',
      'currentPage': _currentPage,
      'totalPages': _totalPages,
      'progressPercentage': '$progressPercentage%',
      'scrollPosition': '${(_scrollPosition * 100).round()}%',
      'isViewing': _isViewing,
      'isScrolling': _isScrolling,
      'loadingStatus': _loadingStatus,
      'viewTime': _formatDuration(_currentViewTime),
      'totalViewTime': _formatDuration(_totalViewTime),
    };

    // Print detailed console log
    debugPrint('📄 ===== DOCUMENT CONSOLE DATA (Every 5s) =====');
    debugPrint('⏰ Time: ${consoleData['timestamp']}');
    debugPrint('📄 Document: ${consoleData['documentName']}');
    debugPrint(
      '📖 Page: ${consoleData['currentPage']} / ${consoleData['totalPages']}',
    );
    debugPrint('📊 Progress: ${consoleData['progressPercentage']}');
    debugPrint('📜 Scroll: ${consoleData['scrollPosition']}');
    debugPrint('👁️ Status: ${_isViewing ? 'Viewing' : 'Not Viewing'}');
    debugPrint('📥 Loading: ${consoleData['loadingStatus']}');
    debugPrint('🔄 Scrolling: ${_isScrolling ? 'Yes' : 'No'}');
    debugPrint('⏱️ View Time: ${consoleData['viewTime']}');
    debugPrint('📈 Total View Time: ${consoleData['totalViewTime']}');
    debugPrint('==========================================');
  }

  /// Send progress data to backend
  Future<void> _sendProgressToBackend() async {
    if (_currentDocumentId == null) return;

    try {
      final progressData = {
        'documentId': _currentDocumentId,
        'currentPage': _currentPage,
        'totalPages': _totalPages,
        'scrollPosition': _scrollPosition,
        'viewTime': _currentViewTime.inSeconds,
        'totalViewTime': _totalViewTime.inSeconds,
        'maxViewedTime': _maxViewedTime.inSeconds,
        'isViewing': _isViewing,
        'isScrolling': _isScrolling,
        'timestamp': DateTime.now().toIso8601String(),
        'progressPercentage': _totalPages > 0
            ? (_currentPage / _totalPages * 100)
            : 0,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_progressEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(progressData),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Document progress sent to backend successfully');
      } else {
        debugPrint(
          '❌ Failed to send document progress: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending document progress: $e');
    }
  }

  /// Stop tracking
  void _stopTracking() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Get current progress data
  Map<String, dynamic> getCurrentProgress() {
    return {
      'documentId': _currentDocumentId,
      'currentPage': _currentPage,
      'totalPages': _totalPages,
      'scrollPosition': _scrollPosition,
      'viewTime': _currentViewTime.inSeconds,
      'totalViewTime': _totalViewTime.inSeconds,
      'maxViewedTime': _maxViewedTime.inSeconds,
      'isViewing': _isViewing,
      'isScrolling': _isScrolling,
      'progressPercentage': _totalPages > 0
          ? (_currentPage / _totalPages * 100)
          : 0,
    };
  }

  /// Dispose resources
  void dispose() {
    _stopTracking();
    _stopConsoleLogging();
  }
}
