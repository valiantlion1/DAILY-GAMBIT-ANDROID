import 'dart:isolate';
import 'dart:math' as math;

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
    final int safeLevel = _clampInt(level, 1, 5);
    return Isolate.run<EngineInsight>(
      () => _StrongChessSearch(
        fen: fen,
        profile: _EngineProfile.forLevel(safeLevel),
      ).run(),
    );
  }

  Future<EngineInsight> analyze(String fen, {int depth = 3}) async {
    final int safeDepth = _clampInt(depth, 1, 7);
    return Isolate.run<EngineInsight>(
      () => _StrongChessSearch(
        fen: fen,
        profile: _EngineProfile.forAnalysisDepth(safeDepth),
      ).run(),
    );
  }
}

class _EngineProfile {
  const _EngineProfile({
    required this.depth,
    required this.quiescenceDepth,
    required this.timeLimitMillis,
  });

  factory _EngineProfile.forLevel(int level) {
    switch (level) {
      case 1:
        return const _EngineProfile(
          depth: 2,
          quiescenceDepth: 0,
          timeLimitMillis: 160,
        );
      case 2:
        return const _EngineProfile(
          depth: 3,
          quiescenceDepth: 1,
          timeLimitMillis: 280,
        );
      case 3:
        return const _EngineProfile(
          depth: 4,
          quiescenceDepth: 2,
          timeLimitMillis: 520,
        );
      case 4:
        return const _EngineProfile(
          depth: 5,
          quiescenceDepth: 3,
          timeLimitMillis: 950,
        );
      default:
        return const _EngineProfile(
          depth: 6,
          quiescenceDepth: 3,
          timeLimitMillis: 1550,
        );
    }
  }

  factory _EngineProfile.forAnalysisDepth(int depth) {
    return _EngineProfile(
      depth: depth,
      quiescenceDepth: math.min(3, math.max(1, depth - 2)),
      timeLimitMillis: 240 + (depth * 180),
    );
  }

  final int depth;
  final int quiescenceDepth;
  final int timeLimitMillis;
}

class _StrongChessSearch {
  _StrongChessSearch({required String fen, required this.profile})
    : game = Game(fen: fen),
      deadline =
          DateTime.now().millisecondsSinceEpoch + profile.timeLimitMillis;

  static const int _mateScore = Bishop.mateUpper - 128;

  final Game game;
  final _EngineProfile profile;
  final int deadline;

  bool _timedOut = false;

  EngineInsight run() {
    final List<Move> legalMoves = game.generateLegalMoves();
    if (game.gameOver || legalMoves.isEmpty) {
      return EngineInsight(evaluation: _evaluateForSideToMove());
    }

    Move? bestMove;
    int bestScore = -_mateScore;

    for (int depth = 1; depth <= profile.depth; depth++) {
      if (_expired) {
        break;
      }

      final _SearchResult result = _searchRoot(depth, legalMoves);
      if (_timedOut || result.move == null) {
        break;
      }

      bestMove = result.move;
      bestScore = result.score;
    }

    bestMove ??= _orderedMoves(legalMoves).first;
    final int evaluation = bestScore == -_mateScore
        ? _evaluateMoveOnePly(bestMove)
        : bestScore;

    return EngineInsight(
      evaluation: evaluation,
      coordinateMove: moveToCoordinateString(bestMove),
      san: game.toSan(bestMove),
    );
  }

  _SearchResult _searchRoot(int depth, List<Move> legalMoves) {
    Move? bestMove;
    int bestScore = -_mateScore;
    int alpha = -_mateScore;
    const int beta = _mateScore;

    for (final Move move in _orderedMoves(legalMoves)) {
      if (_expired) {
        _timedOut = true;
        break;
      }

      game.makeMove(move, false);
      final int score = -_negamax(
        depth: depth - 1,
        alpha: -beta,
        beta: -alpha,
        ply: 1,
      );
      game.undo();

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
      alpha = math.max(alpha, score);
    }

    return _SearchResult(move: bestMove, score: bestScore);
  }

  int _negamax({
    required int depth,
    required int alpha,
    required int beta,
    required int ply,
  }) {
    if (_expired) {
      _timedOut = true;
      return _evaluateForSideToMove();
    }
    if (game.drawn) {
      return 0;
    }

    final List<Move> legalMoves = game.generateLegalMoves();
    if (legalMoves.isEmpty) {
      return game.inCheck ? -_mateScore + ply : 0;
    }
    if (depth <= 0) {
      return _quiescence(
        alpha: alpha,
        beta: beta,
        depth: profile.quiescenceDepth,
        ply: ply,
        legalMoves: legalMoves,
      );
    }

    int best = -_mateScore;
    int localAlpha = alpha;
    for (final Move move in _orderedMoves(legalMoves)) {
      game.makeMove(move, false);
      final int score = -_negamax(
        depth: depth - 1,
        alpha: -beta,
        beta: -localAlpha,
        ply: ply + 1,
      );
      game.undo();

      if (score > best) {
        best = score;
      }
      localAlpha = math.max(localAlpha, score);
      if (localAlpha >= beta || _timedOut) {
        break;
      }
    }

    return best;
  }

