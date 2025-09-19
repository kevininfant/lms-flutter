import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_file/open_file.dart';
import '../models/scorm.dart';
import '../services/pdf_conversion_service.dart';
import '../services/permission_service.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeDocumentViewer();
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

  @override
  Widget build(BuildContext context) {
    final lower = widget.document.filePath.toLowerCase();
    final isOfficeFile = _pdfConverter.canConvertToPdf(
      widget.document.filePath,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.docName),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (_pdfPath != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Download functionality coming soon'),
                  ),
                );
              },
            ),
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
          Text(
            'Loading document...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeAppView() {
    final lower = widget.document.filePath.toLowerCase();
    final isOfficeFile = _pdfConverter.canConvertToPdf(
      widget.document.filePath,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getFileIcon(lower), size: 80, color: _getFileColor(lower)),
          const SizedBox(height: 20),
          Text(
            '${_getFileTypeName(lower)} File',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isOfficeFile
                ? 'The ${_getFileTypeName(lower).toLowerCase()} has been opened\nin your default application.'
                : 'This file type cannot be previewed directly.\nPlease download and open with a compatible app.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _openWithNativeApp();
            },
            child: Text(isOfficeFile ? 'Open Again' : 'Download File'),
          ),
        ],
      ),
    );
  }
}
