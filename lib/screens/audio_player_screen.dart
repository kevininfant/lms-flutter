import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import '../models/scorm.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeWebView();
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
          },
        ),
      )
      ..loadRequest(Uri.parse('data:text/html;base64,$encoded'));

    _webViewController = controller;
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
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading audio',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
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
