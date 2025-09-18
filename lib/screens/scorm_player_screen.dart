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
import 'package:xml/xml.dart' as xml;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_static/shelf_static.dart' as shelf_static;
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../models/scorm.dart';

class ScormPlayerScreen extends StatefulWidget {
  final Scorm scorm;

  const ScormPlayerScreen({super.key, required this.scorm});

  @override
  State<ScormPlayerScreen> createState() => _ScormPlayerScreenState();
}

class _ScormPlayerScreenState extends State<ScormPlayerScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _error;
  bool _useLocalServer = true;
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
            
            // Handle cleartext HTTP error
            if (error.errorCode == -1 && error.description.contains('ERR_CLEARTEXT_NOT_PERMITTED')) {
              debugPrint('❌ Cleartext HTTP error detected. Trying direct file loading...');
              _handleCleartextError();
            }
          },
          onPageFinished: (url) {
            debugPrint('✅ WebView page loaded: $url');
            controller.runJavaScript(
              "document.querySelectorAll('video, audio').forEach(function(m){try{m.muted=true; m.play().catch(function(){});}catch(e){}});",
            );
          },
          onNavigationRequest: (request) {
            debugPrint('🌐 Navigation request: ${request.url}');
            return NavigationDecision.navigate;
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

  Future<void> _handleCleartextError() async {
    debugPrint('🔄 Attempting fallback to direct file loading...');
    
    try {
      // Close the server
      await _server?.close(force: true);
      _server = null;
      
      // Find the launch file again
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String extractPath = path.join(
        appDocDir.path,
        'scorm_extracted',
        widget.scorm.scormName.replaceAll(' ', '_'),
      );
      
      final String? manifestPath = _findManifestFile(extractPath);
      String? launchPath;
      if (manifestPath != null) {
        launchPath = await _launchFromManifest(manifestPath);
      }
      launchPath ??= _findIndexFile(extractPath);
      
      if (launchPath != null) {
        debugPrint('📄 Loading SCORM content directly from: $launchPath');
        await _webViewController.loadFile(launchPath);
      } else {
        throw Exception('No launchable HTML found for direct loading');
      }
    } catch (e) {
      debugPrint('❌ Direct file loading also failed: $e');
      if (mounted) {
        setState(() {
          _error = 'Both server and direct loading failed: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scorm.scormName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              const Text('Local server'),
              Switch(
                value: _useLocalServer,
                onChanged: (v) async {
                  setState(() {
                    _useLocalServer = v;
                    _isLoading = true;
                    _error = null;
                  });
                  await _prepareAndLaunch();
                },
              ),
            ],
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                      'Error loading SCORM package',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _prepareAndLaunch();
                          },
                          child: const Text('Retry'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _useLocalServer = !_useLocalServer;
                            });
                            _prepareAndLaunch();
                          },
                          child: Text(_useLocalServer ? 'Try Direct' : 'Try Server'),
                        ),
                      ],
                    ),
                  ],
                ),
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
                              'Loading SCORM package...',
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
      debugPrint('🚀 Starting SCORM initialization...');
      debugPrint('📦 SCORM File: ${widget.scorm.scormFileLink}');
      
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String extractPath = path.join(
        appDocDir.path,
        'scorm_extracted',
        widget.scorm.scormName.replaceAll(' ', '_'),
      );

      debugPrint('📁 Extract Path: $extractPath');

      // Clean and re-create target dir
      final Directory extractDir = Directory(extractPath);
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create(recursive: true);

      debugPrint('📦 Step 1: Extracting ${widget.scorm.scormFileLink}...');
      
      // Extract from assets
      final ByteData data = await rootBundle.load(widget.scorm.scormFileLink);
      final Uint8List bytes = data.buffer.asUint8List();
      debugPrint('✅ Asset loaded: ${bytes.length} bytes');
      
      final Archive archive = ZipDecoder().decodeBytes(bytes);
      int extractedFiles = 0;
      
      for (final ArchiveFile f in archive) {
        final String outPath = path.join(extractPath, f.name);
        if (f.isFile) {
          final Directory dir = Directory(path.dirname(outPath));
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          final File outFile = File(outPath);
          await outFile.writeAsBytes(f.content as List<int>);
          extractedFiles++;
        }
      }
      
      debugPrint('✅ Step 1 Complete: Extracted $extractedFiles files');

      // Find manifest and resolve launch file
      debugPrint('🔍 Step 1.1: Locating imsmanifest.xml...');
      final String? manifestPath = _findManifestFile(extractPath);
      String? launchPath;
      
      if (manifestPath != null) {
        debugPrint('✅ Found imsmanifest.xml at: $manifestPath');
        debugPrint('📋 Step 1.2: Parsing imsmanifest.xml...');
        launchPath = await _launchFromManifest(manifestPath);
      } else {
        debugPrint('⚠️ No manifest found, searching for index files...');
      }
      
      launchPath ??= _findIndexFile(extractPath);

      if (launchPath == null) {
        throw Exception('No launchable HTML found');
      }
      
      debugPrint('🎯 Found launch file: $launchPath');

      // Optionally serve via local HTTP
      if (_useLocalServer) {
        debugPrint('🌐 Step 2: Starting local server...');
        await _server?.close(force: true);
        
        try {
          final handler = shelf.Pipeline()
              .addMiddleware(shelf.logRequests())
              .addHandler(
                shelf_static.createStaticHandler(
                  extractPath,
                  defaultDocument: 'index.html',
                  serveFilesOutsidePath: false,
                ),
              );
          
          // Try to bind to a specific port range to avoid conflicts
          HttpServer? server;
          for (int port = 8080; port <= 8090; port++) {
            try {
              server = await shelf_io.serve(
                handler,
                InternetAddress.loopbackIPv4,
                port,
              );
              debugPrint('✅ Step 2 Complete: Server started at http://localhost:$port');
              _server = server;
              break;
            } catch (e) {
              debugPrint('⚠️ Port $port busy, trying next...');
              continue;
            }
          }
          
          if (_server == null) {
            throw Exception('Could not start server on any port 8080-8090');
          }

          final String relative = path
              .relative(launchPath, from: extractPath)
              .replaceAll('\\', '/');
          final Uri url = Uri.parse('http://127.0.0.1:${_server!.port}/$relative');
          
          debugPrint('📄 Step 3: Loading SCORM content...');
          debugPrint('🌐 Loading: $url');
          await _webViewController.loadRequest(url);
        } catch (e) {
          debugPrint('❌ Server setup failed: $e');
          debugPrint('🔄 Falling back to direct file loading...');
          await _webViewController.loadFile(launchPath);
        }
      } else {
        debugPrint('📄 Step 3: Loading SCORM content directly...');
        await _webViewController.loadFile(launchPath);
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ SCORM Launch Error: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Failed to launch SCORM: $e';
        _isLoading = false;
      });
    }
  }

  String? _findManifestFile(String root) {
    try {
      final List<FileSystemEntity> entries = Directory(root).listSync(recursive: true);
      for (final e in entries) {
        if (e is File &&
            path.basename(e.path).toLowerCase() == 'imsmanifest.xml') {
          return e.path;
        }
      }
    } catch (e) {
      debugPrint('Manifest search error: $e');
    }
    return null;
  }

  Future<String?> _launchFromManifest(String manifestPath) async {
    try {
      final String xmlString = await File(manifestPath).readAsString();
      debugPrint('📄 Manifest content length: ${xmlString.length} characters');
      debugPrint('📄 Manifest content preview: ${xmlString.length > 200 ? xmlString.substring(0, 200) + '...' : xmlString}');
      
      final doc = xml.XmlDocument.parse(xmlString);
      debugPrint('✅ Manifest structure validated');

      // Get the root element to check for SCORM version
      final root = doc.rootElement;
      final String? scormVersion = root.getAttribute('version');
      debugPrint('📋 SCORM Version: ${scormVersion ?? 'Not specified'}');

      // Find organizations element
      final organizations = doc.findAllElements('organizations');
      if (organizations.isEmpty) {
        debugPrint('❌ No organizations found in manifest');
        return null;
      }
      
      final orgsEl = organizations.first;
      final String? defaultOrgId = orgsEl.getAttribute('default');
      debugPrint('📚 Default organization ID: ${defaultOrgId ?? 'Not specified'}');
      
      // Find all organizations
      final Iterable<xml.XmlElement> orgs = doc.findAllElements('organization');
      debugPrint('📚 Found ${orgs.length} organizations in manifest');
      
      // Log all organization details
      for (final org in orgs) {
        final orgId = org.getAttribute('identifier');
        final orgTitle = org.findElements('title').isNotEmpty 
            ? org.findElements('title').first.innerText 
            : 'No title';
        debugPrint('  - Organization: $orgId ($orgTitle)');
      }
      
      // Select the organization to use
      xml.XmlElement? selectedOrg;
      if (defaultOrgId != null && defaultOrgId.isNotEmpty) {
        debugPrint('🎯 Looking for default organization: $defaultOrgId');
        for (final o in orgs) {
          if (o.getAttribute('identifier') == defaultOrgId) {
            selectedOrg = o;
            debugPrint('✅ Found default organization');
            break;
          }
        }
      }
      
      // Fallback to first organization if default not found
      if (selectedOrg == null) {
        selectedOrg = orgs.isNotEmpty ? orgs.first : null;
        debugPrint('🔄 Using first organization as fallback');
      }
      
      if (selectedOrg == null) {
        debugPrint('❌ No organization found');
        return null;
      }

      // Find the launchable item in the organization
      final String? launchableResourceId = _findLaunchableItem(selectedOrg);
      if (launchableResourceId == null) {
        debugPrint('❌ No launchable item found in organization');
        return null;
      }

      debugPrint('🎯 Found launchable resource ID: $launchableResourceId');

      // Find the resource with the matching identifier
      final Iterable<xml.XmlElement> resources = doc.findAllElements('resource');
      debugPrint('📚 Found ${resources.length} resources in manifest');
      
      // Log all resources
      for (final res in resources) {
        final resId = res.getAttribute('identifier');
        final resHref = res.getAttribute('href');
        final scormType = res.getAttribute('adlcp:scormType') ?? res.getAttribute('scormType');
        debugPrint('  - Resource: $resId -> $resHref (type: ${scormType ?? 'unspecified'})');
      }
      
      xml.XmlElement? targetResource;
      for (final r in resources) {
        if (r.getAttribute('identifier') == launchableResourceId) {
          targetResource = r;
          debugPrint('✅ Found matching resource');
          break;
        }
      }
      
      if (targetResource == null) {
        debugPrint('❌ No resource found with identifier: $launchableResourceId');
        return null;
      }

      final String? href = targetResource.getAttribute('href');
      if (href == null || href.isEmpty) {
        debugPrint('❌ No href found in resource');
        return null;
      }
      
      debugPrint('🎯 Found launch file: $href');

      final String baseDir = path.dirname(manifestPath);
      final String launchPath = path.normalize(path.join(baseDir, href));
      debugPrint('📁 Full launch path: $launchPath');
      
      if (File(launchPath).existsSync()) {
        debugPrint('✅ Launch file exists');
        return launchPath;
      } else {
        debugPrint('❌ Launch file does not exist');
        return null;
      }
    } catch (e) {
      debugPrint('Manifest parse error: $e');
      return null;
    }
  }

  String? _findLaunchableItem(xml.XmlElement organization) {
    debugPrint('🔍 Searching for launchable item in organization...');
    
    // Get all items in the organization
    final items = organization.findElements('item');
    debugPrint('📋 Found ${items.length} items in organization');
    
    // Log all items
    for (final item in items) {
      final itemId = item.getAttribute('identifier');
      final itemTitle = item.findElements('title').isNotEmpty 
          ? item.findElements('title').first.innerText 
          : 'No title';
      final identifierRef = item.getAttribute('identifierref');
      debugPrint('  - Item: $itemId ($itemTitle) -> $identifierRef');
    }
    
    // Look for the first item with an identifierref (launchable item)
    for (final item in items) {
      final identifierRef = item.getAttribute('identifierref');
      if (identifierRef != null && identifierRef.isNotEmpty) {
        debugPrint('✅ Found launchable item with identifierref: $identifierRef');
        return identifierRef;
      }
    }
    
    // If no item with identifierref found, look for nested items
    debugPrint('🔄 No top-level launchable items found, checking nested items...');
    for (final item in items) {
      final nestedItems = item.findElements('item');
      for (final nestedItem in nestedItems) {
        final identifierRef = nestedItem.getAttribute('identifierref');
        if (identifierRef != null && identifierRef.isNotEmpty) {
          debugPrint('✅ Found nested launchable item with identifierref: $identifierRef');
          return identifierRef;
        }
      }
    }
    
    debugPrint('❌ No launchable items found');
    return null;
  }

  String? _findIndexFile(String extractedPath) {
    final Directory dir = Directory(extractedPath);
    final List<String> possibleFiles = [
      'index.html',
      'index.htm',
      'start.html',
      'launch.html',
      'scorm.html',
      'main.html',
    ];
    for (final String fileName in possibleFiles) {
      final File file = File(path.join(extractedPath, fileName));
      if (file.existsSync()) {
        return file.path;
      }
    }
    try {
      final List<FileSystemEntity> files = dir.listSync(recursive: true);
      for (final FileSystemEntity file in files) {
        if (file is File &&
            path.extension(file.path).toLowerCase() == '.html') {
          return file.path;
        }
      }
    } catch (e) {
      debugPrint('Error searching for HTML files: $e');
    }
    return null;
  }
}
