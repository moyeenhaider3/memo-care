import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/kids_mode/application/kids_mode_notifier.dart';

/// Reward flow state used to trigger one-time celebration navigation.
class RewardState {
  const RewardState({
    this.rewardTriggered = false,
    this.useSoundVariant = false,
  });

  final bool rewardTriggered;
  final bool useSoundVariant;

  RewardState copyWith({
    bool? rewardTriggered,
    bool? useSoundVariant,
  }) {
    return RewardState(
      rewardTriggered: rewardTriggered ?? this.rewardTriggered,
      useSoundVariant: useSoundVariant ?? this.useSoundVariant,
    );
  }
}

class RewardNotifier extends Notifier<RewardState> {
  @override
  RewardState build() {
    ref.listen(kidsModeNotifierProvider, (previous, next) {
      final wasComplete = previous?.allQuestsComplete ?? false;
      if (!wasComplete && next.allQuestsComplete) {
        state = state.copyWith(rewardTriggered: true);
      }

      if (wasComplete && !next.allQuestsComplete) {
        state = state.copyWith(rewardTriggered: false);
      }
    });

    return const RewardState();
  }

  void consumeTrigger() {
    if (state.rewardTriggered) {
      state = state.copyWith(rewardTriggered: false);
    }
  }

  // ignore: avoid_positional_boolean_parameters // workaround
  void setUseSoundVariant(bool useSoundVariant) {
    state = state.copyWith(useSoundVariant: useSoundVariant);
  }
}

final rewardNotifierProvider = NotifierProvider<RewardNotifier, RewardState>(
  RewardNotifier.new,
);
