import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'meeting_setup_screen.dart';

class MeetingNavScreen extends StatefulWidget {
  const MeetingNavScreen({super.key});

  @override
  State<MeetingNavScreen> createState() => _MeetingNavScreenState();
}

class _MeetingNavScreenState extends State<MeetingNavScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _error;
  String _currentPlatform = '';
  int _selectedIndex = 0;

  final List<MeetingPlatform> _platforms = [
    MeetingPlatform(
      name: 'App Meeting',
      displayName: 'App Video Meeting',
      description: 'Start or join meetings using our built-in video calling',
      icon: Icons.video_call_rounded,
      color: Colors.green,
      type: 'app_meeting',
    ),
    MeetingPlatform(
      name: 'Google Meet',
      displayName: 'Google Meet',
      description: 'Start or join Google Meet sessions',
      icon: Icons.video_call,
      color: Colors.blue,
      type: 'google_meet',
      url: 'https://meet.google.com/landing',
    ),
    MeetingPlatform(
      name: 'Microsoft Teams',
      displayName: 'Microsoft Teams',
      description: 'Access Microsoft Teams meetings',
      icon: Icons.groups,
      color: Colors.purple,
      type: 'teams',
      url: 'https://teams.microsoft.com/',
    ),
    MeetingPlatform(
      name: 'Zoom',
      displayName: 'Zoom',
      description: 'Join Zoom video conferences',
      icon: Icons.videocam,
      color: Colors.blue.shade600,
      type: 'zoom',
      url: 'https://zoom.us/',
    ),
  ];

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
            debugPrint(
              'WebView Error: ${error.errorCode} - ${error.description}',
            );
            setState(() {
              _error = 'Failed to load meeting platform: ${error.description}';
              _isLoading = false;
            });
          },
          onPageFinished: (url) {
            debugPrint('Meeting page loaded: $url');
            setState(() {
              _isLoading = false;
              _error = null;
            });
          },
          onNavigationRequest: (request) {
            debugPrint('Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      );

    _webViewController = controller;
  }

  void _loadPlatform(MeetingPlatform platform) {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPlatform = platform.type;
    });

    if (platform.type == 'app_meeting') {
      // Navigate to our app meeting setup
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const MeetingSetupScreen()),
      );
      return;
    }

    if (platform.url != null) {
      _webViewController.loadRequest(Uri.parse(platform.url!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentPlatform.isEmpty
              ? 'Meeting Platforms'
              : _platforms
                    .firstWhere((p) => p.type == _currentPlatform)
                    .displayName,
        ),
        backgroundColor: _currentPlatform.isEmpty
            ? Colors.blue
            : _platforms.firstWhere((p) => p.type == _currentPlatform).color,
        foregroundColor: Colors.white,
        actions: [
          if (_currentPlatform.isNotEmpty && _currentPlatform != 'app_meeting')
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final platform = _platforms.firstWhere(
                  (p) => p.type == _currentPlatform,
                );
                _loadPlatform(platform);
              },
            ),
        ],
      ),
      body: _currentPlatform.isEmpty
          ? _buildPlatformSelection()
          : _currentPlatform == 'app_meeting'
          ? _buildAppMeetingView()
          : _buildWebView(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildPlatformSelection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.purple.shade400],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.video_call, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Choose Your Meeting Platform',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Select a platform to start your meeting',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ..._platforms.map(
                (platform) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPlatformCard(platform),
                ),
              ),
              const SizedBox(height: 20), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformCard(MeetingPlatform platform) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _loadPlatform(platform),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                platform.color.withOpacity(0.1),
                platform.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: platform.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(platform.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      platform.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: platform.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      platform.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: platform.color.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: platform.color.withOpacity(0.6),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppMeetingView() {
    return Container(
      decoration: BoxDecoration(
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
            Icon(Icons.video_call_rounded, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'App Video Meeting',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Use the navigation below to access meeting features',
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading)
          Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading meeting platform...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        if (_error != null)
          Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading meeting platform',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final platform = _platforms.firstWhere(
                        (p) => p.type == _currentPlatform,
                      );
                      _loadPlatform(platform);
                    },
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentPlatform = '';
                        _error = null;
                      });
                    },
                    child: const Text('Back to Platform Selection'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index < _platforms.length) {
            setState(() {
              _selectedIndex = index;
              _loadPlatform(_platforms[index]);
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: _platforms.map((platform) {
          return BottomNavigationBarItem(
            icon: Icon(platform.icon),
            label: platform.name.length > 10
                ? platform.name.substring(0, 10) + '...'
                : platform.name,
          );
        }).toList(),
      ),
    );
  }
}

class MeetingPlatform {
  final String name;
  final String displayName;
  final String description;
  final IconData icon;
  final Color color;
  final String type;
  final String? url;

  MeetingPlatform({
    required this.name,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    this.url,
  });
}
