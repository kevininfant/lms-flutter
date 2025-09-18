import 'dart:io';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

class ScormTest {
  static Future<bool> testScormFile(String assetPath) async {
    try {
      print('🧪 Testing SCORM file: $assetPath');
      
      // Test 1: Load asset
      print('📦 Step 1: Loading asset...');
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List();
      print('✅ Asset loaded: ${bytes.length} bytes');
      
      if (bytes.isEmpty) {
        print('❌ Asset is empty');
        return false;
      }
      
      // Test 2: Decode ZIP
      print('📦 Step 2: Decoding ZIP...');
      final Archive archive = ZipDecoder().decodeBytes(bytes);
      print('✅ ZIP decoded: ${archive.length} files');
      
      if (archive.isEmpty) {
        print('❌ ZIP is empty');
        return false;
      }
      
      // Test 3: Extract to temp directory
      print('📦 Step 3: Extracting files...');
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory tempDir = Directory('${appDir.path}/scorm_test');
      
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      await tempDir.create(recursive: true);
      
      int extractedFiles = 0;
      for (final ArchiveFile file in archive) {
        if (file.isFile) {
          final String outPath = '${tempDir.path}/${file.name}';
          final File outFile = File(outPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          extractedFiles++;
        }
      }
      
      print('✅ Extracted $extractedFiles files');
      
      // Test 4: Look for manifest and parse it
      print('📋 Step 4: Looking for manifest...');
      final List<FileSystemEntity> entries = tempDir.listSync(recursive: true);
      bool foundManifest = false;
      bool foundHtml = false;
      String? manifestPath;
      
      for (final entry in entries) {
        if (entry is File) {
          final fileName = entry.path.split('/').last.toLowerCase();
          if (fileName == 'imsmanifest.xml') {
            foundManifest = true;
            manifestPath = entry.path;
            print('✅ Found imsmanifest.xml at: ${entry.path}');
          }
          if (fileName.endsWith('.html')) {
            foundHtml = true;
            print('✅ Found HTML file: ${entry.path}');
          }
        }
      }
      
      if (!foundManifest) {
        print('⚠️ No manifest found');
      } else {
        // Test manifest parsing
        print('📋 Step 5: Testing manifest parsing...');
        await _testManifestParsing(manifestPath!);
      }
      
      if (!foundHtml) {
        print('⚠️ No HTML files found');
      }
      
      // Cleanup
      await tempDir.delete(recursive: true);
      
      print('✅ SCORM test completed successfully');
      return true;
      
    } catch (e) {
      print('❌ SCORM test failed: $e');
      return false;
    }
  }
  
  static Future<void> testAllScormFiles() async {
    print('🧪 Testing all SCORM files...\n');
    
    final scormFiles = [
      'assets/data/scorm.zip',
      'assets/data/pri.zip',
    ];
    
    for (final file in scormFiles) {
      print('Testing: $file');
      final success = await testScormFile(file);
      print('Result: ${success ? "✅ PASS" : "❌ FAIL"}\n');
    }
  }
  
  static Future<void> _testManifestParsing(String manifestPath) async {
    try {
      print('📄 Reading manifest file...');
      final String xmlString = await File(manifestPath).readAsString();
      print('✅ Manifest file read: ${xmlString.length} characters');
      
      print('📄 Manifest content preview:');
      print(xmlString.length > 500 ? xmlString.substring(0, 500) + '...' : xmlString);
      
      print('🔍 Parsing XML structure...');
      final doc = XmlDocument.parse(xmlString);
      print('✅ XML structure validated');
      
      // Check root element
      final root = doc.rootElement;
      final String? scormVersion = root.getAttribute('version');
      print('📋 SCORM Version: ${scormVersion ?? 'Not specified'}');
      
      // Check organizations
      final organizations = doc.findAllElements('organizations');
      if (organizations.isEmpty) {
        print('❌ No organizations found');
        return;
      }
      
      final orgsEl = organizations.first;
      final String? defaultOrgId = orgsEl.getAttribute('default');
      print('📚 Default organization: ${defaultOrgId ?? 'Not specified'}');
      
      final orgs = doc.findAllElements('organization');
      print('📚 Found ${orgs.length} organizations:');
      for (final org in orgs) {
        final orgId = org.getAttribute('identifier');
        final orgTitle = org.findElements('title').isNotEmpty 
            ? org.findElements('title').first.innerText 
            : 'No title';
        print('  - $orgId: $orgTitle');
        
        // Check items in organization
        final items = org.findElements('item');
        print('    Items (${items.length}):');
        for (final item in items) {
          final itemId = item.getAttribute('identifier');
          final itemTitle = item.findElements('title').isNotEmpty 
              ? item.findElements('title').first.innerText 
              : 'No title';
          final identifierRef = item.getAttribute('identifierref');
          print('      - $itemId: $itemTitle -> $identifierRef');
        }
      }
      
      // Check resources
      final resources = doc.findAllElements('resource');
      print('📚 Found ${resources.length} resources:');
      for (final res in resources) {
        final resId = res.getAttribute('identifier');
        final resHref = res.getAttribute('href');
        final scormType = res.getAttribute('adlcp:scormType') ?? res.getAttribute('scormType');
        print('  - $resId -> $resHref (type: ${scormType ?? 'unspecified'})');
      }
      
      print('✅ Manifest parsing test completed');
      
    } catch (e) {
      print('❌ Manifest parsing failed: $e');
    }
  }
}
