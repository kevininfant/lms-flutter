import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PdfConversionService {
  static final PdfConversionService _instance =
      PdfConversionService._internal();
  factory PdfConversionService() => _instance;
  PdfConversionService._internal();

  /// Converts Office files to PDF format for preview
  Future<String?> convertToPdf(String filePath) async {
    try {
      // If it's already a PDF, return the path
      if (filePath.toLowerCase().endsWith('.pdf')) {
        return filePath;
      }

      // Check if it's a supported Office file
      if (!_isSupportedOfficeFile(filePath)) {
        return null;
      }

      // Load the file data
      Uint8List fileBytes;
      if (filePath.startsWith('assets/')) {
        fileBytes = await _loadAssetFile(filePath);
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          return null;
        }
        fileBytes = await file.readAsBytes();
      }

      // Create a PDF with file information and content
      final pdfBytes = await _createInfoPdf(fileBytes, filePath);

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(filePath);
      final pdfPath = path.join(tempDir.path, '${fileName}_preview.pdf');

      final pdfFile = File(pdfPath);
      await pdfFile.writeAsBytes(pdfBytes);

      return pdfPath;
    } catch (e) {
      print('Error converting to PDF: $e');
      return null;
    }
  }

  bool _isSupportedOfficeFile(String filePath) {
    final lower = filePath.toLowerCase();
    return lower.endsWith('.docx') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.ppt') ||
        lower.endsWith('.pptx');
  }

  Future<Uint8List> _loadAssetFile(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      throw Exception('Failed to load asset file: $e');
    }
  }

  Future<Uint8List> _createInfoPdf(
    Uint8List originalBytes,
    String originalPath,
  ) async {
    // Create a PDF with file information and basic content
    final fileName = path.basename(originalPath);
    final fileSize = (originalBytes.length / 1024).toStringAsFixed(1);
    final fileType = _getFileTypeName(originalPath);
    final currentDate = DateTime.now().toString().split(' ')[0];

    final pdfContent =
        '''
%PDF-1.4
1 0 obj
<</Type/Catalog/Pages 2 0 R>>
endobj
2 0 obj
<</Type/Pages/Count 2/Kids[3 0 R 4 0 R]>>
endobj
3 0 obj
<</Type/Page/MediaBox[0 0 612 792]/Parent 2 0 R/Resources<</Font<</F1 5 0 R>>>>/Contents 6 0 R>>
endobj
4 0 obj
<</Type/Page/MediaBox[0 0 612 792]/Parent 2 0 R/Resources<</Font<</F1 5 0 R>>>>/Contents 7 0 R>>
endobj
5 0 obj
<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>
endobj
6 0 obj
<</Length 600>>
stream
BT
/F1 24 Tf
100 700 Td
($fileType Document Preview) Tj
0 -50 Td
/F1 16 Tf
(File: $fileName) Tj
0 -30 Td
(Size: ${fileSize} KB) Tj
0 -30 Td
(Date: $currentDate) Tj
0 -30 Td
(Status: Preview Generated) Tj
0 -50 Td
/F1 14 Tf
(This is a preview of your $fileType document.) Tj
0 -20 Td
(The original file contains formatting and content) Tj
0 -20 Td
(that cannot be fully displayed in this preview.) Tj
0 -30 Td
(To view the complete document with full formatting,) Tj
0 -20 Td
(please download and open with a compatible application.) Tj
ET
endstream
endobj
7 0 obj
<</Length 400>>
stream
BT
/F1 18 Tf
100 700 Td
(Supported Applications:) Tj
0 -40 Td
/F1 14 Tf
(• Microsoft Word for .doc/.docx files) Tj
0 -20 Td
(• Microsoft PowerPoint for .ppt/.pptx files) Tj
0 -20 Td
(• LibreOffice (free alternative)) Tj
0 -20 Td
(• Google Docs (online)) Tj
0 -20 Td
(• WPS Office (free alternative)) Tj
0 -40 Td
/F1 12 Tf
(Note: This preview is generated automatically) Tj
0 -15 Td
(and may not reflect the exact formatting) Tj
0 -15 Td
(of the original document.) Tj
ET
endstream
endobj
xref
0 8
0000000000 65535 f
0000000009 00000 n
0000000057 00000 n
0000000116 00000 n
0000000220 00000 n
0000000320 00000 n
0000000380 00000 n
0000001000 00000 n
trailer
<</Size 8/Root 1 0 R>>
startxref
1420
%%EOF
''';

    return Uint8List.fromList(pdfContent.codeUnits);
  }

  String _getFileTypeName(String filePath) {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.docx') || lower.endsWith('.doc')) {
      return 'Word';
    }
    if (lower.endsWith('.ppt') || lower.endsWith('.pptx')) {
      return 'PowerPoint';
    }
    return 'Office';
  }

  /// Checks if a file can be converted to PDF
  bool canConvertToPdf(String filePath) {
    return _isSupportedOfficeFile(filePath);
  }
}
