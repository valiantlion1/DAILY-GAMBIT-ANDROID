import 'package:bishop/bishop.dart';
import 'package:daily_gambit/core/models.dart';
import 'package:daily_gambit/services/chess_engine_adapter.dart';
import 'package:daily_gambit/services/game_session_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameSessionService service;

  setUp(() {
    service = GameSessionService(engineAdapter: const ChessEngineAdapter());
  });

  test('kingside castling is exposed as a legal move when developed', () {
    final PersistedGameState state = PersistedGameState(
      difficulty: 2,
      sanHistory: _sanHistoryFor(<String>[
        'e2e4',
        'e7e5',
        'g1f3',
        'b8c6',
        'f1c4',
        'g8f6',
      ]),
      analysisUnlocked: false,
    );

    final Set<String> targets = service.availableTargets(state, 'e1');
    expect(targets.contains('g1'), isTrue);
  });

  test('en passant capture remains legal in the expected window', () {
    final PersistedGameState state = PersistedGameState(
      difficulty: 2,
      sanHistory: _sanHistoryFor(<String>['e2e4', 'a7a6', 'e4e5', 'd7d5']),
      analysisUnlocked: false,
    );

    final Set<String> targets = service.availableTargets(state, 'e5');
    expect(targets.contains('d6'), isTrue);
  });

  test('last move is recorded for board feedback and cleared on undo', () {
    final PersistedGameState state = PersistedGameState.initial();
    final PersistedGameState moved = service.applyPlayerMove(
      state,
      from: 'e2',
      to: 'e4',
    )!;

    expect(moved.lastMove, 'e2e4');
    expect(service.undo(moved).lastMove, isNull);
  });

  test('captures are exposed for the board graveyard trays', () {
    final PersistedGameState state = PersistedGameState(
      difficulty: 2,
      sanHistory: _sanHistoryFor(<String>['e2e4', 'd7d5', 'e4d5', 'd8d5']),
      analysisUnlocked: false,
    );

    final LiveGameState live = service.inspect(state);

    expect(live.capturedByWhite, <String>['p']);
    expect(live.capturedByBlack, <String>['P']);
    expect(live.lastCapturedPiece, 'P');
  });

  test('fools mate surfaces a player loss', () {
    final PersistedGameState state = PersistedGameState(
      difficulty: 2,
      sanHistory: _sanHistoryFor(<String>['f2f3', 'e7e5', 'g2g4', 'd8h4']),
      analysisUnlocked: false,
    );

    final LiveGameState live = service.inspect(state);
    expect(live.gameOver, isTrue);
    expect(live.resultTitle, 'Checkmated');
  });

  test('hard engine takes a mate in one', () async {
    final Game game = Game();
    for (final String san in _sanHistoryFor(<String>['f2f3', 'e7e5', 'g2g4'])) {
      game.makeMoveSan(san);
    }

    final EngineInsight insight = await const ChessEngineAdapter().bestMove(
      game.fen,
      level: 5,
    );

    expect(insight.coordinateMove, 'd8h4');
  });
}

List<String> _sanHistoryFor(List<String> uciMoves) {
  final Game game = Game();
  final List<String> sanHistory = <String>[];
  for (final String uci in uciMoves) {
    final Move move = game.getMove(uci)!;
    sanHistory.add(game.toSan(move));
    game.makeMove(move);
  }
  return sanHistory;
}
