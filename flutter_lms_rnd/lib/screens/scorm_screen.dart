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

class ScormScreen extends StatefulWidget {
  const ScormScreen({super.key});

  @override
  State<ScormScreen> createState() => _ScormScreenState();
}

class _ScormScreenState extends State<ScormScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _scormFiles = ['PRI.zip', 'scorm.zip'];
  final List<String> _h5pFiles = ['boardgame.h5p'];
  late final TabController _tabController;
  bool _isExtracting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SCORM Viewer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'SCORM'),
            Tab(text: 'H5P'),
            Tab(text: 'Docs'),
            Tab(text: 'Audio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScormTab(),
          _buildH5pTab(),
          _buildDocsTab(),
          _buildAudioTab(),
        ],
      ),
    );
  }

  Widget _buildScormTab() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available SCORM Files:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _scormFiles.length,
                    itemBuilder: (context, index) {
                      final fileName = _scormFiles[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(
                            Icons.folder_zip,
                            color: Colors.blue,
                          ),
                          title: Text(fileName),
                          subtitle: const Text('SCORM Package'),
                          trailing: _isExtracting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.play_arrow),
                          onTap: _isExtracting
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ScormPlayerPage(
                                        assetFileName: fileName,
                                      ),
                                    ),
                                  );
                                },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildH5pTab() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available H5P Files:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.public, color: Colors.purple),
                    title: const Text('Play online H5P (example)'),
                    subtitle: const Text('https://h5p.org/h5p/embed/612'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const H5pOnlinePage(
                            embedUrl: 'https://h5p.org/h5p/embed/612',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.public, color: Colors.purple),
                    title: const Text('Course Presentation'),
                    subtitle: const Text('https://h5p.org/h5p/embed/57130'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const H5pOnlinePage(
                            embedUrl: 'https://h5p.org/h5p/embed/57130',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.public, color: Colors.purple),
                    title: const Text('Accordion'),
                    subtitle: const Text('https://h5p.org/h5p/embed/6724'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const H5pOnlinePage(
                            embedUrl: 'https://h5p.org/h5p/embed/6724',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _h5pFiles.length,
                    itemBuilder: (context, index) {
                      final fileName = _h5pFiles[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(
                            Icons.extension,
                            color: Colors.green,
                          ),
                          title: Text(fileName),
                          subtitle: const Text('H5P Package'),
                          trailing: const Icon(Icons.play_arrow),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    H5pPlayerPage(assetFileName: fileName),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioTab() {
    const String song1 =
        'https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3';
    const String song2 =
        'https://commondatastorage.googleapis.com/codeskulptor-demos/riceracer_assets/fx/engine-3.ogg';
    const String song3 =
        'https://commondatastorage.googleapis.com/codeskulptor-assets/week7-button.m4a';

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  'Online audio preview:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.audiotrack, color: Colors.teal),
                    title: const Text('Sample Track 1 (MP3)'),
                    subtitle: const Text(song1),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AudioOnlinePage(
                            title: 'Track 1',
                            audioUrl: song1,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.audiotrack, color: Colors.teal),
                    title: const Text('Sample Track 2 (ogg)'),
                    subtitle: const Text(song2),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AudioOnlinePage(
                            title: 'Track 2',
                            audioUrl: song2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.audiotrack, color: Colors.teal),
                    title: const Text('Sample Track 3 (m4a)'),
                    subtitle: const Text(song3),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AudioOnlinePage(
                            title: 'Track 3',
                            audioUrl: song3,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocsTab() {
    // Example public URLs; replace with your own
    const String pdfUrl = 'https://icseindia.org/document/sample.pdf';
    const String docUrl =
        'https://file-examples.com/wp-content/storage/2017/02/file-sample_100kB.doc';
    const String docxUrl =
        'https://file-examples.com/wp-content/storage/2017/02/file-sample_500kB.docx';
    const String xlsUrl =
        'https://file-examples.com/wp-content/storage/2017/02/file_example_XLS_50.xls';
    const String txtUrl = 'https://www.w3.org/TR/PNG/iso_8859-1.txt';

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  'Preview online documents (no download):',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // DOCX/DOC preview via Office Online (no Google Docs)
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.description,
                      color: Colors.deepOrange,
                    ),
                    title: const Text('Open DOC/DOCX (viewer)'),
                    subtitle: const Text('Office Online'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DocWebPreviewPage(
                            url: docxUrl,
                            title: 'DOCX Preview',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // XLS/XLSX preview via Office Online (no Google Docs)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.grid_on, color: Colors.teal),
                    title: const Text('Open XLS/XLSX (viewer)'),
                    subtitle: const Text('Office Online'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DocWebPreviewPage(
                            url: xlsUrl,
                            title: 'Excel Preview',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                    ),
                    title: const Text('PDF sample (online)'),
                    subtitle: Text(pdfUrl),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DocWebPreviewPage(
                            url: pdfUrl,
                            title: 'PDF Preview',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.description, color: Colors.blue),
                    title: const Text('DOC sample (online)'),
                    subtitle: Text(docUrl),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DocWebPreviewPage(
                            url: docUrl,
                            title: 'DOC Preview',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.description,
                      color: Colors.indigo,
                    ),
                    title: const Text('DOCX sample (online)'),
                    subtitle: Text(docxUrl),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DocWebPreviewPage(
                            url: docxUrl,
                            title: 'DOCX Preview',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.grid_on, color: Colors.green),
                    title: const Text('XLS sample (online)'),
                    subtitle: Text(xlsUrl),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DocWebPreviewPage(
                            url: xlsUrl,
                            title: 'XLS Preview',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notes, color: Colors.brown),
                    title: const Text('TXT sample (online)'),
                    subtitle: Text(txtUrl),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DocWebPreviewPage(
                            url: txtUrl,
                            title: 'TXT Preview',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ScormPlayerPage extends StatefulWidget {
  const ScormPlayerPage({super.key, required this.assetFileName});

  final String assetFileName;

  @override
  State<ScormPlayerPage> createState() => _ScormPlayerPageState();
}

class _ScormPlayerPageState extends State<ScormPlayerPage> {
  late final WebViewController _webViewController;

  bool _isLoading = true;
  String? _error;
  bool _useLocalServer = true;
  HttpServer? _server;

  @override
  void initState() {
    super.initState();
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
    // Inline media playback configured via iOS creation params above

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
    _prepareAndLaunch();
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
        title: Text(widget.assetFileName),
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
          ? Center(child: Text(_error!))
          : Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x11000000),
                      child: Center(child: CircularProgressIndicator()),
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
        'scorm_extracted',
        widget.assetFileName.replaceAll('.zip', ''),
      );

      // Clean and re-create target dir
      final Directory extractDir = Directory(extractPath);
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create(recursive: true);

      // Extract from assets
      final ByteData data = await rootBundle.load(
        'assets/data/${widget.assetFileName}',
      );
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

      // Find manifest and resolve launch file
      final String? manifestPath = _findManifestFile(extractPath);
      String? launchPath;
      if (manifestPath != null) {
        launchPath = await _launchFromManifest(manifestPath);
      }
      launchPath ??= _findIndexFile(extractPath);

      if (launchPath == null) {
        throw Exception('No launchable HTML found');
      }
      // Optionally serve via local HTTP
      if (_useLocalServer) {
        await _server?.close(force: true);
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
      } else {
        await _webViewController.loadFile(launchPath);
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to launch SCORM: $e';
        _isLoading = false;
      });
    }
  }

  String? _findManifestFile(String root) {
    try {
      final List<FileSystemEntity> entries = Directory(
        root,
      ).listSync(recursive: true);
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
      final doc = xml.XmlDocument.parse(xmlString);

      final organizations = doc.findAllElements('organizations');
      if (organizations.isEmpty) return null;
      final orgsEl = organizations.first;
      final String? defaultOrgId = orgsEl.getAttribute('default');
      final Iterable<xml.XmlElement> orgs = doc.findAllElements('organization');
      xml.XmlElement? org;
      if (defaultOrgId != null) {
        for (final o in orgs) {
          if (o.getAttribute('identifier') == defaultOrgId) {
            org = o;
            break;
          }
        }
      }
      org ??= orgs.isNotEmpty ? orgs.first : null;
      if (org == null) return null;

      // Prefer the first top-level item with identifierref
      final items = org.findElements('item');
      String? identifierRef;
      for (final i in items) {
        final ref = i.getAttribute('identifierref');
        if (ref != null && ref.isNotEmpty) {
          identifierRef = ref;
          break;
        }
      }

      // Fallback: any resource with scormType="sco" or first resource
      final Iterable<xml.XmlElement> resources = doc.findAllElements(
        'resource',
      );
      xml.XmlElement? resource;
      if (identifierRef != null) {
        for (final r in resources) {
          if (r.getAttribute('identifier') == identifierRef) {
            resource = r;
            break;
          }
        }
      } else {
        for (final r in resources) {
          final scormType =
              r.getAttribute('adlcp:scormType') ?? r.getAttribute('scormType');
          if (scormType == 'sco') {
            resource = r;
            break;
          }
        }
      }
      resource ??= resources.isNotEmpty ? resources.first : null;
      if (resource == null) return null;

      final String? href = resource.getAttribute('href');
      if (href == null || href.isEmpty) return null;

      final String baseDir = path.dirname(manifestPath);
      final String launchPath = path.normalize(path.join(baseDir, href));
      if (File(launchPath).existsSync()) return launchPath;
      return null;
    } catch (e) {
      debugPrint('Manifest parse error: $e');
      return null;
    }
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

class H5pPlayerPage extends StatefulWidget {
  const H5pPlayerPage({super.key, required this.assetFileName});

  final String assetFileName;

  @override
  State<H5pPlayerPage> createState() => _H5pPlayerPageState();
}

class H5pOnlinePage extends StatefulWidget {
  const H5pOnlinePage({super.key, required this.embedUrl});

  final String embedUrl;

  @override
  State<H5pOnlinePage> createState() => _H5pOnlinePageState();
}

class _H5pOnlinePageState extends State<H5pOnlinePage> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
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
      ..loadRequest(Uri.parse(widget.embedUrl));

    _webViewController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('H5P Online')),
      body: _error != null
          ? Center(child: Text(_error!))
          : Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x11000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
    );
  }
}

class AudioOnlinePage extends StatefulWidget {
  const AudioOnlinePage({
    super.key,
    required this.title,
    required this.audioUrl,
  });

  final String title;
  final String audioUrl;

  @override
  State<AudioOnlinePage> createState() => _AudioOnlinePageState();
}

class _AudioOnlinePageState extends State<AudioOnlinePage> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final PlatformWebViewControllerCreationParams params =
        WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: <PlaybackMediaTypes>{},
          )
        : const PlatformWebViewControllerCreationParams();
    final controller = WebViewController.fromPlatformCreationParams(params);

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    final html = _buildAudioHtml(widget.audioUrl);
    final encoded = base64Encode(const Utf8Encoder().convert(html));

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
      ..loadRequest(Uri.parse('data:text/html;base64,$encoded'));

    _webViewController = controller;
  }

  String _buildAudioHtml(String url) {
    // Simple HTML5 audio player, provide multiple source types and avoid encoding URL in src
    final lower = url.toLowerCase();
    final isMp3 = lower.endsWith('.mp3');
    final isOgg = lower.endsWith('.ogg') || lower.endsWith('.oga');
    final isM4a = lower.endsWith('.m4a') || lower.endsWith('.aac');

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    body { margin: 0; padding: 16px; font-family: sans-serif; }
    .wrap { display:flex; height: 100vh; align-items:center; justify-content:center; }
    audio { width: 100%; max-width: 600px; }
  </style>
  <script>
    document.addEventListener('DOMContentLoaded', function(){
      var a = document.querySelector('audio');
      if (a) {
        // Try autoplay muted; user can still tap play if blocked by policy
        a.muted = true;
        a.play().catch(function(){});
      }
    });
  </script>
  <title>Audio</title>
  </head>
  <body>
    <div class="wrap">
      <audio controls preload="auto">
        ${isMp3 ? '<source src="$url" type="audio/mpeg" />' : ''}
        ${isOgg ? '<source src="$url" type="audio/ogg" />' : ''}
        ${isM4a ? '<source src="$url" type="audio/mp4" />' : ''}
        ${(!isMp3 && !isOgg && !isM4a) ? '<source src="$url" />' : ''}
        Your browser does not support the audio element.
      </audio>
    </div>
  </body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _error != null
          ? Center(child: Text(_error!))
          : Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x11000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
    );
  }
}

class DocWebPreviewPage extends StatefulWidget {
  const DocWebPreviewPage({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<DocWebPreviewPage> createState() => _DocWebPreviewPageState();
}

class _DocWebPreviewPageState extends State<DocWebPreviewPage> {
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
    final PlatformWebViewControllerCreationParams params =
        WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: <PlaybackMediaTypes>{},
          )
        : const PlatformWebViewControllerCreationParams();
    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            final alt = !_usedAltViewer ? _altViewerUrl(widget.url) : null;
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
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    final wrapped = _wrapUrlForPreview(widget.url);
    controller.loadRequest(Uri.parse(wrapped));
    _webViewController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _error != null
          ? Center(child: Text(_error!))
          : Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x11000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
    );
  }
}

// Removed native DOCX viewer in favor of online viewer for stability

// Removed ExcelNativePage; using Office Online viewer instead

class _H5pPlayerPageState extends State<H5pPlayerPage> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _error;
  HttpServer? _server;

  @override
  void initState() {
    super.initState();
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
    // Inline media playback configured via iOS creation params above

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
    _prepareAndLaunch();
  }

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.assetFileName)),
      body: _error != null
          ? Center(child: Text(_error!))
          : Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x11000000),
                      child: Center(child: CircularProgressIndicator()),
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
        widget.assetFileName.replaceAll('.h5p', ''),
      );

      final Directory extractDir = Directory(extractPath);
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create(recursive: true);

      final ByteData data = await rootBundle.load(
        'assets/h5p/${widget.assetFileName}',
      );
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
      final List<FileSystemEntity> files = Directory(
        root,
      ).listSync(recursive: true);
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
