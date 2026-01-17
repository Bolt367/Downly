import 'package:flutter/material.dart';
import '../models/video_info.dart';

class VideoQuickAccess extends StatelessWidget {
  final VideoInfo videoInfo;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const VideoQuickAccess({
    super.key,
    required this.videoInfo,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bestQuality = videoInfo.downloadableVideos.first;
    final availableFormats = videoInfo.downloadableVideos.length;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.video_library,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video Detected',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${availableFormats} format${availableFormats > 1 ? 's' : ''} available',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, size: 18),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Material(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.all(12),
                width: double.infinity,
                child: Row(
                  children: [
                    Icon(
                      Icons.download,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Download ${bestQuality.quality} • ${bestQuality.size}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Best quality available',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}