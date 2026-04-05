import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_shadows.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Global navigator key — used by the notification tap callback
// ignore: comment_references // workaround
/// in [main.dart] to navigate to the alarm screen from outside
/// the widget tree.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Root application widget.
///
/// Configures:
/// - `GoRouter` for declarative navigation
/// - Navy-primary Material 3 theme with Inter font
/// - Design-token-based colour, typography, and component system
class MemoCareApp extends ConsumerStatefulWidget {
  /// Creates the root [MemoCareApp].
  const MemoCareApp({
    this.initialAlarmReminderId,
    super.key,
  });

  /// Reminder ID to auto-open on cold-start notification launch.
  final int? initialAlarmReminderId;

  @override
  ConsumerState<MemoCareApp> createState() => _MemoCareAppState();
}

class _MemoCareAppState extends ConsumerState<MemoCareApp> {
  var _handledInitialAlarmNavigation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToInitialAlarmIfNeeded();
    });
  }

  void _navigateToInitialAlarmIfNeeded() {
    if (_handledInitialAlarmNavigation) return;
    final reminderId = widget.initialAlarmReminderId;
    if (reminderId == null) return;

    final context = appNavigatorKey.currentContext;
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToInitialAlarmIfNeeded();
      });
      return;
    }

    _handledInitialAlarmNavigation = true;
    GoRouter.of(context).go('${AppRoutes.alarm}/$reminderId');
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'MemoCare',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: router,
    );
  }

  static ThemeData _buildTheme() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.accent.withValues(alpha: 0.12),
      onSecondaryContainer: AppColors.accent,
      tertiary: AppColors.accentTeal,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.cardBg,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      shadow: Colors.black,
    );

    final textTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,

      // ── App bar ─────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimary,
        ),
      ),

      // ── Cards ───────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        shadowColor: AppShadows.card.first.color,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.cardGap / 2),
      ),

      // ── Elevated buttons ────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),

      // ── Outlined buttons ────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          side: const BorderSide(color: AppColors.primary),
        ),
      ),

      // ── Text buttons ───────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, AppSpacing.buttonHeight),
          foregroundColor: AppColors.accent,
          textStyle: GoogleFonts.inter(fontSize: 15),
        ),
      ),

      // ── Input decoration ────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: AppTypography.bodyMedium,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.skippedGrey,
        ),
      ),

      // ── Bottom navigation bar ───────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        height: AppSpacing.navBarHeight,
        backgroundColor: AppColors.cardBg,
        indicatorColor: AppColors.primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.labelSmall.copyWith(
            color: AppColors.skippedGrey,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: AppSpacing.navIconSize,
            );
          }
          return const IconThemeData(
            color: AppColors.skippedGrey,
            size: AppSpacing.navIconSize,
          );
        }),
      ),

      // ── FAB ─────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Chips ───────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        backgroundColor: AppColors.primaryLight,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.labelMedium,
      ),

      // ── Divider ─────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
