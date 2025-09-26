import 'package:flutter/material.dart';
import 'repositories/scorm_repository.dart';

class TestScormLoading extends StatefulWidget {
  const TestScormLoading({super.key});

  @override
  State<TestScormLoading> createState() => _TestScormLoadingState();
}

class _TestScormLoadingState extends State<TestScormLoading> {
  final ScormRepository _repository = ScormRepository();
  List<String> _logs = [];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _testScormLoading() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    try {
      _addLog('🔍 Starting SCORM loading test...');

      _addLog('📦 Loading course data...');
      final courseData = await _repository.loadCourseData();
      _addLog('✅ Course data loaded successfully');

      _addLog('📦 Found ${courseData.scorms.length} SCORM packages:');
      for (final scorm in courseData.scorms) {
        _addLog('  - ${scorm.scormName} (${scorm.scormFileLink})');
      }

      _addLog('📦 Found ${courseData.videos.length} videos');
      _addLog('📦 Found ${courseData.music.length} music files');
      _addLog('📦 Found ${courseData.h5p.length} H5P activities');
      _addLog('📦 Found ${courseData.docs.length} documents');

      _addLog('✅ Test completed successfully!');
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SCORM Loading Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testScormLoading,
              child: _isLoading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Testing...'),
                      ],
                    )
                  : const Text('Test SCORM Loading'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test Logs:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _logs.isEmpty
                    ? const Text(
                        'No logs yet. Click "Test SCORM Loading" to start.',
                        style: TextStyle(color: Colors.grey),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              log,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
