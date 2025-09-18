import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_static/shelf_static.dart' as shelf_static;
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../models/scorm.dart';

class H5PPlayerScreen extends StatefulWidget {
  final H5P h5p;

  const H5PPlayerScreen({super.key, required this.h5p});

  @override
  State<H5PPlayerScreen> createState() => _H5PPlayerScreenState();
}

class H5POnlinePlayerScreen extends StatefulWidget {
  final H5P h5p;

  const H5POnlinePlayerScreen({super.key, required this.h5p});

  @override
  State<H5POnlinePlayerScreen> createState() => _H5POnlinePlayerScreenState();
}

class _H5PPlayerScreenState extends State<H5PPlayerScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _error;
  HttpServer? _server;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _prepareAndLaunch();
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
            debugPrint(
              'WebView error: ${error.errorCode} ${error.description}',
            );
          },
          onPageFinished: (url) {
            controller.runJavaScript(
              "document.querySelectorAll('video, audio').forEach(function(m){try{m.muted=true; m.play().catch(function(){});}catch(e){}});",
            );
          },
        ),
      );
    _webViewController = controller;
  }

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.h5p.h5pName),
        backgroundColor: Colors.purple,
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
                    'Error loading H5P content',
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
                      _prepareAndLaunch();
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
                              'Loading H5P content...',
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

  Future<void> _prepareAndLaunch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String extractPath = path.join(
        appDocDir.path,
        'h5p_extracted',
        widget.h5p.h5pName.replaceAll(' ', '_'),
      );

      final Directory extractDir = Directory(extractPath);
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create(recursive: true);

      // For H5P files, we'll try to load from URL first
      if (widget.h5p.h5pFile.startsWith('http')) {
        // Load online H5P content
        await _webViewController.loadRequest(Uri.parse(widget.h5p.h5pFile));
      } else {
        // Try to load from assets (if file exists)
        try {
          final ByteData data = await rootBundle.load(widget.h5p.h5pFile);
          final Uint8List bytes = data.buffer.asUint8List();
          final Archive archive = ZipDecoder().decodeBytes(bytes);
          for (final ArchiveFile f in archive) {
            final String outPath = path.join(extractPath, f.name);
            if (f.isFile) {
              final Directory dir = Directory(path.dirname(outPath));
              if (!await dir.exists()) {
                await dir.create(recursive: true);
              }
              final File outFile = File(outPath);
              await outFile.writeAsBytes(f.content as List<int>);
            }
          }

          // H5P: load index.html if present; fallback to any html in the root or inside content
          String? launchPath;
          final List<String> candidates = [
            'index.html',
            path.join('content', 'index.html'),
            path.join('h5p.html'),
          ];
          for (final c in candidates) {
            final p = path.join(extractPath, c);
            if (File(p).existsSync()) {
              launchPath = p;
              break;
            }
          }
          launchPath ??= _findAnyHtml(extractPath);
          if (launchPath == null) {
            throw Exception('No launchable HTML found in H5P');
          }

          // Serve via local HTTP to allow relative assets and XHR
          final handler = shelf.Pipeline()
              .addMiddleware(shelf.logRequests())
              .addHandler(
                shelf_static.createStaticHandler(
                  extractPath,
                  defaultDocument: 'index.html',
                  serveFilesOutsidePath: false,
                ),
              );
          final server = await shelf_io.serve(
            handler,
            InternetAddress.loopbackIPv4,
            0,
          );
          _server = server;
          final String relative = path
              .relative(launchPath, from: extractPath)
              .replaceAll('\\', '/');
          final Uri url = Uri.parse('http://127.0.0.1:${server.port}/$relative');
          await _webViewController.loadRequest(url);
        } catch (e) {
          // If asset loading fails, try to load the URL directly
          await _webViewController.loadRequest(Uri.parse(widget.h5p.h5pFile));
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to launch H5P: $e';
        _isLoading = false;
      });
    }
  }

  String? _findAnyHtml(String root) {
    try {
      final List<FileSystemEntity> files = Directory(root).listSync(recursive: true);
      for (final f in files) {
        if (f is File && path.extension(f.path).toLowerCase() == '.html') {
          return f.path;
        }
      }
    } catch (e) {
      debugPrint('H5P HTML search error: $e');
    }
    return null;
  }
}

class _H5POnlinePlayerScreenState extends State<H5POnlinePlayerScreen> {
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
      )
      ..loadRequest(Uri.parse(widget.h5p.h5pFile));

    _webViewController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.h5p.h5pName),
        backgroundColor: Colors.purple,
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
                    'Error loading H5P content',
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
                      _webViewController.loadRequest(Uri.parse(widget.h5p.h5pFile));
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
                              'Loading H5P content...',
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