  int _quiescence({
    required int alpha,
    required int beta,
    required int depth,
    required int ply,
    required List<Move> legalMoves,
  }) {
    int standPat = _evaluateForSideToMove();
    if (standPat >= beta) {
      return beta;
    }

    int localAlpha = math.max(alpha, standPat);
    if (depth <= 0) {
      return localAlpha;
    }

    final bool mustEscapeCheck = game.inCheck;
    final List<Move> forcingMoves = legalMoves
        .where((Move move) => mustEscapeCheck || move.capture || move.promotion)
        .toList();
    if (forcingMoves.isEmpty) {
      return localAlpha;
    }

    for (final Move move in _orderedMoves(forcingMoves)) {
      if (_expired) {
        _timedOut = true;
        break;
      }

      game.makeMove(move, false);
      final List<Move> replies = game.generateLegalMoves();
      final int score = replies.isEmpty
          ? (game.inCheck ? _mateScore - ply : 0)
          : -_quiescence(
              alpha: -beta,
              beta: -localAlpha,
              depth: depth - 1,
              ply: ply + 1,
              legalMoves: replies,
            );
      game.undo();

      if (score >= beta) {
        return beta;
      }
      localAlpha = math.max(localAlpha, score);
    }

    return localAlpha;
  }

  List<Move> _orderedMoves(List<Move> moves) {
    final List<_ScoredMove> scored = moves
        .map((Move move) => _ScoredMove(move, _moveOrderScore(move)))
        .toList();
    scored.sort((_ScoredMove a, _ScoredMove b) => b.score.compareTo(a.score));
    return scored.map((_ScoredMove scoredMove) => scoredMove.move).toList();
  }

  int _moveOrderScore(Move move) {
    int score = 0;
    final int movingPiece = move.from == Bishop.hand
        ? 0
        : game.board[move.from];
    final String movingSymbol = movingPiece.isNotEmpty
        ? game.variant.pieces[movingPiece.type].symbol.toLowerCase()
        : '';

    if (move.capture) {
      final int capturedValue = move.capturedPiece == null
          ? 100
          : _pieceValue(
              game.variant.pieces[move.capturedPiece!.type].symbol,
              game.variant.pieces[move.capturedPiece!.type].value,
            );
      final int attackerValue = movingPiece.isNotEmpty
          ? _pieceValue(
              game.variant.pieces[movingPiece.type].symbol,
              game.variant.pieces[movingPiece.type].value,
            )
          : 100;
      score += 10000 + (capturedValue * 8) - attackerValue;
    }
    if (move.promotion) {
      score +=
          9000 +
          _pieceValue(
            game.variant.pieces[move.promoPiece!].symbol,
            game.variant.pieces[move.promoPiece!].value,
          );
    }
    if (move.castling) {
      score += 180;
    }

    final _SquareCoord to = _coord(move.to);
    score += (_centerScore(to.file, to.rank) * 3).round();
    if ((movingSymbol == 'n' || movingSymbol == 'b') &&
        _isBackRank(move.from, game.turn)) {
      score += 120;
    }
    if (movingSymbol == 'q' && _isBackRank(move.from, game.turn)) {
      score -= 60;
    }

    return score;
  }

  int _evaluateMoveOnePly(Move move) {
    game.makeMove(move, false);
    final int score = -_evaluateForSideToMove();
    game.undo();
    return score;
  }

  int _evaluateForSideToMove() {
    return _evaluateFor(game.turn);
  }

  int _evaluateFor(int player) {
    int score = 0;
    int playerBishops = 0;
    int opponentBishops = 0;
    int materialWithoutKings = 0;

    for (int index = 0; index < game.size.numIndices; index++) {
      if (!game.size.onBoard(index)) {
        continue;
      }

      final int square = game.board[index];
      if (square.isEmpty) {
        continue;
      }

      final PieceDefinition definition = game.variant.pieces[square.type];
      final String symbol = definition.symbol.toLowerCase();
      final int value = _pieceValue(symbol, definition.value);
      final int positional = _pieceSquareScore(symbol, index, square.colour);
      final int sign = square.colour == player ? 1 : -1;
      score += sign * (value + positional);

      if (symbol != 'k') {
        materialWithoutKings += value;
      }
      if (symbol == 'b') {
        if (square.colour == player) {
          playerBishops++;
        } else {
          opponentBishops++;
        }
      }
    }

    if (playerBishops >= 2) {
      score += 32;
    }
    if (opponentBishops >= 2) {
      score -= 32;
    }

    score += _kingShelterScore(player, materialWithoutKings);
    score -= _kingShelterScore(player.opponent, materialWithoutKings);

    if (game.inCheck) {
      score -= 42;
    }

    return score;
  }

