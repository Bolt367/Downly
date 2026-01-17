import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_info.dart';
import '../providers/download_provider.dart';

class DownloadItem extends StatelessWidget {
  final DownloadProgress download;

  const DownloadItem({
    super.key,
    required this.download,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        final hasError = download.error != null && download.error!.isNotEmpty;
        final isCompleted = !download.isDownloading && !hasError;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // THUMBNAIL CONTAINER - Updated
                  ThumbnailWidget(
                    thumbnailBase64: download.thumbnailBase64,
                    thumbnailUrl: download.thumbnailUrl,
                    isDownloading: download.isDownloading,
                    progress: download.progress,
                  ),

                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          download.title.isNotEmpty
                              ? download.title
                              : _getVideoTitle(download.videoId),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          download.isDownloading
                              ? 'Downloading...'
                              : hasError
                              ? 'Failed'
                              : 'Completed',
                          style: TextStyle(
                            fontSize: 12,
                            color: download.isDownloading
                                ? Colors.blue
                                : hasError
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (download.isDownloading)
                    IconButton(
                      icon: Icon(Icons.pause, size: 20),
                      onPressed: () => provider.cancelDownload(download.videoId),
                    ),
                  if (!download.isDownloading)
                    IconButton(
                      icon: Icon(Icons.delete, size: 20),
                      onPressed: () => provider.clearDownload(download.videoId),
                    ),
                ],
              ),
              if (download.isDownloading) ...[
                SizedBox(height: 12),
                LinearProgressIndicator(
                  value: download.progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(download.progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${download.downloadedSize} / ${download.totalSize}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      download.speed,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ] else if (hasError) ...[
                SizedBox(height: 8),
                Text(
                  download.error!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ] else if (isCompleted) ...[
                SizedBox(height: 8),
                Text(
                  'Completed: ${download.downloadedSize}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getVideoTitle(String videoId) {
    try {
      // If download has a title property, use it
      if (download.title.isNotEmpty) {
        return download.title;
      }

      // Extract title from videoId format: ${pageUrl}_${formatId}
      final parts = videoId.split('_');
      if (parts.length > 1) {
        // Try to get meaningful title
        final urlPart = parts[0];
        if (urlPart.contains('//')) {
          final domain = urlPart.split('//')[1].split('/')[0];
          return 'Video from $domain';
        }
      }
      return 'Video ${videoId.substring(0, min(20, videoId.length))}...';
    } catch (e) {
      return 'Video ${videoId.substring(0, min(15, videoId.length))}...';
    }
  }
}

// Helper function
int min(int a, int b) => a < b ? a : b;

class ThumbnailWidget extends StatefulWidget {
  final String? thumbnailBase64;
  final String? thumbnailUrl;
  final bool isDownloading;
  final double progress;

  const ThumbnailWidget({
    super.key,
    this.thumbnailBase64,
    this.thumbnailUrl,
    this.isDownloading = false,
    this.progress = 0.0,
  });

  @override
  State<ThumbnailWidget> createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<ThumbnailWidget> {
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reload if the image source changed
    if (widget.thumbnailBase64 != oldWidget.thumbnailBase64 ||
        widget.thumbnailUrl != oldWidget.thumbnailUrl) {
      _loadImage();
    }
  }

  void _loadImage() {
    if (widget.thumbnailBase64 != null && widget.thumbnailBase64!.isNotEmpty) {
      try {
        final imageBytes = base64.decode(widget.thumbnailBase64!);
        _imageProvider = MemoryImage(imageBytes);
      } catch (e) {
        print('Failed to decode thumbnail: $e');
        _imageProvider = null;
      }
    } else if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty) {
      _imageProvider = NetworkImage(widget.thumbnailUrl!);
    } else {
      _imageProvider = null;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageProvider != null) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: _imageProvider!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.video_library,
        color: Colors.grey,
        size: 30,
      ),
    );
  }
}