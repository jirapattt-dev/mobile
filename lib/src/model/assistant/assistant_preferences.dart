import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/settings/preferences_storage.dart';

part 'assistant_preferences.freezed.dart';

@freezed
class AssistantPreferences with _$AssistantPreferences {
  const factory AssistantPreferences({
    @Default(true) bool enabled,
    @Default(1200) int elo,
    @Default(1) int arrowCount,
    @Default(false) bool autoPlay,
    @Default(0.5) double autoPlayDelay,
    @Default(false) bool useMaia,
    @Default(true) bool showEvalLabels,
  }) = _AssistantPreferences;

  factory AssistantPreferences.fromJson(Map<String, dynamic> json) =>
      _$AssistantPreferencesFromJson(json);
}

final assistantPreferencesProvider =
    StateNotifierProvider<AssistantPreferencesNotifier, AssistantPreferences>(
  (ref) => AssistantPreferencesNotifier(ref),
);

class AssistantPreferencesNotifier extends StateNotifier<AssistantPreferences>
    with PreferencesStorage<AssistantPreferences> {
  AssistantPreferencesNotifier(this._ref) : super(const AssistantPreferences()) {
    load();
  }

  final Ref _ref;

  @override
  Ref get ref => _ref;

  @override
  String get storageKey => 'assistant_preferences';

  @override
  AssistantPreferences fromJson(Map<String, dynamic> json) =>
      AssistantPreferences.fromJson(json);

  @override
  Map<String, dynamic> toJson(AssistantPreferences prefs) => prefs.toJson();

  void setEnabled(bool value) {
    state = state.copyWith(enabled: value);
    save();
  }

  void setElo(int value) {
    state = state.copyWith(elo: value.clamp(400, 3500));
    save();
  }

  void setArrowCount(int value) {
    state = state.copyWith(arrowCount: value.clamp(1, 3));
    save();
  }

  void setAutoPlay(bool value) {
    state = state.copyWith(autoPlay: value);
    save();
  }

  void setAutoPlayDelay(double value) {
    state = state.copyWith(autoPlayDelay: value.clamp(0.0, 5.0));
    save();
  }

  void setUseMaia(bool value) {
    state = state.copyWith(useMaia: value);
    save();
  }
}
