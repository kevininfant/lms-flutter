import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';

void main() async {
  print('🔍 Checking pri.zip file...\n');

  try {
    // Check if file exists in assets
    final String assetPath = 'assets/scorms/pri.zip';
    print('📁 Checking asset path: $assetPath');

    // Try to load the asset
    try {
      final ByteData data = await rootBundle.load(assetPath);
      print('✅ pri.zip found in assets (${data.lengthInBytes} bytes)');

      // Extract and examine contents
      final Archive archive = ZipDecoder().decodeBytes(
        data.buffer.asUint8List(),
      );
      print('📦 Archive extracted successfully (${archive.length} files)');

      print('\n📋 Contents of pri.zip:');
      for (final file in archive) {
        print('  • ${file.name} (${file.size} bytes)');
      }

      // Look for HTML files
      print('\n🔍 Looking for HTML files:');
      final htmlFiles = archive
          .where(
            (file) =>
                file.name.toLowerCase().endsWith('.html') ||
                file.name.toLowerCase().endsWith('.htm'),
          )
          .toList();

      if (htmlFiles.isEmpty) {
        print('❌ No HTML files found in pri.zip');
        print('💡 This might be why pri.zip is not working');
      } else {
        print('✅ Found ${htmlFiles.length} HTML files:');
        for (final file in htmlFiles) {
          print('  • ${file.name}');
        }
      }

      // Look for manifest
      print('\n🔍 Looking for SCORM manifest:');
      final manifestFiles = archive
          .where(
            (file) =>
                file.name.toLowerCase().contains('imsmanifest') ||
                file.name.toLowerCase().contains('manifest'),
          )
          .toList();

      if (manifestFiles.isEmpty) {
        print('❌ No manifest file found');
        print('💡 This might indicate the file is not a valid SCORM package');
      } else {
        print('✅ Found ${manifestFiles.length} manifest files:');
        for (final file in manifestFiles) {
          print('  • ${file.name}');
        }
      }
    } catch (e) {
      print('❌ Error loading pri.zip from assets: $e');
      print('💡 Make sure pri.zip is in assets/scorms/ directory');
    }
  } catch (e) {
    print('❌ Error: $e');
  }

  print('\n🔧 Troubleshooting steps:');
  print('1. Ensure pri.zip is in assets/scorms/ directory');
  print('2. Check if the file is corrupted');
  print('3. Verify it contains HTML files');
  print('4. Make sure it has a valid SCORM manifest');
  print('5. Try other SCORM files to confirm the system works');
}
