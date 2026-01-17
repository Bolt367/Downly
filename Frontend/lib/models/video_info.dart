// models/video_info.dart
class VideoFormat {
  final String url;
  final String formatId; // ✅ ADD THIS
  final String quality;
  final String size;
  final String duration;

  VideoFormat({
    required this.url,
    required this.formatId,
    required this.quality,
    required this.size,
    required this.duration,
  });

  factory VideoFormat.fromJson(Map<String, dynamic> json) {
    return VideoFormat(
      url: json['url'] ?? '',
      formatId: json['format_id'] ?? '', // ✅ backend must send this
      quality: json['quality'] ?? 'unknown',
      size: json['size'] ?? 'unknown',
      duration: json['duration'] ?? 'unknown',
    );
  }
}

class VideoInfo {
  final String title;
  final String url;
  final String thumbnail;
  final List<VideoFormat> downloadableVideos;

  VideoInfo({
    required this.title,
    required this.url,
    required this.thumbnail,
    required this.downloadableVideos,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      title: json['title'] ?? 'Untitled',
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      downloadableVideos: (json['downloadable_videos'] as List<dynamic>? ?? [])
          .map((v) => VideoFormat.fromJson(v))
          .toList(),
    );
  }

  // ✅ Add this getter to check if any downloadable videos exist
  bool get downloadableFound => downloadableVideos.isNotEmpty;
}
// models/download_progress.dart

class DownloadProgress {
  final String videoId;
  final String title;
  final String pageUrl;
  final String formatId;
  final String filePath;
  final double progress;
  final String downloadedSize;
  final String totalSize;
  final String speed;
  final bool isDownloading;
  final String? error;
  final DateTime? completedAt;
  final DateTime startedAt;
  final String? mediaStoreUri;
  final String? thumbnailUrl;
  final String? thumbnailBase64;

  DownloadProgress({
    required this.videoId,
    required this.title,
    required this.pageUrl,
    required this.formatId,
    required this.filePath,
    this.progress = 0.0,
    this.downloadedSize = '0 B',
    this.totalSize = '0 B',
    this.speed = '0 B/s',
    this.isDownloading = false,
    this.error,
    this.completedAt,
    this.mediaStoreUri,
    this.thumbnailUrl,
    this.thumbnailBase64,

    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'title': title,
    'pageUrl': pageUrl,
    'formatId': formatId,
    'filePath': filePath,
    'progress': progress,
    'downloadedSize': downloadedSize,
    'totalSize': totalSize,
    'speed': speed,
    'isDownloading': isDownloading,
    'error': error,
    'completedAt': completedAt?.toIso8601String(),
    'startedAt': startedAt.toIso8601String(),
    'mediaStoreUri': mediaStoreUri,
    'thumbnailUrl': thumbnailUrl,
    'thumbnailBase64': thumbnailBase64,
  };

  factory DownloadProgress.fromJson(Map<String, dynamic> json) {
    return DownloadProgress(
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? '',
      pageUrl: json['pageUrl'] ?? '',
      formatId: json['formatId'] ?? '',
      filePath: json['filePath'] ?? '',
      progress: (json['progress'] ?? 0.0).toDouble(),
      downloadedSize: json['downloadedSize'] ?? '0 B',
      totalSize: json['totalSize'] ?? '0 B',
      speed: json['speed'] ?? '0 B/s',
      isDownloading: json['isDownloading'] ?? false,
      error: json['error'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : DateTime.now(),
      mediaStoreUri: json['mediaStoreUri'],
      thumbnailUrl: json['thumbnailUrl'],
      thumbnailBase64: json['thumbnailBase64'],

    );
  }

  DownloadProgress copyWith({
    String? videoId,
    String? title,
    String? pageUrl,
    String? formatId,
    String? filePath,
    double? progress,
    String? downloadedSize,
    String? totalSize,
    String? speed,
    bool? isDownloading,
    String? error,
    DateTime? completedAt,
    DateTime? startedAt,
    String? mediaStoreUri,
    String? thumbnailUrl,
    String? thumbnailBase64,


  }) {
    return DownloadProgress(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      pageUrl: pageUrl ?? this.pageUrl,
      formatId: formatId ?? this.formatId,
      filePath: filePath ?? this.filePath,
      progress: progress ?? this.progress,
      downloadedSize: downloadedSize ?? this.downloadedSize,
      totalSize: totalSize ?? this.totalSize,
      speed: speed ?? this.speed,
      isDownloading: isDownloading ?? this.isDownloading,
      error: error ?? this.error,
      completedAt: completedAt ?? this.completedAt,
      startedAt: startedAt ?? this.startedAt,
      mediaStoreUri: mediaStoreUri ?? this.mediaStoreUri,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      thumbnailBase64: thumbnailBase64 ?? this.thumbnailBase64,

    );
  }
}