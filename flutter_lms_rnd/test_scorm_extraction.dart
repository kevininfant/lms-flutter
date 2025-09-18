import 'dart:io';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  print('🧪 Testing SCORM Extraction and Manifest Parsing...\n');
  
  try {
    // Test 1: Extract pri.zip from assets
    print('📦 Step 1: Testing asset extraction...');
    await testAssetExtraction();
    
    // Test 2: Parse imsmanifest.xml
    print('\n📋 Step 2: Testing manifest parsing...');
    await testManifestParsing();
    
    print('\n✅ All tests completed successfully!');
    
  } catch (e) {
    print('\n❌ Test failed: $e');
  }
}

Future<void> testAssetExtraction() async {
  try {
    // Get application documents directory
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory scormDir = Directory('${appDir.path}/test_scorm_content');
    
    // Create directory if it doesn't exist
    if (!await scormDir.exists()) {
      await scormDir.create(recursive: true);
    }
    
    // Load asset file from bundle
    final ByteData data = await rootBundle.load('assets/data/pri.zip');
    final List<int> bytes = data.buffer.asUint8List();
    
    print('✅ Asset loaded: ${bytes.length} bytes');
    
    // Save to temporary file
    final String tempPath = '${scormDir.path}/temp_pri.zip';
    final File tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes);
    
    print('✅ Temporary file created: $tempPath');
    
    // Extract ZIP file
    final Archive archive = ZipDecoder().decodeBytes(bytes);
    int extractedFiles = 0;
    
    for (final ArchiveFile file in archive) {
      if (file.isFile) {
        final String filePath = '${scormDir.path}/${file.name}';
        final File outputFile = File(filePath);
        
        // Create directory if needed
        await outputFile.parent.create(recursive: true);
        
        // Write file
        await outputFile.writeAsBytes(file.content as List<int>);
        extractedFiles++;
        
        if (file.name == 'imsmanifest.xml') {
          print('✅ Found imsmanifest.xml: $filePath');
        }
      }
    }
    
    print('✅ Extracted $extractedFiles files to: ${scormDir.path}');
    
  } catch (e) {
    print('❌ Asset extraction failed: $e');
    rethrow;
  }
}

Future<void> testManifestParsing() async {
  try {
    // Get application documents directory
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory scormDir = Directory('${appDir.path}/test_scorm_content');
    
    // Find imsmanifest.xml
    final File manifestFile = File('${scormDir.path}/imsmanifest.xml');
    
    if (!await manifestFile.exists()) {
      throw Exception('imsmanifest.xml not found');
    }
    
    print('✅ Found imsmanifest.xml: ${manifestFile.path}');
    
    // Read and parse manifest
    final String manifestContent = await manifestFile.readAsString();
    print('✅ Manifest content length: ${manifestContent.length} characters');
    
    final XmlDocument document = XmlDocument.parse(manifestContent);
    final XmlElement? manifest = document.findElements('manifest').firstOrNull;
    
    if (manifest == null) {
      throw Exception('Invalid manifest structure - no manifest element found');
    }
    
    // Extract metadata
    final String identifier = manifest.getAttribute('identifier') ?? 'unknown';
    final String version = manifest.getAttribute('version') ?? '1.0';
    
    print('✅ Manifest ID: $identifier');
    print('✅ SCORM Version: $version');
    
    // Parse resources
    final List<XmlElement> resourceElements = manifest
        .findElements('resources')
        .expand((resources) => resources.findElements('resource'))
        .toList();
    
    print('✅ Found ${resourceElements.length} resources');
    
    String? entryPoint;
    
    for (final XmlElement resourceElement in resourceElements) {
      final String resourceId = resourceElement.getAttribute('identifier') ?? '';
      final String resourceType = resourceElement.getAttribute('type') ?? '';
      final String href = resourceElement.getAttribute('href') ?? '';
      
      print('📄 Resource: ID=$resourceId, Type=$resourceType, Href=$href');
      
      // Check for webcontent type or any resource with href
      if ((resourceType == 'webcontent' || resourceType.isEmpty) && href.isNotEmpty) {
        final String fullPath = '${scormDir.path}/$href';
        final File launchFileCheck = File(fullPath);
        
        if (await launchFileCheck.exists()) {
          entryPoint = href;
          print('🎯 Found entry point: $entryPoint');
        } else {
          print('⚠️ Entry point file not found: $fullPath');
        }
      }
    }
    
    // Fallback search for common SCORM files
    if (entryPoint == null) {
      print('🔍 No entry point found in manifest, searching for common files...');
      entryPoint = await findFallbackEntryPoint(scormDir.path);
    }
    
    if (entryPoint == null) {
      throw Exception('No entry point found in SCORM package');
    }
    
    print('🎯 Final entry point: $entryPoint');
    
    // Check if entry point file exists and is accessible
    final String fullEntryPath = '${scormDir.path}/$entryPoint';
    final File entryFile = File(fullEntryPath);
    
    if (await entryFile.exists()) {
      final int fileSize = await entryFile.length();
      print('✅ Entry point file exists: $fullEntryPath (${fileSize} bytes)');
    } else {
      print('❌ Entry point file not found: $fullEntryPath');
    }
    
  } catch (e) {
    print('❌ Manifest parsing failed: $e');
    rethrow;
  }
}

Future<String?> findFallbackEntryPoint(String contentPath) async {
  final List<String> commonFiles = [
    'index.html',
    'start.html',
    'launch.html',
    'content.html',
    'main.html',
    'story_html5.html', // Common in SCORM packages
    'player.html',
    'course.html',
    'lesson.html',
    'module.html',
    'scorm.html',
    'lms.html',
  ];
  
  print('🔍 Searching for common entry point files...');
  for (final String fileName in commonFiles) {
    final String filePath = '$contentPath/$fileName';
    final File file = File(filePath);
    
    if (await file.exists()) {
      print('✅ Found common entry point: $fileName');
      return fileName;
    }
  }
  
  // Search for any HTML file
  print('🔍 Searching for any HTML file...');
  try {
    final Directory dir = Directory(contentPath);
    final List<FileSystemEntity> files = await dir.list(recursive: true).toList();
    
    for (final FileSystemEntity file in files) {
      if (file is File && file.path.toLowerCase().endsWith('.html')) {
        final String relativePath = file.path.replaceFirst('$contentPath/', '');
        print('✅ Found HTML file: $relativePath');
        return relativePath;
      }
    }
  } catch (e) {
    print('❌ Error searching for HTML files: $e');
  }
  
  print('❌ No entry point found');
  return null;
}

