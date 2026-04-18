import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bishop/bishop.dart';
import 'package:daily_gambit/core/chess_utils.dart';

Future<void> main() async {
  final Random random = Random(20260418);
  final Set<String> seen = <String>{};
  final List<_PuzzleSeed> puzzles = <_PuzzleSeed>[];

  while (puzzles.length < 500) {
    final Game game = Game();
    final int setupPlies = 8 + random.nextInt(18);
    bool invalid = false;

    for (int i = 0; i < setupPlies; i++) {
      final List<Move> legalMoves = game
          .generateLegalMoves()
          .where(
            (Move move) =>
                !move.promotion &&
                !game.toSan(move).contains('O-O') &&
                !game.toSan(move).contains('#'),
          )
          .toList();

      if (legalMoves.length < 8) {
        invalid = true;
        break;
      }

      final Move move = legalMoves[random.nextInt(legalMoves.length)];
      game.makeMove(move);
      if (game.gameOver || game.inCheck) {
        invalid = true;
        break;
      }
    }

    if (invalid || !seen.add(game.fen)) {
      continue;
    }

    final int difficulty = 1 + random.nextInt(5);
    final EngineResult result = await Engine(game: game).search(
      maxDepth: difficulty + 1,
      timeLimit: 70 + (difficulty * 40),
      timeBuffer: 0,
    );

    if (!result.hasMove || result.move == null) {
      continue;
    }

    final Move bestMove = result.move!;
    if (bestMove.promotion) {
      continue;
    }

    final String san = game.toSan(bestMove);
    final String solution = moveToCoordinateString(bestMove);
    final String theme;
    final String prompt;

    if (san.contains('#')) {
      theme = 'Mate net';
      prompt = 'Finish the position immediately.';
    } else if (san.contains('x')) {
      theme = 'Tactical strike';
      prompt = 'Find the cleanest forcing capture.';
    } else if (san.contains('+')) {
      theme = 'Initiative';
      prompt = 'Keep the king under pressure with the best check.';
    } else {
      theme = 'Positional squeeze';
      prompt = 'Find the engine-approved continuation.';
    }

    puzzles.add(
      _PuzzleSeed(
        id: 'puzzle_${(puzzles.length + 1).toString().padLeft(3, '0')}',
        fen: game.fen,
        solution: <String>[solution],
        prompt: prompt,
        theme: theme,
        difficulty: difficulty,
      ),
    );
  }

  final Directory outputDir = Directory('assets/puzzles');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }
  final File output = File('assets/puzzles/puzzle_pack.json');
  output.writeAsStringSync(
    const JsonEncoder.withIndent('  ')
        .convert(puzzles.map((_PuzzleSeed puzzle) => puzzle.toJson()).toList()),
  );

  stdout.writeln('Generated ${puzzles.length} puzzles at ${output.path}');
}

class _PuzzleSeed {
  const _PuzzleSeed({
    required this.id,
    required this.fen,
    required this.solution,
    required this.prompt,
    required this.theme,
    required this.difficulty,
  });

  final String id;
  final String fen;
  final List<String> solution;
  final String prompt;
  final String theme;
  final int difficulty;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fen': fen,
      'solution': solution,
      'prompt': prompt,
      'theme': theme,
      'difficulty': difficulty,
    };
  }
}
