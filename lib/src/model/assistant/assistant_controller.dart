import 'dart:async';

import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/assistant/assistant_preferences.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/engine/engine.dart';
import 'package:lichess_mobile/src/model/engine/engine_providers.dart';
import 'package:lichess_mobile/src/model/engine/engine_spec.dart';

/// Provides the current set of engine arrows for the active game position.
final assistantControllerProvider =
    StateNotifierProvider.autoDispose<AssistantController, AssistantState>(
  (ref) => AssistantController(ref),
);

class AssistantState {
  const AssistantState({
    this.shapes = const {},
    this.bestMove,
    this.eval,
  });

  final Set<Shape> shapes;
  final Move? bestMove;
  final double? eval;

  AssistantState copyWith({
    Set<Shape>? shapes,
    Move? bestMove,
    double? eval,
  }) {
    return AssistantState(
      shapes: shapes ?? this.shapes,
      bestMove: bestMove ?? this.bestMove,
      eval: eval ?? this.eval,
    );
  }
}

class AssistantController extends StateNotifier<AssistantState> {
  AssistantController(this._ref) : super(const AssistantState()) {
    _prefsSub = _ref.listen(assistantPreferencesProvider, (_, __) {
      _restartSearch();
    });
  }

  final Ref _ref;
  late final ProviderSubscription<AssistantPreferences> _prefsSub;

  Position? _currentPosition;
  Side? _userSide;
  Search? _currentSearch;
  StreamSubscription<UciInfo>? _infoSub;

  /// Call this from the game / analysis screen whenever the position or side-to-move changes.
  void updatePosition({
    required Position position,
    required Side userSide,
  }) {
    if (_currentPosition == position && _userSide == userSide) return;
    _currentPosition = position;
    _userSide = userSide;
    _restartSearch();
  }

  Future<void> _restartSearch() async {
    _currentSearch?.stop();
    _infoSub?.cancel();
    state = const AssistantState();

    final prefs = _ref.read(assistantPreferencesProvider);
    final pos = _currentPosition;
    final side = _userSide;

    if (!prefs.enabled || pos == null || side == null) return;
    if (pos.turn != side) return;

    try {
      final spec = prefs.useMaia ? const Lc0Spec() : const StockfishSpec.light();
      final engine = await _ref.read(engineProvider(spec).future);

      if (!_ref.mounted) return;

      _currentSearch = engine.search(
        SearchRequest(
          initialPosition: pos,
          moves: const IListConst([]),
          variant: Variant.chess,
          limit: SearchLimit.depth(_eloToDepth(prefs.elo)),
          multiPv: prefs.arrowCount,
          game: 'assistant',
        ),
      );

      _infoSub = _currentSearch!.infos.listen(_onInfo);
    } catch (e) {
      // Engine failed to start; leave state empty.
    }
  }

  void _onInfo(UciInfo info) {
    final shapes = <Shape>{};
    Move? best;

    // info.pv contains UCI strings; take up to arrowCount.
    final count = _ref.read(assistantPreferencesProvider).arrowCount;
    for (final uci in info.pv.take(count)) {
      final move = Move.fromUci(uci);
      if (move is NormalMove) {
        shapes.add(
          Arrow(
            color: best == null ? ShapeColor.green : ShapeColor.blue,
            orig: move.from,
            dest: move.to,
          ),
        );
        best ??= move;
      }
    }

    final eval = info.mate != null
        ? (info.mate! > 0 ? 10.0 : -10.0)
        : (info.cp ?? 0) / 100.0;

    state = state.copyWith(
      shapes: shapes,
      bestMove: best,
      eval: eval,
    );
  }

  int _eloToDepth(int elo) {
    if (elo >= 2800) return 18;
    if (elo >= 2400) return 15;
    if (elo >= 2000) return 12;
    if (elo >= 1600) return 10;
    if (elo >= 1200) return 8;
    if (elo >= 800) return 6;
    return 4;
  }

  @override
  void dispose() {
    _currentSearch?.stop();
    _infoSub?.cancel();
    _prefsSub.close();
    super.dispose();
  }
}
