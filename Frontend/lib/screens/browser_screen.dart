import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';
import '../models/video_info.dart';
import 'downloads_screen.dart';
import 'home_screen.dart';

class BrowserTabScreen extends StatefulWidget {
  final String initialUrl;
  final String tabId;

  const BrowserTabScreen({
    super.key,
    required this.initialUrl,
    required this.tabId,
  });

  @override
  State<BrowserTabScreen> createState() => _BrowserTabScreenState();
}

class _BrowserTabScreenState extends State<BrowserTabScreen> {
  late InAppWebViewController _webController;
  bool _isLoading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String _currentUrl = '';
  String _pageTitle = 'Loading...';
  VideoInfo? _detectedVideos;
  bool _showVideoFab = false;
  bool _isScanning = false;
  int _videoCount = 0;
  int? _selectedFormatIndex;
  VideoFormat? _selectedVideo;
  bool _initialScanComplete = false;


  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndStoreVideos();
    });
  }

  Future<void> _fetchAndStoreVideos() async {
    if (_isScanning || _initialScanComplete) return;

    print("FETCHING VIDEOS");
    setState(() {
      _isScanning = true;
    });

    try {
      final provider = Provider.of<DownloadProvider>(context, listen: false);
      final videoInfo = await provider.extractVideoInfo(_currentUrl);

      if (mounted && videoInfo.downloadableFound) {
        setState(() {
          _detectedVideos = videoInfo;
          _videoCount = videoInfo.downloadableVideos.length;
          _showVideoFab = true;
          _initialScanComplete = true;
        });
      } else {
        setState(() {
          _showVideoFab = false;
          _detectedVideos = null;
          _videoCount = 0;
          _initialScanComplete = true;
        });
      }
    } catch (e) {
      print('Video detection error: $e');
      setState(() {
        _showVideoFab = false;
        _initialScanComplete = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  void _updateNavigationState() async {
    final canGoBack = await _webController.canGoBack();
    final canGoForward = await _webController.canGoForward();

    if (!mounted) return;

    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  Future<void> _goBack() async {
    if (await _webController.canGoBack()) {
      await _webController.goBack();
    }
  }

  Future<void> _goForward() async {
    if (await _webController.canGoForward()) {
      await _webController.goForward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (await _webController.canGoBack()) {
          await _webController.goBack();
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
                (route) => false, // removes all previous routes
          );

        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Page title
              Text(
                _pageTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              // URL
              Text(
                _currentUrl,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ],
          ),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Navigate to home or close tab
              Navigator.pop(context);
            },
          ),
          actions: [
            // Refresh button
            IconButton(
              icon: Icon(_isLoading ? Icons.close : Icons.refresh),
              onPressed: () {
                if (_isLoading) {
                  _webController.stopLoading();
                } else {
                  _webController.reload();
                }
              },
            ),

            // Download indicator button
            Consumer<DownloadProvider>(
              builder: (context, provider, child) {
                final activeDownloads = provider.activeDownloads.length;

                return Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.download),
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                DownloadsScreen(),
                            transitionDuration: Duration.zero,
                          ),
                        );
                      },
                    ),
                    if (activeDownloads > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$activeDownloads',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            // More options
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                _handleMenuSelection(value);
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'back',
                    enabled: _canGoBack,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, size: 20),
                        SizedBox(width: 8),
                        Text('Back'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'forward',
                    enabled: _canGoForward,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_forward, size: 20),
                        SizedBox(width: 8),
                        Text('Forward'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 20),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'open_browser',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_browser, size: 20),
                        SizedBox(width: 8),
                        Text('Open in Browser'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'bookmark',
                    child: Row(
                      children: [
                        Icon(Icons.bookmark_border, size: 20),
                        SizedBox(width: 8),
                        Text('Bookmark'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, size: 20),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
              initialSettings: InAppWebViewSettings(
                cacheEnabled: true,
                useHybridComposition: true,
                cacheMode: CacheMode.LOAD_DEFAULT, // or LOAD_CACHE_ELSE_NETWORK

                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                transparentBackground: true,
                // AD-BLOCKING SETTINGS (Answer to your question)
                disableVerticalScroll: false,
                disableHorizontalScroll: false,
                // Block pop-up windows (this prevents most ad popups)
                supportMultipleWindows: false,
                // Add content blockers
                contentBlockers: [
                  // Block common ad domains (you can extend this list)
                  ContentBlocker(
                    trigger: ContentBlockerTrigger(
                      urlFilter: ".*doubleclick.net.*",
                    ),
                    action: ContentBlockerAction(
                      type: ContentBlockerActionType.BLOCK,
                    ),
                  ),
                  ContentBlocker(
                    trigger: ContentBlockerTrigger(
                      urlFilter: ".*googleads.*",
                    ),
                    action: ContentBlockerAction(
                      type: ContentBlockerActionType.BLOCK,
                    ),
                  ),
                  ContentBlocker(
                    trigger: ContentBlockerTrigger(
                      urlFilter: ".*googlesyndication.*",
                    ),
                    action: ContentBlockerAction(
                      type: ContentBlockerActionType.BLOCK,
                    ),
                  ),
                  ContentBlocker(
                    trigger: ContentBlockerTrigger(
                      urlFilter: ".*facebook.com/plugins.*",
                    ),
                    action: ContentBlockerAction(
                      type: ContentBlockerActionType.BLOCK,
                    ),
                  ),
                ],
              ),
              onWebViewCreated: (controller) {
                _webController = controller;
              },
              onLoadStart: (controller, url) {
                if (url != null) {
                  setState(() {
                    _isLoading = true;
                    _currentUrl = url.toString();
                    _showVideoFab = false;
                    _detectedVideos = null;
                    _videoCount = 0;
                    _initialScanComplete = false;
                  });
                }
              },

              onLoadStop: (controller, url) async {
                if (url != null) {
                  _currentUrl = url.toString();

                  final title = await controller.getTitle();
                  if (mounted) {
                    setState(() {
                      _pageTitle = title ?? _pageTitle;
                      _isLoading = false;
                    });
                  }

                  _updateNavigationState();
                  _fetchAndStoreVideos();
                }
              },

              onProgressChanged: (controller, progress) {
                setState(() {
                  _isLoading = progress < 100;
                });
              },
              onUpdateVisitedHistory: (controller, url, androidIsReload) {
                if (url != null) {
                  setState(() {
                    _currentUrl = url.toString();
                  });
                  _updateNavigationState();
                }
              },

              // Handle pop-up windows (ads)
              onCreateWindow: (controller, createWindowRequest) async {
                // BLOCK ALL POP-UPS/ADS - Answer to your question
                // This prevents ads from opening in new tabs/windows
                return false; // Return false to block the popup
              },
              // Handle navigation requests
              onLoadResource: (controller, resource) async {
                // You can inspect and block ad resources here
                final url = resource.url.toString();
                if (url.contains('ads') ||
                    url.contains('adserver') ||
                    url.contains('track') ||
                    url.contains('analytics')) {
                  // Return false to block this resource
                }
              },
            ),

            // Loading overlay
            if (_isLoading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_isScanning) return; // Don't allow taps while scanning

            if (_showVideoFab) {
              _showDownloadOptionsBottomSheet();
            } else if (!_initialScanComplete) {
              // Still scanning or hasn't started yet
              return;
            } else {
              // Try to scan again if no videos found previously
              setState(() {
                _initialScanComplete = false;
              });
              _fetchAndStoreVideos();
            }
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          heroTag: 'video_fab',
          child: Stack(
            children: [
              // Main icon
              Center(
                child: _isScanning
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(
                        _showVideoFab ? Icons.video_library : Icons.search,
                        color: Colors.white,
                      ),
              ),

              // Small dot badge
              if (_videoCount > 0 && !_isScanning && _showVideoFab)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        _videoCount > 9 ? '9+' : '$_videoCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'back':
        _goBack();
        break;
      case 'forward':
        _goForward();
        break;
      case 'share':
        _shareUrl();
        break;
      case 'open_browser':
        _openInExternalBrowser();
        break;
      case 'bookmark':
        _bookmarkPage();
        break;
      case 'settings':
        _openSettings();
        break;
    }
  }

  void _shareUrl() {
    // Implement share functionality
    print('Sharing URL: $_currentUrl');
  }

  void _openInExternalBrowser() {
    // Implement open in external browser
    print('Opening in external browser: $_currentUrl');
  }

  void _bookmarkPage() {
    // Implement bookmark functionality
    print('Bookmarking: $_pageTitle');
  }

  void _openSettings() {
    // Implement settings navigation
    print('Opening settings');
  }

  void _showDownloadOptionsBottomSheet() async {
    // Check if we have videos stored
    if (_detectedVideos == null || !_detectedVideos!.downloadableFound) {
      // No videos found previously, try to fetch now
      await _fetchAndStoreVideos();

      if (_detectedVideos == null || !_detectedVideos!.downloadableFound) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('No Videos Found'),
            content: Text('No downloadable videos detected on this page.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    // Reset selection
    _selectedVideo = null;

    // Show bottom sheet using stored videos
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final videoInfo = _detectedVideos!;
            final screenWidth = MediaQuery.of(context).size.width;

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Draggable handle
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Adaptive Thumbnail
                            Container(
                              width: double.infinity,
                              height: screenWidth * 0.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: videoInfo.thumbnail.isNotEmpty
                                    ? DecorationImage(
                                        image:
                                            NetworkImage(videoInfo.thumbnail),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: Colors.grey[200],
                              ),
                              child: videoInfo.thumbnail.isEmpty
                                  ? Center(
                                      child: Icon(
                                        Icons.video_library,
                                        size: 50,
                                        color: Colors.grey[400],
                                      ),
                                    )
                                  : null,
                            ),

                            SizedBox(height: 16),

                            // Title
                            Text(
                              videoInfo.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 8),

                            // Duration
                            Row(
                              children: [
                                Icon(Icons.schedule,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 6),
                                Text(
                                  _getVideoDuration(videoInfo),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),

                            // Available Qualities Text
                            Text(
                              'Available Qualities',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            SizedBox(height: 12),

                            // Quality buttons in Wrap
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children:
                                  videoInfo.downloadableVideos.map((video) {
                                final isSelected = video == _selectedVideo;
                                return _buildQualityButton(
                                  context,
                                  video,
                                  isSelected,
                                  () {
                                    setState(() {
                                      _selectedVideo =
                                          isSelected ? null : video;
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Download button (fixed at bottom)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey[200]!)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (_selectedVideo != null)
                          Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Selected: ${_selectedVideo!.quality}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  _selectedVideo!.size,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selectedVideo != null
                                ? () {
                                    _startDownload(videoInfo, _selectedVideo!);
                                    Navigator.pop(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'DOWNLOAD',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getVideoDuration(VideoInfo videoInfo) {
    if (videoInfo.downloadableVideos.isNotEmpty) {
      final firstVideo = videoInfo.downloadableVideos.first;
      if (firstVideo.duration != 'Unknown') {
        return firstVideo.duration;
      }
    }
    return 'Unknown duration';
  }

  Widget _buildQualityButton(
    BuildContext context,
    VideoFormat video,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              video.quality,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              video.size,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startDownload(VideoInfo videoInfo, VideoFormat video) {
    final provider = Provider.of<DownloadProvider>(context, listen: false);

    provider.downloadVideo(
      pageUrl: _currentUrl,
      formatId: video.formatId,
      estSize: video.size,
      title: videoInfo.title,
      thumbnailUrl: videoInfo.thumbnail,

    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download started - ${video.quality}'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
