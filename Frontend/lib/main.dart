// main.dart
import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:provider/provider.dart';
import 'models/color_schemes.dart';
import 'screens/home_screen.dart';
import 'providers/download_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MediaStore.ensureInitialized();
  MediaStore.appFolder = "MyDownloader";

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Choose your theme combination here:
    final lightTheme = AppColorSchemes.pinkChic; // Change to any light theme
    final darkTheme = AppColorSchemes.darkOcean;     // Change to any dark theme

    return  MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Video Downloader Pro',
        theme: ThemeData.from(
          colorScheme: lightTheme,
          useMaterial3: true,
        ).copyWith(
          // Customize specific components
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: lightTheme.primary,
            iconTheme: IconThemeData(color: lightTheme.onPrimary),
            titleTextStyle: TextStyle(
              color: lightTheme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: lightTheme.secondary,
            foregroundColor: lightTheme.onSecondary,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: lightTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),

        darkTheme: ThemeData.from(
          colorScheme: darkTheme,
          useMaterial3: true,
        ).copyWith(
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: darkTheme.surface,
            iconTheme: IconThemeData(color: darkTheme.onSurface),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: darkTheme.secondary,
            foregroundColor: darkTheme.onSecondary,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: darkTheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
        home: HomeScreen(),
    );
  }
}