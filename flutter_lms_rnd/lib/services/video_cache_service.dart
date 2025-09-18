import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class VideoCacheService {
  VideoCacheService._();

  static final VideoCacheService instance = VideoCacheService._();

  Future<Directory> _getVideoDir() async {
    final Directory baseDir = Platform.isAndroid
        ? (await getApplicationDocumentsDirectory())
        : (await getApplicationSupportDirectory());
    final Directory videoDir = Directory('${baseDir.path}/videos');
    if (!await videoDir.exists()) {
      await videoDir.create(recursive: true);
    }
    return videoDir;
  }

  Future<String> _safeFileNameFromUrl(String url) async {
    final Uri uri = Uri.parse(url);
    final String last = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : 'video';
    final String sanitized = last.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (sanitized.isNotEmpty && sanitized.contains('.')) return sanitized;
    final String ext = uri.path.endsWith('.m3u8') ? 'm3u8' : 'mp4';
    final String hash = base64Url.encode(utf8.encode(url)).replaceAll('=', '');
    return 'video_$hash.$ext';
  }

  Future<File> _targetFile(String url) async {
    final Directory dir = await _getVideoDir();
    final String name = await _safeFileNameFromUrl(url);
    return File('${dir.path}/$name');
  }

  Future<bool> isCached(String url) async {
    final File file = await _targetFile(url);
    return file.exists();
  }

  Future<String?> getCachedPath(String url) async {
    final File file = await _targetFile(url);
    return await file.exists() ? file.path : null;
  }

  Stream<double> downloadWithProgress(String url) async* {
    final File file = await _targetFile(url);
    if (await file.exists()) {
      yield 1.0;
      return;
    }

    final http.Request request = http.Request('GET', Uri.parse(url));
    final http.StreamedResponse response = await request.send();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Failed to download video: ${response.statusCode}');
    }

    final int? total = response.contentLength;
    int received = 0;

    final IOSink sink = file.openWrite();
    try {
      await for (final List<int> chunk in response.stream) {
        received += chunk.length;
        sink.add(chunk);
        if (total != null && total > 0) {
          yield received / total;
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('Video download error: $e\n$st');
      }
      rethrow;
    } finally {
      await sink.flush();
      await sink.close();
    }

    yield 1.0;
  }
}
