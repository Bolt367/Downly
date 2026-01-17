import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_info.dart';
import '../providers/download_provider.dart';

class _DownloadDialogState extends State<DownloadDialog> {
  VideoInfo? _videoInfo;
  bool _isLoading = false;
  VideoFormat? _selectedFormat;

  @override
  void initState() {
    super.initState();

    if (widget.videoInfo != null) {
      _videoInfo = widget.videoInfo;
      if (_videoInfo!.downloadableVideos.isNotEmpty) {
        _selectedFormat = _videoInfo!.downloadableVideos[0];
      }
    } else {
      _extractVideoInfo();
    }
  }

  Future<void> _extractVideoInfo() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<DownloadProvider>(context, listen: false);
      final info = await provider.extractVideoInfo(widget.url);

      setState(() {
        _videoInfo = info;
        if (info.downloadableVideos.isNotEmpty) {
          _selectedFormat = info.downloadableVideos[0];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _videoInfo == null || _videoInfo!.downloadableVideos.isEmpty
            ? const Text('No videos found')
            : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _videoInfo!.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if (_videoInfo!.thumbnail.isNotEmpty)
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(_videoInfo!.thumbnail),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Available Qualities:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _videoInfo!.downloadableVideos.length,
                itemBuilder: (context, index) {
                  final format = _videoInfo!.downloadableVideos[index];
                  return RadioListTile<VideoFormat>(
                    title: Text(
                      '${format.quality} • ${format.size} • ${format.duration}',
                    ),
                    value: format,
                    groupValue: _selectedFormat,
                    onChanged: (value) {
                      setState(() => _selectedFormat = value);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _startDownload,
                  child: const Text('DOWNLOAD'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startDownload() async {
    if (_selectedFormat == null || _videoInfo == null) return;

    final provider = Provider.of<DownloadProvider>(context, listen: false);

    try {

        await provider.downloadVideo(
          pageUrl: _videoInfo!.url,              // ✅ FIXED
          formatId: _selectedFormat!.formatId,   // ✅ FIXED
          title: _videoInfo!.title,
          estSize:_selectedFormat!.size,// ✅ FIXED
          thumbnailUrl: _videoInfo!.thumbnail,
        );

        Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download started!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }
}

// widgets/download_dialog.dart - Update constructor
class DownloadDialog extends StatefulWidget {
  final String url;
  final VideoInfo? videoInfo; // Accept pre-loaded video info

  const DownloadDialog({super.key, required this.url, this.videoInfo});

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}
