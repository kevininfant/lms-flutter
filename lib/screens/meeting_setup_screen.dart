import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'simple_video_meeting_screen.dart';

class MeetingSetupScreen extends StatefulWidget {
  const MeetingSetupScreen({super.key});

  @override
  State<MeetingSetupScreen> createState() => _MeetingSetupScreenState();
}

class _MeetingSetupScreenState extends State<MeetingSetupScreen> {
  final TextEditingController _meetingIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final FocusNode _meetingIdFocus = FocusNode();
  final FocusNode _userNameFocus = FocusNode();

  bool _isCreatingMeeting = false;
  bool _isJoiningMeeting = false;

  @override
  void initState() {
    super.initState();
    _generateRandomMeetingId();
  }

  @override
  void dispose() {
    _meetingIdController.dispose();
    _userNameController.dispose();
    _meetingIdFocus.dispose();
    _userNameFocus.dispose();
    super.dispose();
  }

  void _generateRandomMeetingId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final meetingId = List.generate(9, (index) {
      final charIndex = (random + index) % chars.length;
      return chars[charIndex];
    }).join();

    _meetingIdController.text = meetingId;
  }

  void _createMeeting() {
    if (_userNameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your name');
      return;
    }

    setState(() {
      _isCreatingMeeting = true;
    });

    // Simulate meeting creation delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _joinMeeting(_meetingIdController.text.trim());
      }
    });
  }

  void _joinMeeting(String meetingId) {
    if (meetingId.isEmpty) {
      _showErrorDialog('Please enter a meeting ID');
      return;
    }

    if (_userNameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your name');
      return;
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => SimpleVideoMeetingScreen(
              meetingId: meetingId,
              userName: _userNameController.text.trim(),
            ),
          ),
        )
        .then((_) {
          setState(() {
            _isCreatingMeeting = false;
            _isJoiningMeeting = false;
          });
        });
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

  void _copyMeetingId() {
    Clipboard.setData(ClipboardData(text: _meetingIdController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meeting ID copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Video Meeting'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Icon(Icons.video_call, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Start or Join a Meeting',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with others through high-quality video calls',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // User Name Input
            _buildInputField(
              controller: _userNameController,
              focusNode: _userNameFocus,
              label: 'Your Name',
              hint: 'Enter your display name',
              icon: Icons.person,
              isRequired: true,
            ),
            const SizedBox(height: 20),

            // Meeting ID Input
            _buildInputField(
              controller: _meetingIdController,
              focusNode: _meetingIdFocus,
              label: 'Meeting ID',
              hint: 'Enter or generate meeting ID',
              icon: Icons.meeting_room,
              isRequired: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: _copyMeetingId,
                tooltip: 'Copy Meeting ID',
              ),
            ),
            const SizedBox(height: 10),

            // Generate new meeting ID button
            TextButton.icon(
              onPressed: _generateRandomMeetingId,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate New Meeting ID'),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            _buildActionButton(
              title: 'Create Meeting',
              subtitle: 'Start a new meeting',
              icon: Icons.add,
              color: Colors.green,
              isLoading: _isCreatingMeeting,
              onPressed: _createMeeting,
            ),
            const SizedBox(height: 15),

            _buildActionButton(
              title: 'Join Meeting',
              subtitle: 'Join an existing meeting',
              icon: Icons.login,
              color: Colors.blue,
              isLoading: _isJoiningMeeting,
              onPressed: () {
                setState(() {
                  _isJoiningMeeting = true;
                });
                _joinMeeting(_meetingIdController.text.trim());
              },
            ),
            const SizedBox(height: 30),

            // Features
            _buildFeaturesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(color: Colors.red.shade600, fontSize: 16),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                      : Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meeting Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.videocam,
            title: 'HD Video',
            description: 'High-quality video calls',
          ),
          _buildFeatureItem(
            icon: Icons.mic,
            title: 'Clear Audio',
            description: 'Crystal clear audio quality',
          ),
          _buildFeatureItem(
            icon: Icons.security,
            title: 'Secure',
            description: 'End-to-end encrypted meetings',
          ),
          _buildFeatureItem(
            icon: Icons.devices,
            title: 'Cross Platform',
            description: 'Works on all devices',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.blue.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
