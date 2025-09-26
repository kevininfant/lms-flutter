import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SimpleVideoMeetingScreen extends StatefulWidget {
  final String meetingId;
  final String? userName;

  const SimpleVideoMeetingScreen({
    super.key,
    required this.meetingId,
    this.userName,
  });

  @override
  State<SimpleVideoMeetingScreen> createState() =>
      _SimpleVideoMeetingScreenState();
}

class _SimpleVideoMeetingScreenState extends State<SimpleVideoMeetingScreen> {
  // UI state
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerEnabled = true;
  bool _isConnecting = false;
  bool _isConnected = false;
  String _connectionStatus = 'Initializing...';
  Timer? _connectionTimer;

  // Meeting info
  final List<String> _participants = [];

  @override
  void initState() {
    super.initState();
    _initializeMeeting();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeMeeting() async {
    try {
      setState(() {
        _connectionStatus = 'Requesting permissions...';
      });

      // Request camera and microphone permissions
      final cameraStatus = await Permission.camera.request();
      final microphoneStatus = await Permission.microphone.request();

      if (cameraStatus != PermissionStatus.granted ||
          microphoneStatus != PermissionStatus.granted) {
        setState(() {
          _connectionStatus = 'Permissions denied';
        });
        _showPermissionDialog();
        return;
      }

      setState(() {
        _connectionStatus = 'Initializing meeting...';
        _isConnecting = true;
      });

      // Simulate connection process
      _simulateConnection();
    } catch (e) {
      setState(() {
        _connectionStatus = 'Error: $e';
      });
      _showErrorDialog('Failed to initialize meeting: $e');
    }
  }

  void _simulateConnection() {
    _connectionTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isConnected = true;
          _connectionStatus = 'Connected to meeting';
        });
      }
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Camera and microphone permissions are required for video meetings. Please grant permissions in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isMuted ? 'Microphone muted' : 'Microphone unmuted'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isVideoEnabled ? 'Video enabled' : 'Video disabled'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerEnabled = !_isSpeakerEnabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSpeakerEnabled ? 'Speaker enabled' : 'Speaker disabled',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _switchCamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera switched'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _leaveMeeting() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Meeting'),
        content: const Text('Are you sure you want to leave this meeting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Meeting: ${widget.meetingId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showMeetingInfo();
            },
          ),
        ],
      ),
      body: _buildMeetingBody(),
    );
  }

  Widget _buildMeetingBody() {
    if (_isConnecting) {
      return _buildConnectingView();
    }

    return Stack(
      children: [
        // Main video area
        _buildVideoArea(),
        // Connection status
        _buildConnectionStatus(),
        // Meeting controls
        _buildMeetingControls(),
      ],
    );
  }

  Widget _buildConnectingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            _connectionStatus,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            'Meeting ID: ${widget.meetingId}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: _isConnected
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Video Meeting Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Connected to meeting',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              color: Colors.grey[900],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Waiting for other participants...',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildConnectionStatus() {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isConnected ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _connectionStatus,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Local video preview
            Container(
              width: 120,
              height: 90,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green.shade400, Colors.blue.shade400],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 32, color: Colors.white),
                    SizedBox(height: 4),
                    Text(
                      'You',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  isActive: !_isMuted,
                  onPressed: _toggleMute,
                ),
                _buildControlButton(
                  icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  isActive: _isVideoEnabled,
                  onPressed: _toggleVideo,
                ),
                _buildControlButton(
                  icon: Icons.switch_camera,
                  isActive: true,
                  onPressed: _switchCamera,
                ),
                _buildControlButton(
                  icon: _isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
                  isActive: _isSpeakerEnabled,
                  onPressed: _toggleSpeaker,
                ),
                _buildControlButton(
                  icon: Icons.call_end,
                  isActive: false,
                  isEndCall: true,
                  onPressed: _leaveMeeting,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    bool isEndCall = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isEndCall
              ? Colors.red
              : isActive
              ? Colors.white.withOpacity(0.2)
              : Colors.red.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  void _showMeetingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meeting Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meeting ID: ${widget.meetingId}'),
            const SizedBox(height: 8),
            Text('Participants: ${_participants.length + 1}'),
            const SizedBox(height: 8),
            Text('Status: ${_isConnected ? 'Connected' : 'Connecting'}'),
            const SizedBox(height: 8),
            Text('User: ${widget.userName ?? 'Anonymous'}'),
            const SizedBox(height: 8),
            const Text('Platform: Cross-platform compatible'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
