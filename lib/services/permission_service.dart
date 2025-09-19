import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request external storage permissions
  Future<bool> requestStoragePermissions() async {
    try {
      // For Android 13+ (API level 33+), use granular media permissions
      if (await _isAndroid13OrHigher()) {
        final permissions = [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ];

        final statuses = await permissions.request();

        // Check if all permissions are granted
        return statuses.values.every(
          (status) => status == PermissionStatus.granted,
        );
      } else {
        // For Android 11+ (API level 30+), try MANAGE_EXTERNAL_STORAGE first
        try {
          final manageStorageStatus = await Permission.manageExternalStorage
              .request();
          if (manageStorageStatus == PermissionStatus.granted) {
            return true;
          }
        } catch (e) {
          print('MANAGE_EXTERNAL_STORAGE not available: $e');
        }

        // Fallback to traditional storage permissions
        final status = await Permission.storage.request();
        return status == PermissionStatus.granted;
      }
    } catch (e) {
      print('Error requesting storage permissions: $e');
      return false;
    }
  }

  /// Check if external storage permissions are granted
  Future<bool> hasStoragePermissions() async {
    try {
      if (await _isAndroid13OrHigher()) {
        final permissions = [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ];

        final statuses = await permissions.map((p) => p.status).toList();
        final statusFutures = await Future.wait(statuses);
        return statusFutures.every(
          (status) => status == PermissionStatus.granted,
        );
      } else {
        // Check MANAGE_EXTERNAL_STORAGE first (Android 11+)
        try {
          final manageStorageStatus =
              await Permission.manageExternalStorage.status;
          if (manageStorageStatus == PermissionStatus.granted) {
            return true;
          }
        } catch (e) {
          print('MANAGE_EXTERNAL_STORAGE not available: $e');
        }

        // Fallback to traditional storage permissions
        final status = await Permission.storage.status;
        return status == PermissionStatus.granted;
      }
    } catch (e) {
      print('Error checking storage permissions: $e');
      return false;
    }
  }

  /// Check if we're running on Android 13 or higher
  Future<bool> _isAndroid13OrHigher() async {
    try {
      // Check if photos permission is available (Android 13+ feature)
      final photosStatus = await Permission.photos.status;
      // If photos permission is not denied/restricted, it means we're on Android 13+
      return photosStatus != PermissionStatus.denied &&
          photosStatus != PermissionStatus.restricted;
    } catch (e) {
      // If photos permission throws an error, we're likely on older Android
      return false;
    }
  }

  /// Request internet permission (usually granted by default)
  Future<bool> requestInternetPermission() async {
    try {
      // Internet permission is usually granted by default, no need to request
      return true;
    } catch (e) {
      print('Error requesting internet permission: $e');
      return true; // Assume granted
    }
  }

  /// Open app settings if permissions are permanently denied
  Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }

  /// Check if permissions are permanently denied
  Future<bool> arePermissionsPermanentlyDenied() async {
    try {
      if (await _isAndroid13OrHigher()) {
        final permissions = [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ];

        final statuses = await permissions.map((p) => p.status).toList();
        final statusFutures = await Future.wait(statuses);
        return statusFutures.any(
          (status) => status == PermissionStatus.permanentlyDenied,
        );
      } else {
        final status = await Permission.storage.status;
        return status == PermissionStatus.permanentlyDenied;
      }
    } catch (e) {
      print('Error checking if permissions are permanently denied: $e');
      return false;
    }
  }

  /// Get detailed permission status for debugging
  Future<Map<String, PermissionStatus>> getPermissionStatuses() async {
    try {
      if (await _isAndroid13OrHigher()) {
        final permissions = {
          'photos': Permission.photos,
          'videos': Permission.videos,
          'audio': Permission.audio,
        };

        final statuses = <String, PermissionStatus>{};
        for (final entry in permissions.entries) {
          statuses[entry.key] = await entry.value.status;
        }
        return statuses;
      } else {
        return {'storage': await Permission.storage.status};
      }
    } catch (e) {
      print('Error getting permission statuses: $e');
      return {};
    }
  }
}
