import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import '../models/scorm.dart';
import '../services/music_progress_service.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Music music;

  const AudioPlayerScreen({super.key, required this.music});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _error;
  final MusicProgressService _progressService = MusicProgressService();

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _startMusicTracking();
  }

  @override
  void dispose() {
    _progressService.stopTracking();
    super.dispose();
  }

  void _initializeWebView() {
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
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    final html = _buildAudioHtml(widget.music.musicUrl);
    final encoded = base64Encode(const Utf8Encoder().convert(html));

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            setState(() => _error = error.description);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            _setupJavaScriptCommunication();
          },
        ),
      )
      ..addJavaScriptChannel(
        'MusicProgress',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      )
      ..loadRequest(Uri.parse('data:text/html;base64,$encoded'));

    _webViewController = controller;
  }

  /// Start music progress tracking
  void _startMusicTracking() {
    final musicId = widget.music.musicName.replaceAll(' ', '_').toLowerCase();
    _progressService.startTracking(
      musicId: musicId,
      totalDuration: Duration.zero, // Will be updated when audio loads
    );
  }

  /// Setup JavaScript communication with the WebView
  void _setupJavaScriptCommunication() {
    _webViewController.runJavaScript('''
      window.flutterMusicProgress = {
        sendMessage: function(message) {
          MusicProgress.postMessage(JSON.stringify(message));
        }
      };
    ''');
  }

  /// Handle JavaScript messages from the WebView
  void _handleJavaScriptMessage(String message) {
    try {
      final data = jsonDecode(message);
      final event = data['event'] as String;

      switch (event) {
        case 'loadedmetadata':
          final duration = Duration(seconds: (data['duration'] as num).toInt());
          _progressService.updateTotalDuration(duration);
          _progressService.updateLoadingStatus('Loaded');
          break;
        case 'timeupdate':
          final currentTime = Duration(
            seconds: (data['currentTime'] as num).toInt(),
          );
          _progressService.updatePosition(currentTime);
          break;
        case 'play':
          _progressService.updatePlayState(true);
          break;
        case 'pause':
          _progressService.updatePlayState(false);
          break;
        case 'seeked':
          final seekTime = Duration(
            seconds: (data['currentTime'] as num).toInt(),
          );
          _progressService.onSeek(seekTime);
          break;
        case 'volumechange':
          final volume = data['volume'] as num;
          _progressService.updateVolume(volume.toDouble());
          break;
        case 'ratechange':
          final rate = data['playbackRate'] as num;
          _progressService.updatePlaybackRate(rate.toDouble());
          break;
      }
    } catch (e) {
      debugPrint('Error handling JavaScript message: $e');
    }
  }

  String _buildAudioHtml(String url) {
    // Simple HTML5 audio player, provide multiple source types and avoid encoding URL in src
    final lower = url.toLowerCase();
    final isMp3 = lower.endsWith('.mp3');
    final isOgg = lower.endsWith('.ogg') || lower.endsWith('.oga');
    final isM4a = lower.endsWith('.m4a') || lower.endsWith('.aac');

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
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .container {
      background: white;
      border-radius: 20px;
      padding: 30px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.3);
      text-align: center;
      max-width: 400px;
      width: 90%;
    }
    .music-icon {
      font-size: 48px;
      color: #667eea;
      margin-bottom: 20px;
    }
    .title {
      font-size: 24px;
      font-weight: bold;
      color: #333;
      margin-bottom: 10px;
    }
    .description {
      font-size: 14px;
      color: #666;
      margin-bottom: 30px;
    }
    audio { 
      width: 100%; 
      max-width: 350px;
      border-radius: 10px;
    }
    .controls {
      margin-top: 20px;
      display: flex;
      justify-content: center;
      gap: 10px;
    }
    .btn {
      background: #667eea;
      color: white;
      border: none;
      padding: 10px 20px;
      border-radius: 25px;
      cursor: pointer;
      font-size: 14px;
    }
    .btn:hover {
      background: #5a6fd8;
    }
  </style>
  <script>
    document.addEventListener('DOMContentLoaded', function(){
      var a = document.querySelector('audio');
      if (a) {
        // Try autoplay muted; user can still tap play if blocked by policy
        a.muted = true;
        a.play().catch(function(){});
        
        // Add event listeners for progress tracking
        a.addEventListener('loadedmetadata', function() {
          if (window.flutterMusicProgress) {
            window.flutterMusicProgress.sendMessage({
              event: 'loadedmetadata',
              duration: a.duration
            });
          }
        });
        
        a.addEventListener('timeupdate', function() {
          if (window.flutterMusicProgress) {
            window.flutterMusicProgress.sendMessage({
              event: 'timeupdate',
              currentTime: a.currentTime
            });
          }
        });
        
        a.addEventListener('play', function() {
          if (window.flutterMusicProgress) {
            window.flutterMusicProgress.sendMessage({
              event: 'play'
            });
          }
        });
        
        a.addEventListener('pause', function() {
          if (window.flutterMusicProgress) {
            window.flutterMusicProgress.sendMessage({
              event: 'pause'
            });
          }
        });
        
        a.addEventListener('seeked', function() {
          if (window.flutterMusicProgress) {
            window.flutterMusicProgress.sendMessage({
              event: 'seeked',
              currentTime: a.currentTime
            });
          }
        });
        
        a.addEventListener('volumechange', function() {
          if (window.flutterMusicProgress) {
            window.flutterMusicProgress.sendMessage({
              event: 'volumechange',
              volume: a.volume
            });
          }
        });
        
        a.addEventListener('ratechange', function() {
          if (window.flutterMusicProgress) {
            window.flutterMusicProgress.sendMessage({
              event: 'ratechange',
              playbackRate: a.playbackRate
            });
          }
        });
      }
      
      // Add custom controls
      var playBtn = document.getElementById('playBtn');
      var pauseBtn = document.getElementById('pauseBtn');
      var stopBtn = document.getElementById('stopBtn');
      
      if (playBtn) {
        playBtn.addEventListener('click', function() {
          a.play();
        });
      }
      
      if (pauseBtn) {
        pauseBtn.addEventListener('click', function() {
          a.pause();
        });
      }
      
      if (stopBtn) {
        stopBtn.addEventListener('click', function() {
          a.pause();
          a.currentTime = 0;
        });
      }
    });
  </script>
  <title>Audio Player</title>
</head>
<body>
  <div class="container">
    <div class="music-icon">🎵</div>
    <div class="title">${widget.music.musicName}</div>
    <div class="description">${widget.music.description}</div>
    <audio controls preload="auto">
      ${isMp3 ? '<source src="$url" type="audio/mpeg" />' : ''}
      ${isOgg ? '<source src="$url" type="audio/ogg" />' : ''}
      ${isM4a ? '<source src="$url" type="audio/mp4" />' : ''}
      ${(!isMp3 && !isOgg && !isM4a) ? '<source src="$url" />' : ''}
      Your browser does not support the audio element.
    </audio>
    <div class="controls">
      <button class="btn" id="playBtn">▶️ Play</button>
      <button class="btn" id="pauseBtn">⏸️ Pause</button>
      <button class="btn" id="stopBtn">⏹️ Stop</button>
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
        title: Text(widget.music.musicName),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading audio',
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
                      _initializeWebView();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _webViewController),
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
                              'Loading audio player...',
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
