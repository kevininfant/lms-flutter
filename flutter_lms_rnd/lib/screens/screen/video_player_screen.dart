import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_lms_rnd/services/video_cache_service.dart';
import 'package:flutter_lms_rnd/services/video_progress_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isDownloading = false;
  double _progress = 0.0;
  String? _localPath;
  Duration? _savedPosition;
  bool _isOffline = false;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      // Enter fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Exit fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isDownloading = true;
        _progress = 0.0;
      });

      final String videoUrl = widget.videoUrl;

      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      _isOffline = connectivityResult == ConnectivityResult.none;

      // Get saved progress
      _savedPosition = await VideoProgressService.instance.getProgress(
        videoUrl,
      );

      // Check if video is already cached
      final String? cached = await VideoCacheService.instance.getCachedPath(
        videoUrl,
      );

      if (cached != null && File(cached).existsSync()) {
        // Play cached video
        _localPath = cached;
        await _initializeVideoController(File(_localPath!));
      } else if (!_isOffline) {
        // Download and play
        await _downloadAndPlay(videoUrl);
      } else {
        // Offline and no cached video
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No internet connection and video not cached.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load video: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _initializeVideoController(dynamic source) async {
    try {
      _controller?.dispose();

      if (source is File) {
        _controller = VideoPlayerController.file(source);
      } else if (source is String) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(source));
      } else {
        throw Exception('Invalid video source');
      }

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Resume from saved position
        if (_savedPosition != null && _savedPosition!.inSeconds > 5) {
          await _controller!.seekTo(_savedPosition!);
        }

        // Auto-play
        await _controller!.play();

        // Save progress periodically
        _controller!.addListener(_saveProgress);
        _setupProgressListener();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize video: $e')),
        );
      }
    }
  }

  void _saveProgress() {
    if (_controller != null && _controller!.value.isInitialized) {
      final position = _controller!.value.position;
      if (position.inSeconds > 10 && position.inSeconds % 30 == 0) {
        VideoProgressService.instance.saveProgress(widget.videoUrl, position);
      }
    }
  }

  void _setupProgressListener() {
    if (_controller != null) {
      _controller!.addListener(() {
        if (mounted) {
          setState(() {
            // This will trigger UI updates for progress
          });
        }
      });
    }
  }

  Future<void> _downloadAndPlay(String videoUrl) async {
    // Download video with progress
    await for (final double p
        in VideoCacheService.instance.downloadWithProgress(videoUrl)) {
      if (mounted) {
        setState(() {
          _progress = p;
        });
      }
    }

    // Play downloaded video
    final String? local = await VideoCacheService.instance.getCachedPath(
      videoUrl,
    );
    if (local != null && File(local).existsSync()) {
      _localPath = local;
      await _initializeVideoController(File(_localPath!));
    }
  }

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

  Future<void> _seekTo(Duration position) async {
    if (_controller != null && _controller!.value.isInitialized) {
      await _controller!.seekTo(position);
    }
  }

  @override
  void dispose() {
    // Save final progress
    if (_controller != null && _controller!.value.isInitialized) {
      final currentPosition = _controller!.value.position;
      if (currentPosition.inSeconds > 10) {
        VideoProgressService.instance.saveProgress(
          widget.videoUrl,
          currentPosition,
        );
      }
    }

    // Reset orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: const Text('Video Player'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _initializePlayer();
                  },
                  tooltip: 'Reload video',
                ),
                IconButton(
                  icon: Icon(
                    _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  ),
                  onPressed: _toggleFullscreen,
                  tooltip: _isFullscreen
                      ? 'Exit fullscreen'
                      : 'Enter fullscreen',
                ),
              ],
            ),
      body: _isFullscreen ? _buildFullscreenView() : _buildNormalView(),
    );
  }

  Widget _buildNormalView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isDownloading) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _progress > 0 && _progress < 1 ? _progress : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isOffline
                        ? 'Offline Mode - Playing cached video'
                        : _progress >= 1
                        ? 'Processing...'
                        : 'Downloading: ${(100 * _progress).toStringAsFixed(0)}%',
                  ),
                  if (_savedPosition != null &&
                      _savedPosition!.inSeconds > 5) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Will resume from ${_formatDuration(_savedPosition!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _isInitialized && _controller != null
                  ? VideoPlayer(_controller!)
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          // Video Progress Bar
          if (_isInitialized && _controller != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _controller!,
                    builder: (context, value, child) {
                      final position = value.position;
                      final duration = value.duration;

                      return Column(
                        children: [
                          Slider(
                            value: duration.inMilliseconds > 0
                                ? position.inMilliseconds /
                                      duration.inMilliseconds
                                : 0.0,
                            onChanged: (newValue) {
                              final newPosition = Duration(
                                milliseconds:
                                    (newValue * duration.inMilliseconds)
                                        .round(),
                              );
                              _seekTo(newPosition);
                            },
                            activeColor: Colors.blue,
                            inactiveColor: Colors.grey,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Video controls
          if (_isInitialized && _controller != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_controller!.value.isPlaying) {
                      await _controller!.pause();
                    } else {
                      await _controller!.play();
                    }
                  },
                  icon: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  label: Text(_controller!.value.isPlaying ? 'Pause' : 'Play'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _controller!.pause();
                    await _controller!.seekTo(Duration.zero);
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _toggleFullscreen,
                  icon: Icon(
                    _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  ),
                  label: Text(_isFullscreen ? 'Exit' : 'Fullscreen'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFullscreenView() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Video player fills the entire screen
          Center(
            child: _isInitialized && _controller != null
                ? VideoPlayer(_controller!)
                : const Center(child: CircularProgressIndicator()),
          ),
          // Fullscreen controls overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar
                  if (_isInitialized && _controller != null)
                    ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable: _controller!,
                      builder: (context, value, child) {
                        final position = value.position;
                        final duration = value.duration;

                        return Column(
                          children: [
                            Slider(
                              value: duration.inMilliseconds > 0
                                  ? position.inMilliseconds /
                                        duration.inMilliseconds
                                  : 0.0,
                              onChanged: (newValue) {
                                final newPosition = Duration(
                                  milliseconds:
                                      (newValue * duration.inMilliseconds)
                                          .round(),
                                );
                                _seekTo(newPosition);
                              },
                              activeColor: Colors.white,
                              inactiveColor: Colors.grey,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  // Control buttons
                  if (_isInitialized && _controller != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (_controller!.value.isPlaying) {
                              await _controller!.pause();
                            } else {
                              await _controller!.play();
                            }
                          },
                          icon: Icon(
                            _controller!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () async {
                            await _controller!.pause();
                            await _controller!.seekTo(Duration.zero);
                          },
                          icon: const Icon(
                            Icons.stop,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: _toggleFullscreen,
                          icon: const Icon(
                            Icons.fullscreen_exit,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
