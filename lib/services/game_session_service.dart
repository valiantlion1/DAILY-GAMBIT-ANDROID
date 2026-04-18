import 'package:bishop/bishop.dart';

import '../core/chess_utils.dart';
import '../core/models.dart';
import 'chess_engine_adapter.dart';

class GameSessionService {
  const GameSessionService({required ChessEngineAdapter engineAdapter})
      : _engineAdapter = engineAdapter;

  final ChessEngineAdapter _engineAdapter;

  PersistedGameState startGame({int difficulty = 2}) {
    return PersistedGameState.initial(difficulty: difficulty);
  }

  LiveGameState inspect(PersistedGameState state) {
    final Game game = _buildGame(state.sanHistory);
    final bool playerTurn = game.turn == Bishop.white;
    final bool gameOver = game.gameOver;
    final Map<String, Set<String>> targets = targetsBySourceFromGame(game);

    String statusTitle = playerTurn ? 'Your move' : 'Engine pressure';
    String statusDetail =
        'Level ${state.difficulty} · ${state.sanHistory.length} half-moves played';
    String? resultTitle;
    String? resultDetail;

    if (game.inCheck && !gameOver) {
      statusTitle = playerTurn ? 'You are in check' : 'Engine is in check';
      statusDetail = 'Find the cleanest reply before the tension converts.';
    }

    if (gameOver) {
      final _ResultCopy copy = _describeResult(game);
      resultTitle = copy.title;
      resultDetail = copy.detail;
      statusTitle = resultTitle;
      statusDetail = resultDetail ?? statusDetail;
      if (state.analysisUnlocked && state.analysisSummary != null) {
        resultDetail = '${copy.detail ?? ''}\n${state.analysisSummary}'.trim();
      }
    } else if (state.hintMove != null) {
      statusDetail = 'Hint primed: ${readableMove(state.hintMove!)}';
    }

    return LiveGameState(
      fen: game.fen,
      targetsBySource: targets,
      playerTurn: playerTurn,
      gameOver: gameOver,
      statusTitle: statusTitle,
      statusDetail: statusDetail,
      resultTitle: resultTitle,
      resultDetail: resultDetail,
      bestMoveSan: state.hintMove == null ? null : readableMove(state.hintMove!),
    );
  }

  Set<String> availableTargets(PersistedGameState state, String source) {
    return inspect(state).targetsBySource[source] ?? <String>{};
  }

  PersistedGameState? applyPlayerMove(
    PersistedGameState state, {
    required String from,
    required String to,
  }) {
    final Game game = _buildGame(state.sanHistory);
    if (game.turn != Bishop.white || game.gameOver) {
      return null;
    }

    final Move? move = _resolveMove(game, from, to);
    if (move == null) {
      return null;
    }

    final String san = game.toSan(move);
    final bool applied = game.makeMove(move);
    if (!applied) {
      return null;
    }

    return state.copyWith(
      sanHistory: <String>[...state.sanHistory, san],
      hintMove: null,
      analysisUnlocked: false,
      analysisSummary: null,
    );
  }

  Future<PersistedGameState> runAiTurn(PersistedGameState state) async {
    final Game game = _buildGame(state.sanHistory);
    if (game.turn != Bishop.black || game.gameOver) {
      return state;
    }

    final EngineInsight insight = await _engineAdapter.bestMove(
      game.fen,
      level: state.difficulty,
    );

    if (insight.coordinateMove == null) {
      return state;
    }

    final Move? move = game.getMove(insight.coordinateMove!);
    if (move == null) {
      return state;
    }

    final String san = game.toSan(move);
    final bool applied = game.makeMove(move);
    if (!applied) {
      return state;
    }

    return state.copyWith(
      sanHistory: <String>[...state.sanHistory, san],
      hintMove: null,
    );
  }

  PersistedGameState undo(PersistedGameState state) {
    if (state.sanHistory.isEmpty) {
      return state;
    }

    final int removeCount = state.sanHistory.length >= 2 ? 2 : 1;
    return state.copyWith(
      sanHistory: state.sanHistory.sublist(0, state.sanHistory.length - removeCount),
      hintMove: null,
      analysisUnlocked: false,
      analysisSummary: null,
    );
  }

  PersistedGameState restart(PersistedGameState state) {
    return PersistedGameState.initial(difficulty: state.difficulty);
  }

  Future<PersistedGameState> primeHint(PersistedGameState state) async {
    final LiveGameState live = inspect(state);
    if (!live.playerTurn || live.gameOver) {
      return state;
    }

    final EngineInsight insight = await _engineAdapter.bestMove(
      live.fen,
      level: state.difficulty,
    );
    return state.copyWith(hintMove: insight.coordinateMove);
  }

  Future<PersistedGameState> unlockAnalysisPreview(PersistedGameState state) async {
    final LiveGameState live = inspect(state);
    final EngineInsight insight = await _engineAdapter.analyze(live.fen, depth: 3);
    final String summary = insight.coordinateMove == null
        ? 'Engine score ${_formatEvaluation(insight.evaluation)}. No legal move remains.'
        : 'Engine score ${_formatEvaluation(insight.evaluation)} with ${insight.san ?? readableMove(insight.coordinateMove!)} on deck.';

    return state.copyWith(
      analysisUnlocked: true,
      analysisSummary: summary,
    );
  }

  bool didPlayerWin(PersistedGameState state) {
    final Game game = _buildGame(state.sanHistory);
    return game.gameOver && game.winner == Bishop.white;
  }

  Game _buildGame(List<String> sanHistory) {
    final Game game = Game();
    for (final String san in sanHistory) {
      game.makeMoveSan(san);
    }
    return game;
  }

  Move? _resolveMove(Game game, String from, String to) {
    Move? move = game.getMove('$from$to');
    if (move != null) {
      return move;
    }
    for (final String promotion in <String>['q', 'r', 'b', 'n']) {
      move = game.getMove('$from$to$promotion');
      if (move != null) {
        return move;
      }
    }
    return null;
  }

  _ResultCopy _describeResult(Game game) {
    final String runtime = game.result.runtimeType.toString();
    final bool playerWon = game.winner == Bishop.white;
    if (runtime.contains('Checkmate')) {
      return _ResultCopy(
        title: playerWon ? 'Checkmate secured' : 'Checkmated',
        detail: playerWon
            ? 'You converted the attack cleanly.'
            : 'The engine closed the net before you could stabilize.',
      );
    }
    if (runtime.contains('Stalemate')) {
      return const _ResultCopy(
        title: 'Stalemate',
        detail: 'No legal moves remain. The point is split.',
      );
    }
    if (runtime.contains('Repetition')) {
      return const _ResultCopy(
        title: 'Threefold repetition',
        detail: 'The same position looped three times.',
      );
    }
    if (runtime.contains('Insufficient')) {
      return const _ResultCopy(
        title: 'Insufficient material',
        detail: 'Neither side kept enough force to finish the job.',
      );
    }
    return _ResultCopy(
      title: playerWon ? 'Win banked' : 'Loss logged',
      detail: playerWon
          ? 'You finished ahead of the engine.'
          : 'The engine edged the final sequence.',
    );
  }

  String _formatEvaluation(int centipawns) {
    final double pawns = centipawns / 100;
    return pawns >= 0 ? '+${pawns.toStringAsFixed(1)}' : pawns.toStringAsFixed(1);
  }
}

class _ResultCopy {
  const _ResultCopy({
    required this.title,
    this.detail,
  });

  final String title;
  final String? detail;
}
