// screens/downloads_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_info.dart';
import '../providers/download_provider.dart';
import '../widgets/download_item.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Downloads'),
          centerTitle: true,
          actions: [
            Consumer<DownloadProvider>(
              builder: (context, provider, _) {
                final completedCount = provider.completedDownloads.length;
                if (completedCount > 0) {
                  return IconButton(
                    icon: Badge(
                      label: Text(completedCount.toString()),
                      child: const Icon(Icons.delete_sweep),
                    ),
                    onPressed: () => _showClearAllDialog(context),
                    tooltip: 'Clear All',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.downloading), text: 'Active'),
              Tab(icon: Icon(Icons.download_done), text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveDownloadsTab(),
            _buildCompletedDownloadsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDownloadsTab() {
    return Consumer<DownloadProvider>(
      builder: (context, provider, _) {
        final active = provider.activeDownloads.values.toList();

        if (active.isEmpty) {
          return _buildEmptyState(
            icon: Icons.download_for_offline,
            title: 'No Active Downloads',
            message: 'Downloaded videos will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: active.length,
          itemBuilder: (context, index) {
            return DownloadItem(download: active[index]);
          },
        );
      },
    );
  }

  Widget _buildCompletedDownloadsTab() {
    return Consumer<DownloadProvider>(
      builder: (context, provider, _) {
        final completed = provider.completedDownloads.values.toList();

        if (completed.isEmpty) {
          return _buildEmptyState(
            icon: Icons.download_done,
            title: 'No Completed Downloads',
            message: 'Completed videos will appear here',
          );
        }

        // Sort by completion date (newest first)
        completed.sort((a, b) =>
            (b.completedAt ?? DateTime(1970))
                .compareTo(a.completedAt ?? DateTime(1970)));

        return RefreshIndicator(
          onRefresh: () async {
            provider.notifyListeners();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: completed.length,
            itemBuilder: (context, index) {
              return _buildCompletedItem(completed[index], context);
            },
          ),
        );
      },
    );
  }

  Widget _buildThumbnailWidget(DownloadProgress download) {
    // Try to use stored base64 thumbnail first
    if (download.thumbnailBase64 != null && download.thumbnailBase64!.isNotEmpty) {
      try {
        final imageBytes = base64.decode(download.thumbnailBase64!);
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: MemoryImage(imageBytes),
              fit: BoxFit.cover,
            ),
          ),
        );
      } catch (e) {
        print('Failed to decode thumbnail: $e');
      }
    }

    // Fallback to URL if base64 fails
    if (download.thumbnailUrl != null && download.thumbnailUrl!.isNotEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(download.thumbnailUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Default icon if no thumbnail
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
  Widget _buildCompletedItem(DownloadProgress download, BuildContext context) {
    final provider = Provider.of<DownloadProvider>(context, listen: false);
    final fileExists = download.filePath.isNotEmpty &&
        File(download.filePath).existsSync();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildThumbnailWidget(download),
        title: Text(
          download.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${download.downloadedSize} • ${_formatDate(download.completedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: fileExists ? Colors.grey[600] : Colors.red,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleAction(value, download, context, provider),
          itemBuilder: (context) => [
            if (fileExists) const PopupMenuItem(
              value: 'play',
              child: Row(
                children: [
                  Icon(Icons.play_arrow, size: 20),
                  SizedBox(width: 8),
                  Text('Play'),
                ],
              ),
            ),
            if (fileExists) const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: fileExists ? () => _playVideo(download, context) : null,
      ),
    );
  }

  void _handleAction(
      String action,
      DownloadProgress download,
      BuildContext context,
      DownloadProvider provider,
      ) {
    switch (action) {
      case 'play':
        _playVideo(download, context);
        break;
      case 'share':
        _shareVideo(download);
        break;
      case 'delete':
        _deleteVideo(download, context, provider);
        break;
    }
  }

  void _playVideo(DownloadProgress download, BuildContext context) {
    // Implement video playback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playing: ${download.title}')),
    );
  }

  void _shareVideo(DownloadProgress download) {
    // Implement sharing with share_plus
    // Share.shareXFiles([XFile(download.filePath)]);
  }

  Future<void> _deleteVideo(
      DownloadProgress download,
      BuildContext context,
      DownloadProvider provider,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: Text('Delete "${download.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.clearDownload(download.videoId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video deleted'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showClearAllDialog(BuildContext context) {
    final provider = Provider.of<DownloadProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Downloads'),
        content: const Text('This will delete all download history and files.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.clearAllDownloads();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All downloads cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}