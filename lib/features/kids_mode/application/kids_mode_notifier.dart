import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/kids_mode/application/kids_mode_state.dart';
import 'package:memo_care/features/kids_mode/domain/kids_models.dart';

/// Manages Kids Mode state — activation, quests, points, and stars.
class KidsModeNotifier extends Notifier<KidsModeState> {
  @override
  KidsModeState build() => const KidsModeState(
    childName: 'Friend',
    dailyQuests: [
      Quest(
        id: 'q1',
        title: 'Wake up and stretch',
        time: '7:00 AM',
        category: 'health',
      ),
      Quest(
        id: 'q2',
        title: 'Take your medicine',
        time: '7:15 AM',
        category: 'medicine',
      ),
      Quest(
        id: 'q3',
        title: 'Have breakfast',
        time: '7:30 AM',
        category: 'meal',
      ),
      Quest(
        id: 'q4',
        title: 'Take your vitamin',
        time: '7:45 AM',
        category: 'medicine',
      ),
      Quest(
        id: 'q5',
        title: 'Pack your school bag',
        time: '8:00 AM',
      ),
    ],
  );

  /// Activate/deactivate kids mode.
  void setActive({required bool active}) {
    state = state.copyWith(isActive: active);
  }

  /// Set the child's display name.
  void setChildName(String name) {
    state = state.copyWith(childName: name);
  }

  /// Mark a quest as completed by [questId].
  void completeQuest(String questId) {
    final updated = state.dailyQuests.map((q) {
      if (q.id == questId && !q.isCompleted) {
        return q.copyWith(isCompleted: true);
      }
      return q;
    }).toList();

    final completedCount = updated.where((q) => q.isCompleted).length;
    final total = updated.length;
    final allDone = completedCount == total && total > 0;

    // Award 10 pts per task, 50 bonus when all done.
    const earnedPoints = 10;
    final bonus = allDone && !state.allQuestsComplete ? 50 : 0;
    final newDaily = state.points.dailyPoints + earnedPoints + bonus;
    final newTotal = state.points.totalPoints + earnedPoints + bonus;

    // Star rating: 1-5 based on percentage.
    final pct = total > 0 ? completedCount / total : 0.0;
    final stars = (pct * 5).round().clamp(0, 5);

    state = state.copyWith(
      dailyQuests: updated,
      allQuestsComplete: allDone,
      starRating: stars,
      points: state.points.copyWith(
        dailyPoints: newDaily,
        totalPoints: newTotal,
      ),
    );
  }

  /// Reset daily quests and points for a new day.
  void resetDay() {
    final reset = state.dailyQuests
        .map((q) => q.copyWith(isCompleted: false))
        .toList();
    state = state.copyWith(
      dailyQuests: reset,
      allQuestsComplete: false,
      starRating: 0,
      points: state.points.copyWith(dailyPoints: 0),
    );
  }
}

/// Provider — keep-alive so points survive tab switches.
final kidsModeNotifierProvider =
    NotifierProvider<KidsModeNotifier, KidsModeState>(
      KidsModeNotifier.new,
    );
