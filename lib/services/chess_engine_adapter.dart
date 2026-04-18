import 'package:bishop/bishop.dart';

import '../core/chess_utils.dart';

class EngineInsight {
  const EngineInsight({
    required this.evaluation,
    this.coordinateMove,
    this.san,
  });

  final int evaluation;
  final String? coordinateMove;
  final String? san;
}

class ChessEngineAdapter {
  const ChessEngineAdapter();

  Future<EngineInsight> bestMove(String fen, {required int level}) async {
    final Game game = Game(fen: fen);
    final EngineResult result = await Engine(game: game).search(
      maxDepth: level.clamp(1, 5) + 1,
      timeLimit: 80 + (level.clamp(1, 5) * 50),
      timeBuffer: 0,
    );

    if (!result.hasMove || result.move == null) {
      return EngineInsight(evaluation: game.evaluate(game.turn));
    }

    return EngineInsight(
      evaluation: result.eval ?? game.evaluate(game.turn),
      coordinateMove: moveToCoordinateString(result.move!),
      san: game.toSan(result.move!),
    );
  }

  Future<EngineInsight> analyze(String fen, {int depth = 3}) async {
    final Game game = Game(fen: fen);
    final EngineResult result = await Engine(game: game).search(
      maxDepth: depth.clamp(1, 6),
      timeLimit: 120 + (depth.clamp(1, 6) * 60),
      timeBuffer: 0,
    );

    if (!result.hasMove || result.move == null) {
      return EngineInsight(evaluation: game.evaluate(game.turn));
    }

    return EngineInsight(
      evaluation: result.eval ?? game.evaluate(game.turn),
      coordinateMove: moveToCoordinateString(result.move!),
      san: game.toSan(result.move!),
    );
  }
}
