import 'dart:async';

import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/engine/engine.dart';
import 'package:lichess_mobile/src/model/assistant/assistant_preferences.dart';

/// Provides the current set of engine arrows for the active game position.
///
/// In a real integration you will feed this controller the current position
/// and side-to-move from the game screen / controller.
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

  /// Call this from the game screen whenever the position or side-to-move changes.
  void updatePosition({
    required Position position,
    required Side userSide,
  }) {
    if (_currentPosition == position && _userSide == userSide) return;
    _currentPosition = position;
    _userSide = userSide;
    _restartSearch();
  }

  void _restartSearch() {
    _currentSearch?.stop();
    _infoSub?.cancel();
    state = const AssistantState();

    final prefs = _ref.read(assistantPreferencesProvider);
    final pos = _currentPosition;
    final side = _userSide;

    if (!prefs.enabled || pos == null || side == null) return;
    if (pos.turn != side) return; // only suggest on user's turn

    // TODO: obtain a shared Engine instance from the app's engine pool.
    // For the skeleton we leave the actual Engine construction as a comment.
    //
    // final engine = _ref.read(engineProvider);
    //
    // _currentSearch = engine.search(SearchRequest(
    //   initialPosition: pos,
    //   moves: const IListConst([]),
    //   variant: Variant.chess,
    //   limit: SearchLimit.depth(_eloToDepth(prefs.elo)),
    //   multiPv: prefs.arrowCount,
    //   game: 'assistant',
    // ));
    //
    // _infoSub = _currentSearch!.infos.listen(_onInfo);
  }

  void _onInfo(UciInfo info) {
    // Convert the top PVs into Shape arrows.
    // Example (you will adapt to the real PV format):
    //
    // final shapes = <Shape>{};
    // for (final move in info.pv.take(3)) {
    //   final normal = NormalMove.fromUci(move);
    //   shapes.add(Arrow(
    //     color: ShapeColor.green,
    //     orig: normal.from,
    //     dest: normal.to,
    //   ));
    // }
    // state = state.copyWith(shapes: shapes);
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
