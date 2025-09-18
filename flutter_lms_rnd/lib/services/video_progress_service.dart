import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoProgressService {
  VideoProgressService._();
  static final VideoProgressService instance = VideoProgressService._();

  static const String _progressKey = 'video_progress';
  static const String _lastWatchedKey = 'last_watched_videos';

  /// Save video progress (position in seconds)
  Future<void> saveProgress(String videoUrl, Duration position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = _getProgressMap(prefs);

      progressMap[videoUrl] = {
        'position': position.inSeconds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'duration': null, // Will be updated when video loads
      };

      await prefs.setString(_progressKey, json.encode(progressMap));

      // Update last watched list
      await _updateLastWatched(videoUrl);

      if (kDebugMode) {
        print('Saved progress for $videoUrl: ${position.inSeconds}s');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save progress: $e');
      }
    }
  }

  /// Get saved video progress
  Future<Duration?> getProgress(String videoUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = _getProgressMap(prefs);

      final progressData = progressMap[videoUrl];
      if (progressData != null) {
        final position = progressData['position'] as int?;
        if (position != null && position > 0) {
          return Duration(seconds: position);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get progress: $e');
      }
    }
    return null;
  }

  /// Save video duration
  Future<void> saveDuration(String videoUrl, Duration duration) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = _getProgressMap(prefs);

      if (progressMap.containsKey(videoUrl)) {
        progressMap[videoUrl]!['duration'] = duration.inSeconds;
        await prefs.setString(_progressKey, json.encode(progressMap));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save duration: $e');
      }
    }
  }

  /// Get video duration
  Future<Duration?> getDuration(String videoUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = _getProgressMap(prefs);

      final progressData = progressMap[videoUrl];
      if (progressData != null) {
        final duration = progressData['duration'] as int?;
        if (duration != null) {
          return Duration(seconds: duration);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get duration: $e');
      }
    }
    return null;
  }

  /// Get progress percentage
  Future<double> getProgressPercentage(String videoUrl) async {
    try {
      final position = await getProgress(videoUrl);
      final duration = await getDuration(videoUrl);

      if (position != null && duration != null && duration.inSeconds > 0) {
        return (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get progress percentage: $e');
      }
    }
    return 0.0;
  }

  /// Get last watched videos
  Future<List<String>> getLastWatchedVideos({int limit = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastWatchedJson = prefs.getString(_lastWatchedKey);

      if (lastWatchedJson != null) {
        final List<dynamic> lastWatched = json.decode(lastWatchedJson);
        return lastWatched.cast<String>().take(limit).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get last watched videos: $e');
      }
    }
    return [];
  }

  /// Clear progress for a specific video
  Future<void> clearProgress(String videoUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = _getProgressMap(prefs);

      progressMap.remove(videoUrl);
      await prefs.setString(_progressKey, json.encode(progressMap));

      if (kDebugMode) {
        print('Cleared progress for $videoUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear progress: $e');
      }
    }
  }

  /// Clear all progress
  Future<void> clearAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
      await prefs.remove(_lastWatchedKey);

      if (kDebugMode) {
        print('Cleared all video progress');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear all progress: $e');
      }
    }
  }

  /// Get all progress data
  Map<String, dynamic> _getProgressMap(SharedPreferences prefs) {
    try {
      final progressJson = prefs.getString(_progressKey);
      if (progressJson != null) {
        final Map<String, dynamic> decoded = json.decode(progressJson);
        return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to decode progress map: $e');
      }
    }
    return {};
  }

  /// Update last watched videos list
  Future<void> _updateLastWatched(String videoUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastWatchedJson = prefs.getString(_lastWatchedKey);

      List<String> lastWatched = [];
      if (lastWatchedJson != null) {
        lastWatched = List<String>.from(json.decode(lastWatchedJson));
      }

      // Remove if already exists and add to front
      lastWatched.remove(videoUrl);
      lastWatched.insert(0, videoUrl);

      // Keep only last 50 videos
      if (lastWatched.length > 50) {
        lastWatched = lastWatched.take(50).toList();
      }

      await prefs.setString(_lastWatchedKey, json.encode(lastWatched));
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update last watched: $e');
      }
    }
  }

  /// Check if video was watched recently
  Future<bool> isRecentlyWatched(
    String videoUrl, {
    Duration threshold = const Duration(hours: 24),
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = _getProgressMap(prefs);

      final progressData = progressMap[videoUrl];
      if (progressData != null) {
        final timestamp = progressData['timestamp'] as int?;
        if (timestamp != null) {
          final lastWatched = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final now = DateTime.now();
          return now.difference(lastWatched) < threshold;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check if recently watched: $e');
      }
    }
    return false;
  }
}
