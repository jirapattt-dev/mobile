import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/assistant/assistant_preferences.dart';

/// Call this to show the assistant settings.
void showAssistantSettings(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const AssistantSettingsSheet(),
  );
}

class AssistantSettingsSheet extends ConsumerWidget {
  const AssistantSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(assistantPreferencesProvider);
    final notifier = ref.read(assistantPreferencesProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chess Assistant', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Enabled'),
            value: prefs.enabled,
            onChanged: notifier.setEnabled,
          ),
          ListTile(
            title: const Text('Strength (ELO)'),
            subtitle: Slider(
              value: prefs.elo.toDouble(),
              min: 400,
              max: 3500,
              divisions: 31,
              label: prefs.elo.toString(),
              onChanged: (v) => notifier.setElo(v.round()),
            ),
            trailing: Text(prefs.elo.toString()),
          ),
          ListTile(
            title: const Text('Arrows'),
            subtitle: Slider(
              value: prefs.arrowCount.toDouble(),
              min: 1,
              max: 3,
              divisions: 2,
              label: prefs.arrowCount.toString(),
              onChanged: (v) => notifier.setArrowCount(v.round()),
            ),
            trailing: Text(prefs.arrowCount.toString()),
          ),
          SwitchListTile(
            title: const Text('Auto-play'),
            value: prefs.autoPlay,
            onChanged: notifier.setAutoPlay,
          ),
          if (prefs.autoPlay)
            ListTile(
              title: const Text('Delay (seconds)'),
              subtitle: Slider(
                value: prefs.autoPlayDelay,
                min: 0,
                max: 5,
                divisions: 10,
                label: prefs.autoPlayDelay.toStringAsFixed(1),
                onChanged: notifier.setAutoPlayDelay,
              ),
              trailing: Text(prefs.autoPlayDelay.toStringAsFixed(1)),
            ),
          SwitchListTile(
            title: const Text('Use Maia (Lc0)'),
            subtitle: const Text('Experimental – falls back to Stockfish if unavailable'),
            value: prefs.useMaia,
            onChanged: notifier.setUseMaia,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
