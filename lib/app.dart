import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memo_care/core/router/app_router.dart';

/// Root application widget.
///
/// Configures:
/// - `GoRouter` for declarative navigation
/// - Teal-seeded Material 3 theme
/// - Noto Sans font for Hindi compatibility
/// - Minimum 18 pt body text (ONBD-05)
/// - High-contrast colours and 56 dp touch targets (P-07)
class MemoCareApp extends ConsumerWidget {
  /// Creates the root [MemoCareApp].
  const MemoCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'MemoCare',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: router,
    );
  }

  static ThemeData _buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
    );

    final textTheme = GoogleFonts.notoSansTextTheme().copyWith(
      bodyLarge: GoogleFonts.notoSans(fontSize: 20, height: 1.5),
      bodyMedium: GoogleFonts.notoSans(
        fontSize: 18,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.notoSans(
        fontSize: 18,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.notoSans(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.notoSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.notoSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: GoogleFonts.notoSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          textStyle: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          textStyle: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 56),
          textStyle: GoogleFonts.notoSans(fontSize: 18),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.notoSans(fontSize: 18),
        hintStyle: GoogleFonts.notoSans(fontSize: 18),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
