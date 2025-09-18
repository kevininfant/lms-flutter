import 'dart:io';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Check internet connectivity
  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _isOnline = false;
      if (kDebugMode) {
        print('Connectivity check failed: $e');
      }
    }
    return _isOnline;
  }

  /// Check if a specific URL is reachable
  Future<bool> checkUrlReachability(String url) async {
    try {
      final uri = Uri.parse(url);
      final result = await InternetAddress.lookup(uri.host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('URL reachability check failed for $url: $e');
      }
      return false;
    }
  }

  /// Set online status (for testing or manual override)
  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
  }
}
