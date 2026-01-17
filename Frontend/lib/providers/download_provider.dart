// providers/download_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_store_plus/media_store_plus.dart';
import '../models/video_info.dart';

class DownloadProvider with ChangeNotifier {
  final String _apiBaseUrl = 'http://192.168.0.118:5000';
  static const String _downloadsKey = 'downloaded_videos';

  // Memory cache
  final Map<String, DownloadProgress> _activeDownloads = {};
  final Map<String, StreamSubscription> _downloadSubscriptions = {};
  late SharedPreferences _prefs;

  // MediaStore instance
  final MediaStore _mediaStore = MediaStore();

  DownloadProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    // Initialize MediaStore with app folder
    MediaStore.appFolder = "VideoDownloader";
    await MediaStore.ensureInitialized();
  }

  // Public getters
  Map<String, DownloadProgress> get activeDownloads => _activeDownloads;

  Map<String, DownloadProgress> get completedDownloads => _getCompletedDownloads();

  Future<void> downloadVideo({
    required String pageUrl,
    required String formatId,
    required String estSize,
    required String title,
    required String? thumbnailUrl,
  }) async {
    final String videoId = '${pageUrl}_$formatId';

    if (_activeDownloads.containsKey(videoId)) {
      print('Download already in progress: $videoId');
      return;
    }

    print("Starting download: $title ($estSize)");

    // Generate safe filename
    final safeName = _generateSafeFilename(title);
    // Try to download thumbnail if URL is provided
    String? thumbnailBase64;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      try {
        thumbnailBase64 = await _downloadThumbnailToBase64(thumbnailUrl);
      } catch (e) {
        print('Failed to download thumbnail: $e');
      }
    }
    // Create initial progress
    final initialProgress = DownloadProgress(
      videoId: videoId,
      title: title,
      pageUrl: pageUrl,
      formatId: formatId,
      filePath: '', // Will be set after download
      totalSize: estSize,
      isDownloading: true,
      thumbnailUrl: thumbnailUrl,
      thumbnailBase64: thumbnailBase64,

    );

    _activeDownloads[videoId] = initialProgress;
    notifyListeners();

    try {
      // Check permissions
      if (!await _requestStoragePermission()) {
        _updateDownloadError(videoId, "Storage permission denied");
        return;
      }

      // Create HTTP request
      final request = http.Request(
        'POST',
        Uri.parse('$_apiBaseUrl/stream-download'),
      )..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({
          "url": pageUrl,
          "format_id": formatId,
        });

      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        _updateDownloadError(videoId, "HTTP ${response.statusCode}");
        return;
      }

      // Start download process
      _startDownloadStream(
        videoId: videoId,
        initialProgress: initialProgress,
        response: response,
        safeName: safeName,
        estSize: estSize,
      );

    } catch (e) {
      _updateDownloadError(videoId, "Download failed: $e");
    }
  }

  void _startDownloadStream({
    required String videoId,
    required DownloadProgress initialProgress,
    required http.StreamedResponse response,
    required String safeName,
    required String estSize,
  }) {
    int totalBytes = _sizeToBytes(estSize);
    int downloadedBytes = 0;
    DateTime startTime = DateTime.now();
    List<int> allBytes = [];

    final subscription = response.stream.listen(
          (List<int> chunk) {
        allBytes.addAll(chunk);
        downloadedBytes += chunk.length;

        // Update progress
        final progress = totalBytes > 0 ? downloadedBytes / totalBytes : 0.0;
        final speed = _calculateSpeed(downloadedBytes, startTime);

        _activeDownloads[videoId] = initialProgress.copyWith(
          progress: progress.clamp(0.0, 1.0),
          downloadedSize: _formatBytes(downloadedBytes),
          speed: speed,
        );
        notifyListeners();
      },
      onDone: () async {
        await _saveDownloadedFile(
          videoId: videoId,
          initialProgress: initialProgress,
          bytes: allBytes,
          safeName: safeName,
          downloadedBytes: downloadedBytes,
        );
      },
      onError: (error) {
        _updateDownloadError(videoId, "Stream error: $error");
      },
      cancelOnError: true,
    );

    _downloadSubscriptions[videoId] = subscription;
  }

  Future<void> _saveDownloadedFile({
    required String videoId,
    required DownloadProgress initialProgress,
    required List<int> bytes,
    required String safeName,
    required int downloadedBytes,
  }) async {
    try {
      // Create file in app's cache directory first
      final cacheDir = await getTemporaryDirectory();
      final cacheFile = File('${cacheDir.path}/$safeName.mp4');

      // Write bytes to cache file
      await cacheFile.writeAsBytes(bytes);

      // Save to MediaStore from cache file
      final saveInfo = await _mediaStore.saveFile(
        tempFilePath: cacheFile.path,
        dirType: DirType.download,
        dirName: DirName.download,
        relativePath: null,
      );

      if (saveInfo != null) {
        final filePath = await _getFilePathFromUri(saveInfo.uri) ?? cacheFile.path;

        // Save completed download
        final completedProgress = initialProgress.copyWith(
          progress: 1.0,
          downloadedSize: _formatBytes(downloadedBytes),
          speed: '0 B/s',
          isDownloading: false,
          completedAt: DateTime.now(),
          mediaStoreUri: saveInfo.uri.toString(),
          filePath: filePath,
          thumbnailUrl: initialProgress.thumbnailUrl,
          thumbnailBase64: initialProgress.thumbnailBase64,
        );

        await _saveToSharedPreferences(videoId, completedProgress);

        print('✅ Download saved to MediaStore: ${saveInfo.uri}');

        // Success - update UI
        _activeDownloads.remove(videoId);
        _downloadSubscriptions.remove(videoId);
        notifyListeners();

        // Try to delete cache file, but don't worry if it fails
        try {
          if (await cacheFile.exists()) {
            await cacheFile.delete();
          }
        } catch (e) {
          print('⚠️ Cache file cleanup failed (not critical): $e');
        }

      } else {
        throw Exception('MediaStore save failed');
      }

    } catch (e) {
      print('❌ Save failed: $e');
      _updateDownloadError(videoId, "Save failed: ${e.toString()}");
    }
  }

  Future<String?> _getFilePathFromUri(Uri uri) async {
    try {
      return await _mediaStore.getFilePathFromUri(uriString: uri.toString());
    } catch (e) {
      print('Failed to get file path from URI: $e');
      return null;
    }
  }
  Future<String?> _downloadThumbnailToBase64(String thumbnailUrl) async {
    try {
      final response = await http.get(Uri.parse(thumbnailUrl));

      if (response.statusCode == 200) {
        // Convert to base64
        final base64String = base64Encode(response.bodyBytes);

        // Optional: Compress thumbnail if it's too large
        // Max size for SharedPreferences is around 1MB per entry
        if (base64String.length > 500000) { // ~500KB
          print('Thumbnail too large, skipping: ${base64String.length} bytes');
          return null;
        }

        return base64String;
      }
    } catch (e) {
      print('Thumbnail download error: $e');
    }
    return null;
  }

  Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+)
        // Use photos/videos permission
        var status = await Permission.photos.status;
        if (status.isDenied) {
          status = await Permission.photos.request();
        }

        if (status.isPermanentlyDenied) {
          // Open app settings
          await openAppSettings();
          return false;
        }

        return status.isGranted;
      } else if (Platform.isIOS) {
        // For iOS
        var status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
      return true;
    } catch (e) {
      print('Permission error: $e');
      return false;
    }
  }

  // Permission and file management
  Future<bool> _checkPermissions() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Cancel download
  void cancelDownload(String videoId) {
    _downloadSubscriptions.remove(videoId)?.cancel();
    _activeDownloads.remove(videoId);
    notifyListeners();
  }

  // Clear completed download
  Future<void> clearDownload(String videoId) async {
    try {
      // Get download info
      final completed = _getCompletedDownloads();
      final download = completed[videoId];

      if (download != null) {
        // Try to delete via MediaStore
        if (download.mediaStoreUri != null) {
          await _mediaStore.deleteFileUsingUri(uriString: download.mediaStoreUri!);
        }
        // Delete from SharedPreferences
        await _removeFromSharedPreferences(videoId);
        // Remove file if path exists
        if (download.filePath.isNotEmpty) {
          try {
            await File(download.filePath).delete();
          } catch (e) {
            print('File delete error: $e');
          }
        }
      }

      // Remove from active downloads if present
      _activeDownloads.remove(videoId);
      _downloadSubscriptions.remove(videoId);

      notifyListeners();

    } catch (e) {
      print('Clear download error: $e');
    }
  }

  // Clear all downloads
  Future<void> clearAllDownloads() async {
    try {
      // Cancel all active downloads
      for (final sub in _downloadSubscriptions.values) {
        sub.cancel();
      }
      _downloadSubscriptions.clear();
      _activeDownloads.clear();

      // Get all completed downloads
      final completed = _getCompletedDownloads();

      // Delete files and remove from MediaStore
      for (final download in completed.values) {
        if (download.mediaStoreUri != null) {
          await _mediaStore.deleteFileUsingUri(uriString: download.mediaStoreUri!);
        }
        if (download.filePath.isNotEmpty) {
          try {
            await File(download.filePath).delete();
          } catch (e) {
            print('File delete error: $e');
          }
        }
      }

      // Clear SharedPreferences
      await _prefs.remove(_downloadsKey);

      notifyListeners();

    } catch (e) {
      print('Clear all downloads error: $e');
    }
  }

  // SharedPreferences methods
  Map<String, DownloadProgress> _getCompletedDownloads() {
    final Map<String, DownloadProgress> completed = {};

    try {
      final String? jsonStr = _prefs.getString(_downloadsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(jsonStr);
        data.forEach((key, value) {
          try {
            completed[key] = DownloadProgress.fromJson(value);
          } catch (e) {
            print('Parse error for $key: $e');
          }
        });
      }
    } catch (e) {
      print('Load completed downloads error: $e');
    }

    return completed;
  }

  Future<void> _saveToSharedPreferences(String videoId, DownloadProgress download) async {
    try {
      final existing = _getCompletedDownloads();
      existing[videoId] = download;
      await _prefs.setString(_downloadsKey, json.encode(
          existing.map((key, value) => MapEntry(key, value.toJson()))));
    } catch (e) {
      print('Save to prefs error: $e');
    }
  }

  Future<void> _removeFromSharedPreferences(String videoId) async {
    try {
      final existing = _getCompletedDownloads();
      existing.remove(videoId);
      await _prefs.setString(_downloadsKey, json.encode(
          existing.map((key, value) => MapEntry(key, value.toJson()))));
    } catch (e) {
      print('Remove from prefs error: $e');
    }
  }

  // Helper methods
  String _generateSafeFilename(String title) {
    return title
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .substring(0, min(title.length, 50));
  }

  int _sizeToBytes(String size) {
    try {
      final value = double.parse(size.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (size.toLowerCase().contains('gb')) return (value * pow(1024, 3)).toInt();
      if (size.toLowerCase().contains('mb')) return (value * pow(1024, 2)).toInt();
      if (size.toLowerCase().contains('kb')) return (value * 1024).toInt();
      return value.toInt();
    } catch (e) {
      return 0;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _calculateSpeed(int downloadedBytes, DateTime startTime) {
    final elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
    if (elapsedSeconds == 0) return '0 B/s';
    final speed = downloadedBytes / elapsedSeconds;
    return '${_formatBytes(speed.toInt())}/s';
  }

  void _updateDownloadError(String videoId, String error) {
    if (_activeDownloads.containsKey(videoId)) {
      final current = _activeDownloads[videoId]!;
      _activeDownloads[videoId] = current.copyWith(
        isDownloading: false,
        error: error,
      );
      notifyListeners();
    }
    _downloadSubscriptions.remove(videoId)?.cancel();
  }

  // Video info extraction
  Future<VideoInfo> extractVideoInfo(String url) async {
    final response = await http.post(
      Uri.parse('$_apiBaseUrl/extract-video'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return VideoInfo.fromJson(jsonDecode(response.body));
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  Future<bool> testBackendConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$_apiBaseUrl/'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}