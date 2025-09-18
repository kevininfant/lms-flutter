import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:open_file/open_file.dart';
import '../models/scorm.dart';

class DocumentViewerScreen extends StatefulWidget {
  final Document document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _error;
  bool _usedAltViewer = false;

  bool _isOffice(String lower) {
    return lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.xlsx') ||
        lower.endsWith('.ppt') ||
        lower.endsWith('.pptx');
  }

  bool _isPdf(String lower) {
    return lower.endsWith('.pdf');
  }

  // Prefer Office Online for Office files; Google Viewer for PDFs; direct for txt/others
  String _wrapUrlForPreview(String raw) {
    final lower = raw.toLowerCase();
    if (_isOffice(lower)) {
      final encoded = Uri.encodeComponent(raw);
      return 'https://view.officeapps.live.com/op/embed.aspx?src=$encoded';
    }
    if (_isPdf(lower)) {
      final encoded = Uri.encodeComponent(raw);
      return 'https://docs.google.com/gview?embedded=1&url=$encoded';
    }
    return raw;
  }

  String? _altViewerUrl(String raw) {
    final lower = raw.toLowerCase();
    if (_isPdf(lower)) {
      // Fallback to PDF.js if Google Viewer fails
      final encoded = Uri.encodeComponent(raw);
      return 'https://mozilla.github.io/pdf.js/web/viewer.html?file=$encoded';
    }
    if (_isOffice(lower)) {
      // No Google Docs fallback per requirement; keep single viewer
      return null;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    
    // Check file type and use appropriate viewer
    final lower = widget.document.filePath.toLowerCase();
    if (lower.endsWith('.ppt') || lower.endsWith('.pptx') || 
        lower.endsWith('.doc') || lower.endsWith('.docx')) {
      _openWithNativeApp();
      return;
    }
    
    _initializeWebView();
  }

  Future<void> _openWithNativeApp() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use open_file package to open files with native apps
      final result = await OpenFile.open(widget.document.filePath);
      
      if (result.type != ResultType.done) {
        throw Exception('Failed to open file: ${result.message}');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to open file: $e';
        _isLoading = false;
      });
    }
  }

  IconData _getFileIcon(String filePath) {
    if (filePath.endsWith('.ppt') || filePath.endsWith('.pptx')) {
      return Icons.slideshow;
    } else if (filePath.endsWith('.doc') || filePath.endsWith('.docx')) {
      return Icons.description;
    }
    return Icons.insert_drive_file;
  }

  Color _getFileColor(String filePath) {
    if (filePath.endsWith('.ppt') || filePath.endsWith('.pptx')) {
      return Colors.orange[300]!;
    } else if (filePath.endsWith('.doc') || filePath.endsWith('.docx')) {
      return Colors.blue[300]!;
    }
    return Colors.grey[300]!;
  }

  String _getFileTypeName(String filePath) {
    if (filePath.endsWith('.ppt') || filePath.endsWith('.pptx')) {
      return 'PowerPoint';
    } else if (filePath.endsWith('.doc') || filePath.endsWith('.docx')) {
      return 'Word';
    }
    return 'Document';
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

    // Assign the controller first before using it
    _webViewController = controller;

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            final alt = !_usedAltViewer ? _altViewerUrl(widget.document.filePath) : null;
            if (alt != null) {
              setState(() {
                _isLoading = true;
                _error = null;
                _usedAltViewer = true;
              });
              _webViewController.loadRequest(Uri.parse(alt));
              return;
            }
            setState(() => _error = error.description);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      );

    final wrapped = _wrapUrlForPreview(widget.document.filePath);
    controller.loadRequest(Uri.parse(wrapped));
  }

  @override
  Widget build(BuildContext context) {
    final lower = widget.document.filePath.toLowerCase();
    final isOfficeFile = lower.endsWith('.ppt') || lower.endsWith('.pptx') || 
                        lower.endsWith('.doc') || lower.endsWith('.docx');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.docName),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
                _usedAltViewer = false;
              });
              if (isOfficeFile) {
                _openWithNativeApp();
              } else {
                _initializeWebView();
              }
            },
          ),
        ],
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
                    'Error loading document',
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
                      setState(() {
                        _isLoading = true;
                        _error = null;
                        _usedAltViewer = false;
                      });
                      if (isOfficeFile) {
                        _openWithNativeApp();
                      } else {
                        _initializeWebView();
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : isOfficeFile
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getFileIcon(lower),
                        size: 80,
                        color: _getFileColor(lower),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${_getFileTypeName(lower)} File Opened',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'The ${_getFileTypeName(lower).toLowerCase()} has been opened\nin your default application.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _openWithNativeApp();
                        },
                        child: const Text('Open Again'),
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
                                  'Loading document...',
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
