import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/kids_theme.dart';
import 'package:memo_care/features/kids_mode/application/kids_mode_notifier.dart';
import 'package:memo_care/features/kids_mode/application/reward_notifier.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/daily_checklist.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/kids_bottom_nav.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/mascot_widget.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/parent_view_toggle.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/points_display.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/quest_progress_bar.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/star_rating.dart';

/// Kids Mode root screen — wrapped in [KidsTheme] so all children get the
/// purple palette automatically.
class KidsDashboardScreen extends ConsumerStatefulWidget {
  const KidsDashboardScreen({super.key});

  @override
  ConsumerState<KidsDashboardScreen> createState() =>
      _KidsDashboardScreenState();
}

class _KidsDashboardScreenState extends ConsumerState<KidsDashboardScreen> {
  int _navIndex = 0;
  ProviderSubscription<RewardState>? _rewardSubscription;

  @override
  void initState() {
    super.initState();
    _rewardSubscription = ref.listenManual(rewardNotifierProvider, (
      previous,
      next,
    ) {
      if (!mounted || !next.rewardTriggered) {
        return;
      }

      final target = next.useSoundVariant
          ? '/kids/reward-sound'
          : '/kids/reward';
      ref.read(rewardNotifierProvider.notifier).consumeTrigger();
      context.go(target);
    });
  }

  @override
  void dispose() {
    _rewardSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: KidsTheme.data,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_navIndex) {
      case 1:
        return _PrizesPlaceholder(onNavTap: _onNavTap);
      case 2:
        return _MePlaceholder(onNavTap: _onNavTap);
      case 0:
      default:
        return _QuestDashboard(onNavTap: _onNavTap);
    }
  }

  void _onNavTap(int index) => setState(() => _navIndex = index);
}

/// Quest / Main dashboard tab.
class _QuestDashboard extends ConsumerWidget {
  const _QuestDashboard({required this.onNavTap});

  final ValueChanged<int> onNavTap;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _mascotMessage(int completed, int total) {
    if (total == 0) return "Let's get started! 🎯";
    if (completed == 0) return "Let's do this! 💪";
    if (completed == total) return 'Amazing job! 🌟';
    return 'Keep going! 🚀';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kidsState = ref.watch(kidsModeNotifierProvider);
    final notifier = ref.read(kidsModeNotifierProvider.notifier);

    final completed = kidsState.dailyQuests.where((q) => q.isCompleted).length;
    final total = kidsState.dailyQuests.length;

    return Scaffold(
      backgroundColor: KidsColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative sparkle in background.
            const Positioned(
              bottom: 100,
              right: 12,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 96,
                  color: KidsColors.warmYellow,
                ),
              ),
            ),
            // Main scroll content.
            CustomScrollView(
              slivers: [
                // Top bar: Parent View toggle + Points.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        ParentViewToggle(
                          onUnlocked: () => context.go('/home'),
                        ),
                        const Spacer(),
                        PointsDisplay(
                          points: kidsState.points.totalPoints,
                        ),
                      ],
                    ),
                  ),
                ),
                // Header: greeting + star rating + mascot avatar.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_greeting()}, ${kidsState.childName}! 🌟',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF7C3AED),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              StarRating(rating: kidsState.starRating),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Robot avatar.
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: KidsColors.primary.withAlpha(25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: KidsColors.primary.withAlpha(30),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            size: 44,
                            color: KidsColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Quest progress bar.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: QuestProgressBar(
                      completed: completed,
                      total: total,
                      childName: kidsState.childName,
                    ),
                  ),
                ),
                // Daily checklist.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: DailyChecklist(
                      quests: kidsState.dailyQuests,
                      onComplete: notifier.completeQuest,
                    ),
                  ),
                ),
                // Mascot with speech bubble.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: MascotWidget(
                      message: _mascotMessage(completed, total),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: KidsBottomNav(
        currentIndex: 0,
        onTap: onNavTap,
      ),
    );
  }
}

/// Prizes tab placeholder.
class _PrizesPlaceholder extends StatelessWidget {
  const _PrizesPlaceholder({required this.onNavTap});

  final ValueChanged<int> onNavTap;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: KidsTheme.data,
      child: Scaffold(
        backgroundColor: KidsColors.background,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: 80,
                color: KidsColors.warmYellow,
              ),
              SizedBox(height: 16),
              Text(
                'Prizes coming soon! 🏆',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: KidsColors.primary,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: KidsBottomNav(
          currentIndex: 1,
          onTap: onNavTap,
        ),
      ),
    );
  }
}

/// Me tab placeholder.
class _MePlaceholder extends StatelessWidget {
  const _MePlaceholder({required this.onNavTap});

  final ValueChanged<int> onNavTap;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: KidsTheme.data,
      child: Scaffold(
        backgroundColor: KidsColors.background,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.face_rounded,
                size: 80,
                color: KidsColors.primary,
              ),
              SizedBox(height: 16),
              Text(
                'My Profile',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: KidsColors.primary,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: KidsBottomNav(
          currentIndex: 2,
          onTap: onNavTap,
        ),
      ),
    );
  }
}
