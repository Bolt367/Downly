// color_schemes.dart
import 'package:flutter/material.dart';

class AppColorSchemes {
  // ==================== LIGHT THEMES ====================

  static final ColorScheme modernBlue = const ColorScheme.light(
    primary: Color(0xFF1976D2),      // Deep Blue
    primaryContainer: Color(0xFF1565C0),
    secondary: Color(0xFF00ACC1),    // Teal
    secondaryContainer: Color(0xFF0097A7),
    tertiary: Color(0xFFFF9800),     // Amber for actions
    tertiaryContainer: Color(0xFFF57C00),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE3F2FD), // Light blue surface
    background: Color(0xFFF4F6F8),   // Soft gray
    error: Color(0xFFD32F2F),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.black,
    onSurface: Color(0xFF1A1A1A),
    onBackground: Color(0xFF1A1A1A),
    onError: Colors.white,
    outline: Color(0xFFE0E0E0),
    outlineVariant: Color(0xFFEEEEEE),
  );

  static final ColorScheme greenBoost = const ColorScheme.light(
    primary: Color(0xFF2E7D32),     // Forest Green
    primaryContainer: Color(0xFF1B5E20),
    secondary: Color(0xFF2196F3),   // Blue
    secondaryContainer: Color(0xFF0D47A1),
    tertiary: Color(0xFFFFB300),    // Amber
    tertiaryContainer: Color(0xFFF57C00),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE8F5E8), // Light green surface
    background: Color(0xFFF1F8E9),  // Very light green
    error: Color(0xFFC62828),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.black,
    onSurface: Color(0xFF1B1B1B),
    onBackground: Color(0xFF1B1B1B),
    onError: Colors.white,
    outline: Color(0xFFC8E6C9),
    outlineVariant: Color(0xFFE8F5E9),
  );

  static final ColorScheme purpleNeon = const ColorScheme.light(
    primary: Color(0xFF7C4DFF),     // Deep Purple
    primaryContainer: Color(0xFF651FFF),
    secondary: Color(0xFF00E676),   // Neon Green
    secondaryContainer: Color(0xFF00C853),
    tertiary: Color(0xFFFF4081),    // Pink accent
    tertiaryContainer: Color(0xFFF50057),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF3E5F5), // Light purple surface
    background: Color(0xFFF8F7FF),  // Very light purple
    error: Color(0xFFF44336),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onTertiary: Colors.white,
    onSurface: Color(0xFF212121),
    onBackground: Color(0xFF212121),
    onError: Colors.white,
    outline: Color(0xFFE1BEE7),
    outlineVariant: Color(0xFFF3E5F5),
  );

  static final ColorScheme orangeEnergy = const ColorScheme.light(
    primary: Color(0xFFFF5722),     // Deep Orange
    primaryContainer: Color(0xFFD84315),
    secondary: Color(0xFF2196F3),   // Blue
    secondaryContainer: Color(0xFF0D47A1),
    tertiary: Color(0xFF4CAF50),    // Green for success
    tertiaryContainer: Color(0xFF2E7D32),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFFFF3E0), // Light orange surface
    background: Color(0xFFFFF5F5),  // Very light red tint
    error: Color(0xFFD32F2F),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onSurface: Color(0xFF1A1A1A),
    onBackground: Color(0xFF1A1A1A),
    onError: Colors.white,
    outline: Color(0xFFFFCCBC),
    outlineVariant: Color(0xFFFFE0B2),
  );

  static final ColorScheme tealElegance = const ColorScheme.light(
    primary: Color(0xFF009688),     // Teal
    primaryContainer: Color(0xFF00796B),
    secondary: Color(0xFFFF9800),   // Orange
    secondaryContainer: Color(0xFFF57C00),
    tertiary: Color(0xFF2196F3),    // Blue for links
    tertiaryContainer: Color(0xFF1976D2),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE0F2F1), // Light teal surface
    background: Color(0xFFF8FDFD),  // Very light teal tint
    error: Color(0xFFC62828),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onTertiary: Colors.white,
    onSurface: Color(0xFF1A1A1A),
    onBackground: Color(0xFF1A1A1A),
    onError: Colors.white,
    outline: Color(0xFFB2DFDB),
    outlineVariant: Color(0xFFE0F2F1),
  );

  static final ColorScheme redPower = const ColorScheme.light(
    primary: Color(0xFFD32F2F),     // Red
    primaryContainer: Color(0xFFB71C1C),
    secondary: Color(0xFF303F9F),   // Indigo
    secondaryContainer: Color(0xFF283593),
    tertiary: Color(0xFF388E3C),    // Green for success
    tertiaryContainer: Color(0xFF2E7D32),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFFFEBEE), // Light red surface
    background: Color(0xFFFFF5F5),  // Very light red
    error: Color(0xFFC62828),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onSurface: Color(0xFF1A1A1A),
    onBackground: Color(0xFF1A1A1A),
    onError: Colors.white,
    outline: Color(0xFFFFCDD2),
    outlineVariant: Color(0xFFFFEBEE),
  );

  static final ColorScheme pinkChic = const ColorScheme.light(
    primary: Color(0xFFE91E63),     // Pink
    primaryContainer: Color(0xFFC2185B),
    secondary: Color(0xFF00BCD4),   // Cyan
    secondaryContainer: Color(0xFF0097A7),
    tertiary: Color(0xFFFF9800),    // Amber
    tertiaryContainer: Color(0xFFF57C00),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFFCE4EC), // Light pink surface
    background: Color(0xFFFEF5F9),  // Very light pink
    error: Color(0xFFD32F2F),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.black,
    onSurface: Color(0xFF1A1A1A),
    onBackground: Color(0xFF1A1A1A),
    onError: Colors.white,
    outline: Color(0xFFF8BBD0),
    outlineVariant: Color(0xFFFCE4EC),
  );

  // ==================== DARK THEMES ====================

  static final ColorScheme darkPro = const ColorScheme.dark(
    primary: Color(0xFF00E5FF),     // Cyan
    primaryContainer: Color(0xFF00B8D4),
    secondary: Color(0xFFFF9100),   // Orange accent
    secondaryContainer: Color(0xFFF57C00),
    tertiary: Color(0xFF4CAF50),    // Green for downloads
    tertiaryContainer: Color(0xFF388E3C),
    surface: Color(0xFF1E293B),
    surfaceVariant: Color(0xFF334155),
    background: Color(0xFF0F172A),  // Deep navy
    error: Color(0xFFCF6679),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onTertiary: Colors.white,
    onSurface: Color(0xFFF1F5F9),
    onBackground: Color(0xFFF1F5F9),
    onError: Colors.black,
    outline: Color(0xFF475569),
    outlineVariant: Color(0xFF334155),
  );

  static final ColorScheme darkOcean = const ColorScheme.dark(
    primary: Color(0xFF64B5F6),     // Light Blue
    primaryContainer: Color(0xFF1976D2),
    secondary: Color(0xFFFFB74D),   // Light Orange
    secondaryContainer: Color(0xFFF57C00),
    tertiary: Color(0xFF81C784),    // Light Green
    tertiaryContainer: Color(0xFF388E3C),
    surface: Color(0xFF1C1F26),
    surfaceVariant: Color(0xFF2D3748),
    background: Color(0xFF121212),  // True black
    error: Color(0xFFCF6679),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onTertiary: Colors.black,
    onSurface: Color(0xFFE2E8F0),
    onBackground: Color(0xFFE2E8F0),
    onError: Colors.black,
    outline: Color(0xFF4A5568),
    outlineVariant: Color(0xFF2D3748),
  );

  static final ColorScheme darkPurple = const ColorScheme.dark(
    primary: Color(0xFFBB86FC),     // Purple
    primaryContainer: Color(0xFF3700B3),
    secondary: Color(0xFF03DAC6),   // Teal
    secondaryContainer: Color(0xFF018786),
    tertiary: Color(0xFFFFB74D),    // Amber
    tertiaryContainer: Color(0xFFF57C00),
    surface: Color(0xFF1E1B26),
    surfaceVariant: Color(0xFF332940),
    background: Color(0xFF121212),
    error: Color(0xFFCF6679),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onTertiary: Colors.black,
    onSurface: Color(0xFFE6E1E6),
    onBackground: Color(0xFFE6E1E6),
    onError: Colors.black,
    outline: Color(0xFF49454F),
    outlineVariant: Color(0xFF332940),
  );

  static final ColorScheme darkAmber = const ColorScheme.dark(
    primary: Color(0xFFFFB74D),     // Amber
    primaryContainer: Color(0xFFFF9100),
    secondary: Color(0xFF64B5F6),   // Blue
    secondaryContainer: Color(0xFF1976D2),
    tertiary: Color(0xFF81C784),    // Green
    tertiaryContainer: Color(0xFF388E3C),
    surface: Color(0xFF1E1B18),
    surfaceVariant: Color(0xFF3C3834),
    background: Color(0xFF121212),
    error: Color(0xFFCF6679),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onTertiary: Colors.black,
    onSurface: Color(0xFFE6E1E6),
    onBackground: Color(0xFFE6E1E6),
    onError: Colors.black,
    outline: Color(0xFF5D5A57),
    outlineVariant: Color(0xFF3C3834),
  );

  static final ColorScheme darkGreen = const ColorScheme.dark(
    primary: Color(0xFF81C784),     // Green
    primaryContainer: Color(0xFF388E3C),
    secondary: Color(0xFF64B5F6),   // Blue
    secondaryContainer: Color(0xFF1976D2),
    tertiary: Color(0xFFFFB74D),    // Amber
    tertiaryContainer: Color(0xFFF57C00),
    surface: Color(0xFF1B1F1C),
    surfaceVariant: Color(0xFF2D332D),
    background: Color(0xFF121212),
    error: Color(0xFFCF6679),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onTertiary: Colors.black,
    onSurface: Color(0xFFE6E1E6),
    onBackground: Color(0xFFE6E1E6),
    onError: Colors.black,
    outline: Color(0xFF495049),
    outlineVariant: Color(0xFF2D332D),
  );

  static final ColorScheme darkRed = const ColorScheme.dark(
    primary: Color(0xFFF48FB1),     // Pink
    primaryContainer: Color(0xFFAD1457),
    secondary: Color(0xFF64B5F6),   // Blue
    secondaryContainer: Color(0xFF1565C0),
    tertiary: Color(0xFFFFB74D),    // Amber
    tertiaryContainer: Color(0xFFF57C00),
    surface: Color(0xFF1F1A1C),
    surfaceVariant: Color(0xFF382D32),
    background: Color(0xFF121212),
    error: Color(0xFFCF6679),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onTertiary: Colors.black,
    onSurface: Color(0xFFECE0E5),
    onBackground: Color(0xFFECE0E5),
    onError: Colors.black,
    outline: Color(0xFF4F4348),
    outlineVariant: Color(0xFF382D32),
  );

  // Helper to get all light theme names
  static List<String> get lightThemeNames => [
    'Modern Blue',
    'Green Boost',
    'Purple Neon',
    'Orange Energy',
    'Teal Elegance',
    'Red Power',
    'Pink Chic',
  ];

  // Helper to get all dark theme names
  static List<String> get darkThemeNames => [
    'Dark Pro',
    'Dark Ocean',
    'Dark Purple',
    'Dark Amber',
    'Dark Green',
    'Dark Red',
  ];

  // Get theme by name
  static ColorScheme getLightTheme(String name) {
    switch (name) {
      case 'Modern Blue': return modernBlue;
      case 'Green Boost': return greenBoost;
      case 'Purple Neon': return purpleNeon;
      case 'Orange Energy': return orangeEnergy;
      case 'Teal Elegance': return tealElegance;
      case 'Red Power': return redPower;
      case 'Pink Chic': return pinkChic;
      default: return modernBlue;
    }
  }

  static ColorScheme getDarkTheme(String name) {
    switch (name) {
      case 'Dark Pro': return darkPro;
      case 'Dark Ocean': return darkOcean;
      case 'Dark Purple': return darkPurple;
      case 'Dark Amber': return darkAmber;
      case 'Dark Green': return darkGreen;
      case 'Dark Red': return darkRed;
      default: return darkPro;
    }
  }
}