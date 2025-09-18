import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import '../models/scorm.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Video video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
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
    // Extract Vimeo video ID from URL
    final RegExp vimeoRegex = RegExp(r'vimeo\.com/(\d+)');
    final Match? match = vimeoRegex.firstMatch(widget.video.videoUrl);
    
    if (match != null) {
      final String videoId = match.group(1)!;
      final String embedUrl = 'https://player.vimeo.com/video/$videoId';
      _webViewController.loadRequest(Uri.parse(embedUrl));
    } else {
      setState(() {
        _error = 'Invalid Vimeo URL';
        _isLoading = false;
      });
    }
  }

  void _loadDirectVideo() {
    final String html = _buildVideoHtml(widget.video.videoUrl);
    _webViewController.loadHtmlString(html);
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
      background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
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
      max-width: 800px;
      width: 90%;
    }
    .video-icon {
      font-size: 48px;
      color: #ff6b6b;
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
    video { 
      width: 100%; 
      max-width: 700px;
      border-radius: 10px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.2);
    }
    .controls {
      margin-top: 20px;
      display: flex;
      justify-content: center;
      gap: 10px;
      flex-wrap: wrap;
    }
    .btn {
      background: #ff6b6b;
      color: white;
      border: none;
      padding: 10px 20px;
      border-radius: 25px;
      cursor: pointer;
      font-size: 14px;
    }
    .btn:hover {
      background: #ff5252;
    }
    .info {
      margin-top: 20px;
      padding: 15px;
      background: #f8f9fa;
      border-radius: 10px;
      text-align: left;
    }
    .info h4 {
      margin: 0 0 10px 0;
      color: #333;
    }
    .info p {
      margin: 5px 0;
      color: #666;
      font-size: 14px;
    }
  </style>
  <script>
    document.addEventListener('DOMContentLoaded', function(){
      var v = document.querySelector('video');
      if (v) {
        // Try autoplay muted; user can still tap play if blocked by policy
        v.muted = true;
        v.play().catch(function(){});
      }
      
      // Add custom controls
      var playBtn = document.getElementById('playBtn');
      var pauseBtn = document.getElementById('pauseBtn');
      var stopBtn = document.getElementById('stopBtn');
      var fullscreenBtn = document.getElementById('fullscreenBtn');
      
      if (playBtn) {
        playBtn.addEventListener('click', function() {
          v.play();
        });
      }
      
      if (pauseBtn) {
        pauseBtn.addEventListener('click', function() {
          v.pause();
        });
      }
      
      if (stopBtn) {
        stopBtn.addEventListener('click', function() {
          v.pause();
          v.currentTime = 0;
        });
      }
      
      if (fullscreenBtn) {
        fullscreenBtn.addEventListener('click', function() {
          if (v.requestFullscreen) {
            v.requestFullscreen();
          } else if (v.webkitRequestFullscreen) {
            v.webkitRequestFullscreen();
          } else if (v.mozRequestFullScreen) {
            v.mozRequestFullScreen();
          } else if (v.msRequestFullscreen) {
            v.msRequestFullscreen();
          }
        });
      }
    });
  </script>
  <title>Video Player</title>
</head>
<body>
  <div class="container">
    <div class="video-icon">🎬</div>
    <div class="title">${widget.video.videoName}</div>
    <div class="description">${widget.video.description}</div>
    <video controls preload="auto" poster="">
      <source src="$url" type="video/mp4">
      <source src="$url" type="video/webm">
      <source src="$url" type="video/ogg">
      Your browser does not support the video element.
    </video>
    <div class="controls">
      <button class="btn" id="playBtn">▶️ Play</button>
      <button class="btn" id="pauseBtn">⏸️ Pause</button>
      <button class="btn" id="stopBtn">⏹️ Stop</button>
      <button class="btn" id="fullscreenBtn">🔍 Fullscreen</button>
    </div>
    <div class="info">
      <h4>Video Information</h4>
      <p><strong>Type:</strong> ${widget.video.type.toUpperCase()}</p>
      <p><strong>URL:</strong> $url</p>
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
                    'Error loading video',
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
