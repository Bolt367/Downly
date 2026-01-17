import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';
import 'browser_screen.dart';
import 'downloads_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  late TabController _tabController;
  List<BrowserTab> _tabs = [];
  int _currentTabIndex = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _tabs.add(BrowserTab(
      id: 'tab_1',
      title: 'New Tab',
      url: '',
    ));

    // Auto-request permissions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestStoragePermission();
    });
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return status.isGranted;
    }
    return true;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0: // Browser
        return _buildBrowserContent();
      case 1: // Downloads
        return DownloadsScreen();
      case 2: // Settings
        return _buildSettingsScreen();
      default:
        return _buildBrowserContent();
    }
  }

  void _submitUrl(BuildContext context) {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrowserTabScreen(
          initialUrl: url,
          tabId: _tabs[_currentTabIndex].id,
        ),
      ),
    );
    debugPrint('Processing URL: $url');
  }

  Widget _buildBrowserContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: MediaQuery.of(context).size.height < 650
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),

            // App Icon/Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.download_for_offline,
                size: 50,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 30),

            // App Name
            Text(
              'Video Downloader',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 10),

            // Description Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Enter video or page URL to download',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),

            SizedBox(height: 50),

            // Search Box Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // URL Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          Icon(Icons.link, color: Colors.grey[500], size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onSubmitted: (_) => _submitUrl(context),
                              controller: _urlController,
                              focusNode: _urlFocusNode,
                              decoration: InputDecoration(
                                hintText: 'https://www.example.com/watch?v=...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 15),
                              ),
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          if (_urlController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.clear,
                                  size: 18, color: Colors.grey[500]),
                              onPressed: () => _urlController.clear(),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Search/Download Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _submitUrl(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'SEARCH',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // Optional: Supported sites info
                    Text(
                      "Smart detection for supported video formats",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),

            // Recent Downloads or Tips Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20),
                        SizedBox(width: 10),
                        Text(
                          'How to use:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      '1. Copy the video/Web URL from your browser\n'
                      '2. Paste it in the field above\n'
                      '3. Click "SEARCH" to find available videos\n'
                      '4. Choose video quality and format\n'
                      '5. Download to your device',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Download status indicator from provider
            Consumer<DownloadProvider>(
              builder: (context, provider, child) {
                final activeDownloads = provider.activeDownloads.length;

                if (activeDownloads > 0) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              Icon(Icons.download,
                                  color: Theme.of(context).colorScheme.primary),
                              if (activeDownloads > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
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
                          ),
                          SizedBox(width: 10),
                          Text(
                            '$activeDownloads active download${activeDownloads > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.chevron_right,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16),
                        ],
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[500],
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Downloads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          SizedBox(height: 20),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.storage),
            title: Text('Storage Location'),
            subtitle: Text('/storage/emulated/0/Download'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to storage settings
            },
          ),
          ListTile(
            leading: Icon(Icons.perm_device_information),
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}

class BrowserTab {
  final String id;
  String title;
  String url;

  BrowserTab({
    required this.id,
    required this.title,
    required this.url,
  });
}
