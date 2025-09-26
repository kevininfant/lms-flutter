import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_file/open_file.dart';
import '../models/scorm.dart';
import '../services/pdf_conversion_service.dart';
import '../services/permission_service.dart';
import '../services/document_progress_service.dart';

class DocumentViewerScreen extends StatefulWidget {
  final Document document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _isLoading = true;
  String? _error;
  String? _pdfPath;
  final PdfConversionService _pdfConverter = PdfConversionService();
  final PermissionService _permissionService = PermissionService();
  final DocumentProgressService _progressService = DocumentProgressService();
  int _currentPage = 1;
  int _totalPages = 1;
  Timer? _viewTimeTimer;

  @override
  void initState() {
    super.initState();
    _initializeDocumentViewer();
    _startDocumentTracking();
  }

  @override
  void dispose() {
    _progressService.stopTracking();
    _viewTimeTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeDocumentViewer() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Request storage permissions first
      final hasPermissions = await _permissionService.hasStoragePermissions();
      if (!hasPermissions) {
        final granted = await _permissionService.requestStoragePermissions();
        if (!granted) {
          setState(() {
            _error =
                'Storage permissions are required to view documents. Please grant permissions in app settings.';
            _isLoading = false;
          });
          return;
        }
      }

      final lower = widget.document.filePath.toLowerCase();

      // Check if it's a PDF file
      if (lower.endsWith('.pdf')) {
        setState(() {
          _pdfPath = widget.document.filePath;
          _isLoading = false;
        });
        return;
      }

      // Check if it's an Office file that can be converted to PDF
      if (_pdfConverter.canConvertToPdf(widget.document.filePath)) {
        await _convertAndPreviewOfficeFile();
        return;
      }

      // For other files, try to open with native app
      _openWithNativeApp();
    } catch (e) {
      setState(() {
        _error = 'Error initializing document viewer: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _convertAndPreviewOfficeFile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Convert Office file to PDF
      final pdfPath = await _pdfConverter.convertToPdf(
        widget.document.filePath,
      );

      if (pdfPath != null) {
        setState(() {
          _pdfPath = pdfPath;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to convert document to PDF';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error converting document: $e';
        _isLoading = false;
      });
    }
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

  /// Start document progress tracking
  void _startDocumentTracking() {
    final documentId = widget.document.docName
        .replaceAll(' ', '_')
        .toLowerCase();
    _progressService.startTracking(
      documentId: documentId,
      documentName: widget.document.docName,
      totalPages: _totalPages,
    );

    // Start view time timer to update every second
    _viewTimeTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _updateViewTime();
    });
  }

  /// Update document progress when page changes
  void _onPageChanged(int pageNumber) {
    setState(() {
      _currentPage = pageNumber;
    });
    _progressService.updateScrollPosition(0.0, pageNumber);
  }

  /// Update document view time
  void _updateViewTime() {
    _progressService.updateViewTime(
      Duration(seconds: DateTime.now().millisecondsSinceEpoch ~/ 1000),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.document.docName, style: TextStyle(fontSize: 16)),
            if (_totalPages > 1)
              Text(
                'Page $_currentPage of $_totalPages',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
                _pdfPath = null;
              });
              _initializeDocumentViewer();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorView();
    }

    if (_pdfPath != null) {
      return _buildPdfViewer();
    }

    if (_isLoading) {
      return _buildLoadingView();
    }

    return _buildNativeAppView();
  }

  Widget _buildPdfViewer() {
    // Check if it's a remote URL or local file
    if (_pdfPath!.startsWith('http://') || _pdfPath!.startsWith('https://')) {
      return SfPdfViewer.network(
        _pdfPath!,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          setState(() {
            _error = 'Failed to load PDF: ${details.error}';
          });
        },
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          setState(() {
            _totalPages = details.document.pages.count;
          });
          _progressService.updateTotalPages(_totalPages);
          _progressService.updateLoadingStatus('Loaded');
        },
        onPageChanged: (PdfPageChangedDetails details) {
          _onPageChanged(details.newPageNumber);
        },
      );
    } else {
      return SfPdfViewer.file(
        File(_pdfPath!),
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          setState(() {
            _error = 'Failed to load PDF: ${details.error}';
          });
        },
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          setState(() {
            _totalPages = details.document.pages.count;
          });
          _progressService.updateTotalPages(_totalPages);
          _progressService.updateLoadingStatus('Loaded');
        },
        onPageChanged: (PdfPageChangedDetails details) {
          _onPageChanged(details.newPageNumber);
        },
      );
    }
  }

  Widget _buildErrorView() {
    final isPermissionError = _error!.contains('permissions');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading document',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                    _pdfPath = null;
                  });
                  _initializeDocumentViewer();
                },
                child: const Text('Retry'),
              ),
              if (isPermissionError) ...[
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _permissionService.openSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Open Settings'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading document...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildNativeAppView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileIcon(widget.document.filePath),
            size: 64,
            color: _getFileColor(widget.document.filePath),
          ),
          const SizedBox(height: 16),
          Text(
            widget.document.docName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getFileTypeName(widget.document.filePath),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _openWithNativeApp();
            },
            child: const Text('Open with Native App'),
          ),
        ],
      ),
    );
  }
}
