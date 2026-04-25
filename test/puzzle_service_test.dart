import 'package:daily_gambit/core/models.dart';
import 'package:daily_gambit/services/puzzle_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PuzzleService service;
  const PuzzleDefinition puzzle = PuzzleDefinition(
    id: 'puzzle_001',
    fen: 'rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2',
    solution: <String>['g1f3'],
    prompt: 'Develop with tempo.',
    theme: 'Initiative',
    difficulty: 1,
  );

  setUp(() {
    service = PuzzleService(puzzles: const <PuzzleDefinition>[puzzle]);
  });

  test('daily puzzle selection is deterministic for a given date', () {
    final PuzzleDefinition first = service.nextDailyPuzzle(
      DateTime(2026, 4, 18),
    );
    final PuzzleDefinition second = service.nextDailyPuzzle(
      DateTime(2026, 4, 18),
    );
    expect(first.id, second.id);
  });

  test('correct solution marks the puzzle as completed', () {
    PuzzleProgressState state = PuzzleProgressState.initial(puzzle.id);
    state = service.submitSolution(state, from: 'g1', to: 'f3');
    expect(state.completed, isTrue);
    expect(state.completedPuzzleIds.contains(puzzle.id), isTrue);
  });

  test('next unsolved puzzle skips completed ids', () {
    const PuzzleDefinition secondPuzzle = PuzzleDefinition(
      id: 'puzzle_002',
      fen: 'rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2',
      solution: <String>['g1f3'],
      prompt: 'Develop again.',
      theme: 'Initiative',
      difficulty: 1,
    );
    final PuzzleService twoPuzzleService = PuzzleService(
      puzzles: const <PuzzleDefinition>[puzzle, secondPuzzle],
    );

    final PuzzleDefinition? next = twoPuzzleService.nextUnsolvedPuzzle(
      const <String>{'puzzle_001'},
      afterId: 'puzzle_001',
    );

    expect(next?.id, 'puzzle_002');
  });

  test('wrong legal move increments failure count', () {
    PuzzleProgressState state = PuzzleProgressState.initial(puzzle.id);
    state = service.submitSolution(state, from: 'b1', to: 'c3');
    expect(state.completed, isFalse);
    expect(state.failedAttempts, 1);
  });
}
