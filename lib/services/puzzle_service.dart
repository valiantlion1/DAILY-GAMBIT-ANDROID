import 'dart:convert';

import 'package:bishop/bishop.dart';
import 'package:flutter/services.dart';

import '../core/chess_utils.dart';
import '../core/models.dart';

class PuzzleService {
  PuzzleService({required List<PuzzleDefinition> puzzles}) : _puzzles = puzzles;

  final List<PuzzleDefinition> _puzzles;

  static Future<PuzzleService> loadFromAssets() async {
    final String raw = await rootBundle.loadString('assets/puzzles/puzzle_pack.json');
    final List<dynamic> parsed = jsonDecode(raw) as List<dynamic>;
    return PuzzleService(
      puzzles: parsed
          .cast<Map<String, dynamic>>()
          .map(PuzzleDefinition.fromJson)
          .toList(),
    );
  }

  List<PuzzleDefinition> loadPack(String packId) => _puzzles;

  PuzzleDefinition nextDailyPuzzle(DateTime date) {
    return _puzzles[dayOfYear(date) % _puzzles.length];
  }

  PuzzleProgressState ensurePuzzle(
    PuzzleProgressState? saved,
    PuzzleDefinition puzzle,
  ) {
    if (saved == null || saved.activePuzzleId != puzzle.id) {
      return PuzzleProgressState.initial(puzzle.id).copyWith(
        completedPuzzleIds: saved?.completedPuzzleIds ?? const <String>{},
      );
    }
    return saved;
  }

  LivePuzzleState inspect(PuzzleProgressState state) {
    final PuzzleDefinition puzzle = byId(state.activePuzzleId);
    final Game game = _buildPuzzleGame(state, puzzle);
    final String title = state.completed ? 'Puzzle solved' : 'Daily tactic';
    final String detail = state.completed
        ? 'Clean finish. Come back tomorrow for the next local challenge.'
        : '${puzzle.prompt} · Difficulty ${puzzle.difficulty}/5 · ${state.failedAttempts} misses';
    return LivePuzzleState(
      puzzle: puzzle,
      fen: game.fen,
      targetsBySource: targetsBySourceFromGame(game),
      completed: state.completed,
      statusTitle: title,
      statusDetail: detail,
    );
  }

  Set<String> availableTargets(PuzzleProgressState state, String source) {
    return inspect(state).targetsBySource[source] ?? <String>{};
  }

  PuzzleProgressState switchToPuzzle(
    PuzzleProgressState state,
    String puzzleId,
  ) {
    return PuzzleProgressState.initial(puzzleId).copyWith(
      completedPuzzleIds: state.completedPuzzleIds,
    );
  }

  PuzzleProgressState submitSolution(
    PuzzleProgressState state, {
    required String from,
    required String to,
  }) {
    if (state.completed) {
      return state;
    }

    final PuzzleDefinition puzzle = byId(state.activePuzzleId);
    final String attempted = '$from$to';
    final int nextIndex = state.playedMoves.length;
    final String expected = puzzle.solution[nextIndex];

    final Game game = _buildPuzzleGame(state, puzzle);
    if (game.getMove(attempted) == null) {
      return state.copyWith(failedAttempts: state.failedAttempts + 1);
    }

    if (attempted != expected) {
      return state.copyWith(failedAttempts: state.failedAttempts + 1);
    }

    final List<String> played = <String>[...state.playedMoves, attempted];
    final bool completed = played.length >= puzzle.solution.length;
    final Set<String> completedPuzzleIds =
        Set<String>.from(state.completedPuzzleIds);
    if (completed) {
      completedPuzzleIds.add(puzzle.id);
    }

    return state.copyWith(
      playedMoves: played,
      completed: completed,
      hintMove: null,
      completedPuzzleIds: completedPuzzleIds,
    );
  }

  PuzzleProgressState primeHint(PuzzleProgressState state) {
    if (state.completed) {
      return state;
    }
    final PuzzleDefinition puzzle = byId(state.activePuzzleId);
    return state.copyWith(
      hintMove: puzzle.solution[state.playedMoves.length],
    );
  }

  PuzzleDefinition byId(String id) {
    return _puzzles.firstWhere((PuzzleDefinition puzzle) => puzzle.id == id);
  }

  Game _buildPuzzleGame(PuzzleProgressState state, PuzzleDefinition puzzle) {
    final Game game = Game(fen: puzzle.fen);
    for (final String move in state.playedMoves) {
      final Move? nextMove = game.getMove(move);
      if (nextMove != null) {
        game.makeMove(nextMove);
      }
    }
    return game;
  }
}
