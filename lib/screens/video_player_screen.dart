import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import '../models/scorm.dart';
import '../services/video_progress_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Video video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  String? _error;
  final VideoProgressService _progressService = VideoProgressService();

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _progressService.dispose();
    super.dispose();
  }

  void _initializeWebView() {
    // Don't reinitialize if already initialized
    if (_webViewController != null) {
      return;
    }

    final PlatformWebViewControllerCreationParams params =
        WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: <PlaybackMediaTypes>{},
          )
        : const PlatformWebViewControllerCreationParams();
    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);

      // Set additional Android WebView settings for better video handling
      androidController.setOnShowFileSelector((params) async {
        return [];
      });
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'videoProgress',
        onMessageReceived: (JavaScriptMessage message) {
          _handleVideoProgressMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            debugPrint(
              'WebView Error: ${error.errorCode} - ${error.description}',
            );
            setState(() => _error = 'WebView Error: ${error.description}');
          },
          onPageFinished: (url) {
            debugPrint('WebView page loaded: $url');
            setState(() => _isLoading = false);
            _startProgressTracking();

            // Inject additional JavaScript for better video handling
            controller.runJavaScript('''
                  console.log('Page loaded, initializing video enhancements...');
                  
                  // Add error recovery for video element
                  const video = document.querySelector('video');
                  if (video) {
                    video.addEventListener('error', function(e) {
                      console.error('Video error:', e);
                      if (e.target.error) {
                        console.error('Error code:', e.target.error.code);
                        console.error('Error message:', e.target.error.message);
                      }
                    });
                    
                    // Retry mechanism for failed video loads
                    video.addEventListener('loadstart', function() {
                      console.log('Video loading started...');
                    });
                    
                    video.addEventListener('canplay', function() {
                      console.log('Video can play');
                    });
                    
                    // Set video properties for better compatibility
                    video.setAttribute('playsinline', 'true');
                    video.setAttribute('webkit-playsinline', 'true');
                    video.playsInline = true;
                  }
                ''');
          },
          onNavigationRequest: (request) {
            debugPrint('Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      );

    // Assign the controller first before using it
    _webViewController = controller;

    // Handle different video types
    if (widget.video.type == 'vimeo') {
      _loadVimeoVideo();
    } else {
      _loadDirectVideo();
    }
  }

  void _loadVimeoVideo() {
    if (_webViewController == null) return;

    // Extract Vimeo video ID from URL
    final RegExp vimeoRegex = RegExp(r'vimeo\.com/(\d+)');
    final Match? match = vimeoRegex.firstMatch(widget.video.videoUrl);

    if (match != null) {
      final String videoId = match.group(1)!;
      final String html = _buildVimeoHtml(videoId);
      _webViewController!.loadHtmlString(html);
    } else {
      setState(() {
        _error = 'Invalid Vimeo URL';
        _isLoading = false;
      });
    }
  }

  void _loadDirectVideo() {
    if (_webViewController == null) return;

    final String html = _buildVideoHtml(widget.video.videoUrl);
    _webViewController!.loadHtmlString(html);
  }

  void _startProgressTracking() {
    // Set up alert callback
    _progressService.onShowAlert = (String message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
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

    // Start progress tracking for the video
    _progressService.startTracking(
      videoId: widget.video.videoName.replaceAll(' ', '_'),
      totalDuration: const Duration(
        minutes: 15,
      ), // Default duration, will be updated when video loads
    );
  }

  void _handleVideoProgressMessage(String message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);

      final String type = data['type'] ?? '';
      final dynamic dataValue = data['data'];

      debugPrint('📹 Video Progress: $type - $dataValue');

      switch (type) {
        case 'duration':
          if (dataValue != null) {
            final double duration = (dataValue is num)
                ? dataValue.toDouble()
                : 0;
            _progressService.updateTotalDuration(
              Duration(seconds: duration.round()),
            );
          }
          break;

        case 'position':
          if (dataValue != null) {
            final double position = (dataValue is num)
                ? dataValue.toDouble()
                : 0;
            _progressService.updatePosition(
              Duration(seconds: position.round()),
            );
          }
          break;

        case 'play':
          _progressService.updatePlayState(true);
          break;

        case 'pause':
          _progressService.updatePlayState(false);
          break;

        case 'seek':
          if (dataValue != null) {
            final double position = (dataValue is num)
                ? dataValue.toDouble()
                : 0;
            _progressService.onSeek(Duration(seconds: position.round()));
          }
          break;

        case 'ended':
          _progressService.updatePlayState(false);
          debugPrint('🏁 Video ended');
          break;

        case 'loading_status':
          if (dataValue is String) {
            _progressService.updateLoadingStatus(dataValue);
            debugPrint('📥 Loading status: $dataValue');
          }
          break;

        case 'console_data':
          if (dataValue is Map<String, dynamic>) {
            _handleConsoleData(dataValue);
          }
          break;
      }
    } catch (e) {
      debugPrint('❌ Error handling video progress message: $e');
    }
  }

  void _handleConsoleData(Map<String, dynamic> consoleData) {
    debugPrint('🖥️ ===== CONSOLE DATA FROM WEBVIEW =====');
    debugPrint('⏰ Time: ${consoleData['timestamp']}');
    debugPrint('📹 Video: ${consoleData['videoName']}');
    debugPrint(
      '⏱️ Position: ${consoleData['currentPosition']} / ${consoleData['totalDuration']}',
    );
    debugPrint('📊 Progress: ${consoleData['progressPercentage']}');
    debugPrint('▶️ Status: ${consoleData['isPlaying'] ? 'Playing' : 'Paused'}');
    debugPrint('📥 Loading: ${consoleData['loadingStatus']}');
    debugPrint('🔄 Seeking: ${consoleData['isSeeking'] ? 'Yes' : 'No'}');
    debugPrint('💾 Buffered: ${consoleData['bufferedSeconds']}');
    debugPrint('⚡ Rate: ${consoleData['playbackRate']}');
    debugPrint('🌐 Network: ${consoleData['networkState']}');
    debugPrint('📡 Ready: ${consoleData['readyState']}');
    debugPrint(
      '🔊 Volume: ${consoleData['volume']} ${consoleData['muted'] ? '(Muted)' : ''}',
    );
    debugPrint('========================================');
  }

  String _buildVimeoHtml(String videoId) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Vimeo Video Player</title>
  <script src="https://player.vimeo.com/api/player.js"></script>
  <style>
    body {
      margin: 0;
      padding: 20px;
      font-family: Arial, sans-serif;
      background: #f5f5f5;
    }
    .container {
      max-width: 800px;
      margin: 0 auto;
      background: white;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      overflow: hidden;
    }
    .title {
      padding: 20px;
      background: #1ab7ea;
      color: white;
      font-size: 18px;
      font-weight: bold;
      text-align: center;
    }
    .video-container {
      position: relative;
      width: 100%;
      height: 0;
      padding-bottom: 56.25%; /* 16:9 aspect ratio */
    }
    .video-container iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: none;
    }
    .controls {
      padding: 20px;
      text-align: center;
      background: #f8f9fa;
    }
    .btn {
      background: #1ab7ea;
      color: white;
      border: none;
      padding: 10px 20px;
      margin: 0 5px;
      border-radius: 5px;
      cursor: pointer;
      font-size: 14px;
    }
    .btn:hover {
      background: #0ea5d6;
    }
    .status {
      margin-top: 10px;
      font-size: 12px;
      color: #666;
    }
    .console-log {
      margin-top: 10px;
      padding: 10px;
      background: #f8f9fa;
      border-radius: 5px;
      font-family: monospace;
      font-size: 11px;
      color: #333;
      max-height: 200px;
      overflow-y: auto;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="title">${widget.video.videoName}</div>
    <div class="video-container">
      <iframe 
        id="vimeo-player"
        src="https://player.vimeo.com/video/$videoId?api=1&player_id=vimeo-player"
        frameborder="0" 
        allow="autoplay; fullscreen; picture-in-picture" 
        allowfullscreen>
      </iframe>
    </div>
    <div class="controls">
      <button class="btn" onclick="playVideo()">▶️ Play</button>
      <button class="btn" onclick="pauseVideo()">⏸️ Pause</button>
      <button class="btn" onclick="getCurrentTime()">⏱️ Get Time</button>
    </div>
    <div class="status">
      Vimeo Player with Progress Tracking | Console logging every 5 seconds
    </div>
    <div class="console-log" id="console-log">
      <div>Console logs will appear here...</div>
    </div>
  </div>

  <script>
    let player = null;
    let consoleLogTimer = null;
    let progressTimer = null;
    let lastTrackedTime = 0;
    let loadingStatus = 'Initializing';
    let isPlaying = false;
    let currentDuration = 0;
    let currentPosition = 0;
    
    // Initialize Vimeo player
    function initVimeoPlayer() {
      const iframe = document.getElementById('vimeo-player');
      player = new Vimeo.Player(iframe);
      
      // Set up event listeners
      player.ready().then(function() {
        loadingStatus = 'Player ready';
        logToConsole('🎬 Vimeo player initialized and ready');
        sendProgress('loading_status', loadingStatus);
        
        // Get initial duration
        player.getDuration().then(function(duration) {
          currentDuration = duration;
          logToConsole('📏 Video duration: ' + formatTime(duration));
          sendProgress('duration', duration);
        }).catch(function(error) {
          logToConsole('❌ Error getting duration: ' + error);
        });
      }).catch(function(error) {
        loadingStatus = 'Error: ' + error.message;
        logToConsole('❌ Player initialization error: ' + error);
        sendProgress('loading_status', loadingStatus);
      });
      
      // Play event
      player.on('play', function() {
        isPlaying = true;
        loadingStatus = 'Playing';
        logToConsole('▶️ Video playing');
        sendProgress('play');
        sendProgress('loading_status', loadingStatus);
        startProgressTracking();
        startConsoleLogging();
      });
      
      // Pause event
      player.on('pause', function() {
        isPlaying = false;
        loadingStatus = 'Paused';
        logToConsole('⏸️ Video paused');
        sendProgress('pause');
        sendProgress('loading_status', loadingStatus);
        stopProgressTracking();
        stopConsoleLogging();
      });
      
      // Time update event
      player.on('timeupdate', function(data) {
        currentPosition = data.seconds;
      });
      
      // Loaded event
      player.on('loaded', function() {
        loadingStatus = 'Loaded';
        logToConsole('📥 Video loaded');
        sendProgress('loading_status', loadingStatus);
      });
      
      // Buffer start event
      player.on('bufferstart', function() {
        loadingStatus = 'Buffering';
        logToConsole('📥 Video buffering...');
        sendProgress('loading_status', loadingStatus);
      });
      
      // Buffer end event
      player.on('bufferend', function() {
        loadingStatus = 'Buffering complete';
        logToConsole('📥 Buffering complete');
        sendProgress('loading_status', loadingStatus);
      });
      
      // Ended event
      player.on('ended', function() {
        isPlaying = false;
        loadingStatus = 'Ended';
        logToConsole('🏁 Video ended');
        sendProgress('ended');
        sendProgress('loading_status', loadingStatus);
        stopProgressTracking();
        stopConsoleLogging();
      });
      
      // Error event
      player.on('error', function(error) {
        loadingStatus = 'Error: ' + error.message;
        logToConsole('❌ Video error: ' + error.message);
        sendProgress('loading_status', loadingStatus);
      });
      
      // Seeked event
      player.on('seeked', function(data) {
        currentPosition = data.seconds;
        logToConsole('⏩ Seeked to: ' + formatTime(data.seconds));
        sendProgress('seek', data.seconds);
      });
    }
    
    function startProgressTracking() {
      if (progressTimer) return;
      
      progressTimer = setInterval(function() {
        if (isPlaying && player) {
          player.getCurrentTime().then(function(currentTime) {
            currentPosition = currentTime;
            
            // Track every 30 seconds
            if (currentTime - lastTrackedTime >= 30) {
              logToConsole('📊 Tracking progress: ' + formatTime(currentTime) + ' / ' + formatTime(currentDuration));
              sendProgress('position', currentTime);
              lastTrackedTime = currentTime;
            }
          }).catch(function(error) {
            logToConsole('❌ Error getting current time: ' + error);
          });
        }
      }, 1000); // Check every second
    }
    
    function stopProgressTracking() {
      if (progressTimer) {
        clearInterval(progressTimer);
        progressTimer = null;
      }
    }
    
    function startConsoleLogging() {
      if (consoleLogTimer) return;
      
      consoleLogTimer = setInterval(function() {
        if (player) {
          logConsoleData();
        }
      }, 5000); // Log every 5 seconds
      
      logToConsole('🖥️ Started console logging every 5 seconds');
    }
    
    function stopConsoleLogging() {
      if (consoleLogTimer) {
        clearInterval(consoleLogTimer);
        consoleLogTimer = null;
      }
    }
    
    function logConsoleData() {
      if (!player) return;
      
      // Get current video state
      Promise.all([
        player.getCurrentTime(),
        player.getDuration(),
        player.getPaused(),
        player.getVolume(),
        player.getPlaybackRate()
      ]).then(function([currentTime, duration, paused, volume, playbackRate]) {
        const progressPercentage = duration > 0 ? Math.round((currentTime / duration) * 100) : 0;
        
        // Console log data
        const consoleData = {
          timestamp: new Date().toISOString(),
          videoId: '${widget.video.videoName.replaceAll(' ', '_')}',
          videoName: '${widget.video.videoName}',
          currentPosition: formatTime(currentTime),
          totalDuration: formatTime(duration),
          progressPercentage: progressPercentage + '%',
          isPlaying: !paused,
          isSeeking: false, // Vimeo doesn't provide seeking state directly
          loadingStatus: loadingStatus,
          bufferedSeconds: 'N/A', // Vimeo doesn't provide buffered info
          playbackRate: playbackRate + 'x',
          networkState: 'N/A', // Vimeo doesn't provide network state
          readyState: 'N/A', // Vimeo doesn't provide ready state
          volume: Math.round(volume * 100) + '%',
          muted: volume === 0
        };
        
        // Print detailed console log
        logToConsole('🎬 ===== VIMEO CONSOLE DATA (Every 5s) =====');
        logToConsole('⏰ Time: ' + consoleData.timestamp);
        logToConsole('📹 Video: ' + consoleData.videoName);
        logToConsole('⏱️ Position: ' + consoleData.currentPosition + ' / ' + consoleData.totalDuration);
        logToConsole('📊 Progress: ' + consoleData.progressPercentage);
        logToConsole('▶️ Status: ' + (consoleData.isPlaying ? 'Playing' : 'Paused'));
        logToConsole('📥 Loading: ' + consoleData.loadingStatus);
        logToConsole('🔄 Seeking: ' + (consoleData.isSeeking ? 'Yes' : 'No'));
        logToConsole('💾 Buffered: ' + consoleData.bufferedSeconds);
        logToConsole('⚡ Rate: ' + consoleData.playbackRate);
        logToConsole('🌐 Network: ' + consoleData.networkState);
        logToConsole('📡 Ready: ' + consoleData.readyState);
        logToConsole('🔊 Volume: ' + consoleData.volume + (consoleData.muted ? ' (Muted)' : ''));
        logToConsole('==========================================');
        
        // Send console data to Flutter
        sendProgress('console_data', consoleData);
      }).catch(function(error) {
        logToConsole('❌ Error getting player state: ' + error);
      });
    }
    
    function formatTime(seconds) {
      if (!seconds || isNaN(seconds)) return '00:00';
      
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      const secs = Math.floor(seconds % 60);
      
      if (hours > 0) {
        return hours.toString().padStart(2, '0') + ':' + 
               minutes.toString().padStart(2, '0') + ':' + 
               secs.toString().padStart(2, '0');
      } else {
        return minutes.toString().padStart(2, '0') + ':' + 
               secs.toString().padStart(2, '0');
      }
    }
    
    function logToConsole(message) {
      const consoleLog = document.getElementById('console-log');
      const timestamp = new Date().toLocaleTimeString();
      const logEntry = document.createElement('div');
      logEntry.textContent = '[' + timestamp + '] ' + message;
      consoleLog.appendChild(logEntry);
      consoleLog.scrollTop = consoleLog.scrollHeight;
      
      // Also log to browser console
      console.log(message);
    }
    
    function playVideo() {
      if (player) {
        player.play().catch(function(error) {
          logToConsole('❌ Error playing video: ' + error);
        });
      }
    }
    
    function pauseVideo() {
      if (player) {
        player.pause().catch(function(error) {
          logToConsole('❌ Error pausing video: ' + error);
        });
      }
    }
    
    function getCurrentTime() {
      if (player) {
        player.getCurrentTime().then(function(currentTime) {
          logToConsole('⏱️ Current time: ' + formatTime(currentTime));
        }).catch(function(error) {
          logToConsole('❌ Error getting current time: ' + error);
        });
      }
    }
    
    function sendProgress(type, data) {
      const message = {
        type: type,
        data: data,
        videoId: '${widget.video.videoName.replaceAll(' ', '_')}',
        timestamp: new Date().toISOString()
      };
      
      try {
        if (typeof videoProgress !== 'undefined') {
          videoProgress.postMessage(JSON.stringify(message));
        }
      } catch (e) {
        logToConsole('Progress message: ' + JSON.stringify(message));
      }
    }
    
    // Initialize when page loads
    document.addEventListener('DOMContentLoaded', function() {
      logToConsole('🚀 Initializing Vimeo player...');
      initVimeoPlayer();
    });
  </script>
</body>
</html>
''';
  }

  String _buildVideoHtml(String url) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    body { 
      margin: 0; 
      padding: 16px; 
      font-family: sans-serif; 
      background: #f0f0f0;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .container {
      background: white;
      border-radius: 10px;
      padding: 20px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      text-align: center;
      max-width: 800px;
      width: 90%;
    }
    .title {
      font-size: 20px;
      font-weight: bold;
      color: #333;
      margin-bottom: 20px;
    }
    video { 
      width: 100%; 
      max-width: 700px;
      border-radius: 8px;
      background: #000;
    }
    .controls {
      margin-top: 15px;
      display: flex;
      justify-content: center;
      gap: 10px;
    }
    .btn {
      background: #007bff;
      color: white;
      border: none;
      padding: 8px 16px;
      border-radius: 5px;
      cursor: pointer;
      font-size: 14px;
    }
    .btn:hover {
      background: #0056b3;
    }
    .status {
      margin-top: 10px;
      font-size: 12px;
      color: #666;
    }
  </style>
  <script>
    let videoElement = null;
    let progressTimer = null;
    let consoleLogTimer = null;
    let lastTrackedTime = 0;
    let loadingStatus = 'Initializing';
    let bufferedRanges = [];
    
    function initVideo() {
      videoElement = document.querySelector('video');
      if (!videoElement) return;
      
      // Set up video properties
      videoElement.muted = true;
      videoElement.playsInline = true;
      videoElement.setAttribute('playsinline', 'true');
      videoElement.setAttribute('webkit-playsinline', 'true');
      
      // Event listeners for loading status
      videoElement.addEventListener('loadstart', function() {
        loadingStatus = 'Loading started';
        console.log('📥 Video loading started');
        sendProgress('loading_status', loadingStatus);
      });
      
      videoElement.addEventListener('loadeddata', function() {
        loadingStatus = 'Data loaded';
        console.log('📥 Video data loaded');
        sendProgress('loading_status', loadingStatus);
      });
      
      videoElement.addEventListener('loadedmetadata', function() {
        loadingStatus = 'Metadata loaded';
        console.log('📥 Video metadata loaded, duration:', videoElement.duration);
        sendProgress('duration', videoElement.duration);
        sendProgress('loading_status', loadingStatus);
      });
      
      videoElement.addEventListener('canplay', function() {
        loadingStatus = 'Can play';
        console.log('📥 Video can start playing');
        sendProgress('loading_status', loadingStatus);
      });
      
      videoElement.addEventListener('canplaythrough', function() {
        loadingStatus = 'Can play through';
        console.log('📥 Video can play through without buffering');
        sendProgress('loading_status', loadingStatus);
      });
      
      videoElement.addEventListener('waiting', function() {
        loadingStatus = 'Buffering';
        console.log('📥 Video buffering...');
        sendProgress('loading_status', loadingStatus);
      });
      
      videoElement.addEventListener('playing', function() {
        loadingStatus = 'Playing';
        console.log('📥 Video playing');
        sendProgress('loading_status', loadingStatus);
      });
      
      videoElement.addEventListener('stalled', function() {
        loadingStatus = 'Stalled';
        console.log('📥 Video stalled');
        sendProgress('loading_status', loadingStatus);
      });
      
      videoElement.addEventListener('error', function(e) {
        loadingStatus = 'Error: ' + (e.target.error ? e.target.error.message : 'Unknown error');
        console.log('📥 Video error:', e.target.error);
        sendProgress('loading_status', loadingStatus);
      });
      
      // Event listeners for playback
      videoElement.addEventListener('play', function() {
        console.log('▶️ Video playing');
        sendProgress('play');
        startProgressTracking();
        startConsoleLogging();
      });
      
      videoElement.addEventListener('pause', function() {
        console.log('⏸️ Video paused');
        sendProgress('pause');
        stopProgressTracking();
        stopConsoleLogging();
      });
      
      videoElement.addEventListener('ended', function() {
        console.log('🏁 Video ended');
        sendProgress('ended');
        stopProgressTracking();
        stopConsoleLogging();
      });
      
      // Progress event for buffering info
      videoElement.addEventListener('progress', function() {
        updateBufferedRanges();
      });
      
      // Try to start playing
      videoElement.play().catch(function(error) {
        console.log('❌ Autoplay failed:', error);
        loadingStatus = 'Autoplay failed: ' + error.message;
        sendProgress('loading_status', loadingStatus);
      });
    }
    
    function startProgressTracking() {
      if (progressTimer) return;
      
      progressTimer = setInterval(function() {
        if (videoElement && !videoElement.paused) {
          const currentTime = videoElement.currentTime;
          const duration = videoElement.duration;
          
          // Track every 30 seconds
          if (currentTime - lastTrackedTime >= 30) {
            console.log('📊 Tracking progress:', currentTime, '/', duration);
            sendProgress('position', currentTime);
            lastTrackedTime = currentTime;
          }
        }
      }, 1000); // Check every second
    }
    
    function stopProgressTracking() {
      if (progressTimer) {
        clearInterval(progressTimer);
        progressTimer = null;
      }
    }
    
    function startConsoleLogging() {
      if (consoleLogTimer) return;
      
      consoleLogTimer = setInterval(function() {
        if (videoElement) {
          logConsoleData();
        }
      }, 5000); // Log every 5 seconds
      
      console.log('🖥️ Started console logging every 5 seconds');
    }
    
    function stopConsoleLogging() {
      if (consoleLogTimer) {
        clearInterval(consoleLogTimer);
        consoleLogTimer = null;
      }
    }
    
    function updateBufferedRanges() {
      if (!videoElement || !videoElement.buffered) return;
      
      bufferedRanges = [];
      for (let i = 0; i < videoElement.buffered.length; i++) {
        bufferedRanges.push({
          start: videoElement.buffered.start(i),
          end: videoElement.buffered.end(i)
        });
      }
    }
    
    function getBufferedSeconds() {
      if (!videoElement || !videoElement.buffered || videoElement.buffered.length === 0) {
        return 0;
      }
      
      const currentTime = videoElement.currentTime;
      let bufferedAhead = 0;
      
      for (let i = 0; i < videoElement.buffered.length; i++) {
        const start = videoElement.buffered.start(i);
        const end = videoElement.buffered.end(i);
        
        if (currentTime >= start && currentTime <= end) {
          bufferedAhead = end - currentTime;
          break;
        }
      }
      
      return Math.round(bufferedAhead);
    }
    
    function logConsoleData() {
      if (!videoElement) return;
      
      const currentTime = videoElement.currentTime;
      const duration = videoElement.duration;
      const progressPercentage = duration > 0 ? Math.round((currentTime / duration) * 100) : 0;
      const bufferedSeconds = getBufferedSeconds();
      const networkState = getNetworkStateText(videoElement.networkState);
      const readyState = getReadyStateText(videoElement.readyState);
      
      // Console log data
      const consoleData = {
        timestamp: new Date().toISOString(),
        videoId: '${widget.video.videoName.replaceAll(' ', '_')}',
        videoName: '${widget.video.videoName}',
        currentPosition: formatTime(currentTime),
        totalDuration: formatTime(duration),
        progressPercentage: progressPercentage + '%',
        isPlaying: !videoElement.paused,
        isSeeking: videoElement.seeking,
        loadingStatus: loadingStatus,
        bufferedSeconds: bufferedSeconds + 's',
        playbackRate: videoElement.playbackRate + 'x',
        networkState: networkState,
        readyState: readyState,
        volume: Math.round(videoElement.volume * 100) + '%',
        muted: videoElement.muted
      };
      
      // Print detailed console log
      console.log('🎬 ===== VIDEO CONSOLE DATA (Every 5s) =====');
      console.log('⏰ Time:', consoleData.timestamp);
      console.log('📹 Video:', consoleData.videoName);
      console.log('⏱️ Position:', consoleData.currentPosition, '/', consoleData.totalDuration);
      console.log('📊 Progress:', consoleData.progressPercentage);
      console.log('▶️ Status:', consoleData.isPlaying ? 'Playing' : 'Paused');
      console.log('📥 Loading:', consoleData.loadingStatus);
      console.log('🔄 Seeking:', consoleData.isSeeking ? 'Yes' : 'No');
      console.log('💾 Buffered:', consoleData.bufferedSeconds);
      console.log('⚡ Rate:', consoleData.playbackRate);
      console.log('🌐 Network:', consoleData.networkState);
      console.log('📡 Ready:', consoleData.readyState);
      console.log('🔊 Volume:', consoleData.volume, consoleData.muted ? '(Muted)' : '');
      console.log('==========================================');
      
      // Send console data to Flutter
      sendProgress('console_data', consoleData);
    }
    
    function formatTime(seconds) {
      if (!seconds || isNaN(seconds)) return '00:00';
      
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      const secs = Math.floor(seconds % 60);
      
      if (hours > 0) {
        return hours.toString().padStart(2, '0') + ':' + 
               minutes.toString().padStart(2, '0') + ':' + 
               secs.toString().padStart(2, '0');
      } else {
        return minutes.toString().padStart(2, '0') + ':' + 
               secs.toString().padStart(2, '0');
      }
    }
    
    function getNetworkStateText(state) {
      const states = {
        0: 'Empty',
        1: 'Idle',
        2: 'Loading',
        3: 'No Source'
      };
      return states[state] || 'Unknown';
    }
    
    function getReadyStateText(state) {
      const states = {
        0: 'Nothing',
        1: 'Metadata',
        2: 'Current Data',
        3: 'Future Data',
        4: 'Enough Data'
      };
      return states[state] || 'Unknown';
    }
    
    function sendProgress(type, data) {
      const message = {
        type: type,
        data: data,
        videoId: '${widget.video.videoName.replaceAll(' ', '_')}',
        timestamp: new Date().toISOString()
      };
      
      try {
        if (typeof videoProgress !== 'undefined') {
          videoProgress.postMessage(JSON.stringify(message));
        }
      } catch (e) {
        console.log('Progress message:', message);
      }
    }
    
    function playVideo() {
      if (videoElement) {
        videoElement.play();
      }
    }
    
    function pauseVideo() {
      if (videoElement) {
        videoElement.pause();
      }
    }
    
    function resumeVideo() {
      if (videoElement) {
        videoElement.play();
      }
    }
    
    // Initialize when page loads
    document.addEventListener('DOMContentLoaded', initVideo);
  </script>
  <title>Simple Video Player</title>
</head>
<body>
  <div class="container">
    <div class="title">${widget.video.videoName}</div>
    <video 
      controls 
      preload="auto" 
      playsinline 
      webkit-playsinline>
      <source src="$url" type="video/mp4">
      <source src="$url" type="video/webm">
      <source src="$url" type="video/ogg">
      Your browser does not support the video element.
    </video>
    <div class="controls">
      <button class="btn" onclick="playVideo()">▶️ Play</button>
      <button class="btn" onclick="pauseVideo()">⏸️ Pause</button>
      <button class="btn" onclick="resumeVideo()">▶️ Resume</button>
    </div>
    <div class="status">
      Progress tracking every 30 seconds | Console logging every 5 seconds
    </div>
  </div>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.videoName),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _progressService.printProgressStatus();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progress status printed to console'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Show Progress Status',
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading video',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _webViewController = null;
                        _error = null;
                        _isLoading = true;
                      });
                      _initializeWebView();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                if (_webViewController != null)
                  WebViewWidget(controller: _webViewController!),
                if (_isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x11000000),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Loading video player...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
