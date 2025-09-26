import 'package:flutter/material.dart';
import '../services/document_progress_service.dart';

/// Test widget to demonstrate document progress tracking every 5 seconds
class DocumentTrackingTest extends StatefulWidget {
  const DocumentTrackingTest({super.key});

  @override
  State<DocumentTrackingTest> createState() => _DocumentTrackingTestState();
}

class _DocumentTrackingTestState extends State<DocumentTrackingTest> {
  final DocumentProgressService _progressService = DocumentProgressService();
  int _currentPage = 1;
  int _totalPages = 10;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    // Set up alert callback to show tracking messages
    _progressService.onShowAlert = (message) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    };
  }

  @override
  void dispose() {
    _progressService.stopTracking();
    super.dispose();
  }

  void _startTracking() {
    _progressService.startTracking(
      documentId: 'test_document',
      documentName: 'Test Document',
      totalPages: _totalPages,
    );
    setState(() {
      _isTracking = true;
    });
  }

  void _stopTracking() {
    _progressService.stopTracking();
    setState(() {
      _isTracking = false;
    });
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
      _progressService.updateScrollPosition(0.0, _currentPage);
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _progressService.updateScrollPosition(0.0, _currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Tracking Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document Progress Tracking Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text('Current Page: $_currentPage of $_totalPages'),
                    const SizedBox(height: 8),
                    Text(
                      'Tracking Status: ${_isTracking ? "Active" : "Inactive"}',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isTracking
                              ? _stopTracking
                              : _startTracking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTracking
                                ? Colors.red
                                : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            _isTracking ? 'Stop Tracking' : 'Start Tracking',
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _previousPage,
                          child: const Text('Previous Page'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _nextPage,
                          child: const Text('Next Page'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Console Output (Every 5 seconds)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check the debug console for detailed tracking logs that appear every 5 seconds when tracking is active.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '📄 ===== DOCUMENT CONSOLE DATA (Every 5s) =====\n'
                        '⏰ Time: [timestamp]\n'
                        '📄 Document: Test Document\n'
                        '📖 Page: [current] / [total]\n'
                        '📊 Progress: [percentage]%\n'
                        '👁️ Status: Viewing\n'
                        '📥 Loading: Loaded\n'
                        '🔄 Scrolling: No\n'
                        '⏱️ View Time: [duration]\n'
                        '📈 Total View Time: [duration]\n'
                        '==========================================',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
