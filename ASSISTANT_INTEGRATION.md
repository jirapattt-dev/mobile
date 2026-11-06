# Integration sketch (add to your game screen)

In the widget that currently builds the live-game `BoardWidget`, change it roughly like this:

```dart
final assistantState = ref.watch(assistantControllerProvider);
final prefs = ref.watch(assistantPreferencesProvider);

// Somewhere in the build method, after you know the current position:
ref.read(assistantControllerProvider.notifier).updatePosition(
  position: currentPosition,
  userSide: mySide,
);

return BoardWidget(
  size: boardSize,
  orientation: orientation,
  controller: boardController,
  onMove: onMove,
  shapes: {
    ...existingShapes,           // keep any analysis/last-move highlights
    ...assistantState.shapes,    // engine arrows
  },
  // optional floating button overlay
  boardOverlay: prefs.enabled
      ? Positioned(
          right: 8,
          bottom: 8,
          child: FloatingActionButton.small(
            onPressed: () => showAssistantSettings(context, ref),
            child: const Icon(Icons.smart_toy),
          ),
        )
      : null,
);
```

## Auto-play hook (optional)

Listen to `assistantState.bestMove` and, when auto-play is enabled, schedule:

```dart
if (prefs.autoPlay && assistantState.bestMove != null) {
  Future.delayed(Duration(milliseconds: (prefs.autoPlayDelay * 1000).round()), () {
    if (mounted) onMove(assistantState.bestMove!);
  });
}
```

## Next steps after dropping these files in

1. Run `dart run build_runner build --delete-conflicting-outputs` to generate the freezed code.
2. Wire a real `Engine` instance (the app already has an engine pool in `lib/src/model/engine/`).
3. Convert UCI PVs into `Shape` / `Arrow` objects (see analysis board for examples).
4. Add a simple settings sheet that calls the setters on `assistantPreferencesProvider`.
5. Test on a practice or analysis board first, then move to the live game screen.
