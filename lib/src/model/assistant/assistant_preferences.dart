import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/src/model/settings/preferences_storage.dart';

part 'assistant_preferences.freezed.dart';
part 'assistant_preferences.g.dart';

final assistantPreferencesProvider =
    NotifierProvider<AssistantPreferencesNotifier, AssistantPreferences>(
  AssistantPreferencesNotifier.new,
);

class AssistantPreferencesNotifier()
    extends Notifier<AssistantPreferences>
    with PreferencesStorage<AssistantPreferences> {
  @override
  AssistantPreferences build() => fetch();

  @override
  String get storageKey => 'assistant_preferences';

  @override
  AssistantPreferences fromJson(Map<String, dynamic> json) =>
      AssistantPreferences.fromJson(json);

  @override
  AssistantPreferences get defaults => const AssistantPreferences();

  Future<void> setEnabled(bool value) => save(state.copyWith(enabled: value));
  Future<void> setElo(int value) =>
      save(state.copyWith(elo: value.clamp(400, 3500)));
  Future<void> setArrowCount(int value) =>
      save(state.copyWith(arrowCount: value.clamp(1, 3)));
  Future<void> setAutoPlay(bool value) => save(state.copyWith(autoPlay: value));
  Future<void> setAutoPlayDelay(double value) =>
      save(state.copyWith(autoPlayDelay: value.clamp(0.0, 5.0)));
  Future<void> setUseMaia(bool value) => save(state.copyWith(useMaia: value));
}

@Freezed(fromJson: true, toJson: true)
sealed class const AssistantPreferences._() with _$AssistantPreferences {
  const factory({
    @Default(true) bool enabled,
    @Default(1200) int elo,
    @Default(1) int arrowCount,
    @Default(false) bool autoPlay,
    @Default(0.5) double autoPlayDelay,
    @Default(false) bool useMaia,
    @Default(true) bool showEvalLabels,
  }) = _AssistantPreferences;

  factory fromJson(Map<String, dynamic> json) =>
      _$AssistantPreferencesFromJson(json);
}