  int _kingShelterScore(int colour, int materialWithoutKings) {
    final int kingSquare = game.state.royalSquares[colour];
    if (kingSquare == Bishop.invalid) {
      return 0;
    }

    final _SquareCoord coord = _coord(kingSquare);
    final bool endgame = materialWithoutKings < 2600;
    if (endgame) {
      return (_centerScore(coord.file, coord.rank) * 2.2).round();
    }

    int score = 0;
    final bool castledShort = colour == Bishop.white
        ? kingSquare == indexFromSquareName('g1')
        : kingSquare == indexFromSquareName('g8');
    final bool castledLong = colour == Bishop.white
        ? kingSquare == indexFromSquareName('c1')
        : kingSquare == indexFromSquareName('c8');
    if (castledShort || castledLong) {
      score += 46;
    }

    final int pawnRank = colour == Bishop.white
        ? coord.rank + 1
        : coord.rank - 1;
    for (final int file in <int>[coord.file - 1, coord.file, coord.file + 1]) {
      if (file < 0 || file > 7 || pawnRank < 1 || pawnRank > 8) {
        continue;
      }
      final int pawn =
          game.board[indexFromSquareName(_squareName(file, pawnRank))];
      if (pawn.isNotEmpty &&
          pawn.colour == colour &&
          game.variant.pieces[pawn.type].symbol.toLowerCase() == 'p') {
        score += 12;
      }
    }

    return score;
  }

  int _pieceSquareScore(String symbol, int index, int colour) {
    final _SquareCoord coord = _coord(index);
    final int relativeRank = colour == Bishop.white
        ? coord.rank
        : 9 - coord.rank;
    final int center = _centerScore(coord.file, coord.rank);
    final bool edge =
        coord.file == 0 ||
        coord.file == 7 ||
        coord.rank == 1 ||
        coord.rank == 8;

    switch (symbol) {
      case 'p':
        return ((relativeRank - 2) * 10) +
            (_centerFileScore(coord.file) * 4).round();
      case 'n':
        return (center * 3.0).round() - (edge ? 28 : 0);
      case 'b':
        return (center * 1.6).round() + (edge ? -10 : 8);
      case 'r':
        return relativeRank >= 7 ? 18 : 0;
      case 'q':
        return (center * 0.75).round() - (relativeRank <= 2 ? 12 : 0);
      case 'k':
        return relativeRank <= 2 ? 12 : -center;
      default:
        return 0;
    }
  }

  int _pieceValue(String symbol, int fallback) {
    switch (symbol.toLowerCase()) {
      case 'p':
        return 100;
      case 'n':
        return 320;
      case 'b':
        return 335;
      case 'r':
        return 500;
      case 'q':
        return 920;
      case 'k':
        return 0;
      default:
        return fallback >= Bishop.mateUpper ? 0 : fallback;
    }
  }

  int _centerScore(int file, int rank) {
    final double fileDistance = (file - 3.5).abs();
    final double rankDistance = (rank - 4.5).abs();
    return (28 - ((fileDistance + rankDistance) * 7)).round();
  }

  int _centerFileScore(int file) {
    return (4 - (file - 3.5).abs()).round();
  }

  bool _isBackRank(int index, int colour) {
    final _SquareCoord coord = _coord(index);
    return colour == Bishop.white ? coord.rank == 1 : coord.rank == 8;
  }

  _SquareCoord _coord(int index) {
    return _SquareCoord(file: index & 7, rank: 8 - (index >> 4));
  }

  bool get _expired => DateTime.now().millisecondsSinceEpoch >= deadline;
}

class _SearchResult {
  const _SearchResult({required this.move, required this.score});

  final Move? move;
  final int score;
}

class _ScoredMove {
  const _ScoredMove(this.move, this.score);

  final Move move;
  final int score;
}

class _SquareCoord {
  const _SquareCoord({required this.file, required this.rank});

  final int file;
  final int rank;
}

int _clampInt(int value, int min, int max) {
  return math.max(min, math.min(max, value));
}

String _squareName(int file, int rank) {
  return '${String.fromCharCode(97 + file)}$rank';
}
