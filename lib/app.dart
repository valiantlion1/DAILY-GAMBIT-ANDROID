import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/models.dart';
import 'screens/home_shell.dart';
import 'services/chess_engine_adapter.dart';
import 'services/game_session_service.dart';
import 'services/monetization_service.dart';
import 'services/progress_service.dart';
import 'services/puzzle_service.dart';
import 'services/storage_service.dart';
import 'services/telemetry_service.dart';
import 'theme/app_theme.dart';

final Provider<AppBootstrap> bootstrapProvider = Provider<AppBootstrap>(
  (Ref ref) => throw UnimplementedError('Bootstrap is overridden at runtime.'),
);

final NotifierProvider<DailyGambitController, AppViewState>
appControllerProvider = NotifierProvider<DailyGambitController, AppViewState>(
  DailyGambitController.new,
);

class AppBootstrap {
  const AppBootstrap({
    required this.storageService,
    required this.telemetryService,
    required this.progressService,
    required this.monetizationService,
    required this.gameSessionService,
    required this.puzzleService,
    required this.initialState,
  });

  final StorageService storageService;
  final TelemetryService telemetryService;
  final ProgressService progressService;
  final MonetizationService monetizationService;
  final GameSessionService gameSessionService;
  final PuzzleService puzzleService;
  final AppViewState initialState;
}

Future<AppBootstrap> bootstrapApplication() async {
  final StorageService storageService = StorageService();
  await storageService.init();

  final TelemetryService telemetryService = const TelemetryService();
  final ProgressService progressService = const ProgressService();
  final MonetizationService monetizationService = MonetizationService(
    progressService: progressService,
  );
  final ChessEngineAdapter engineAdapter = const ChessEngineAdapter();
  final GameSessionService gameSessionService = GameSessionService(
    engineAdapter: engineAdapter,
  );
  final PuzzleService puzzleService = await PuzzleService.loadFromAssets();

  final AppProfile profile = await storageService.loadProfile();
  final PersistedGameState game = await storageService.loadGame();
  final PuzzleDefinition dailyPuzzle = puzzleService.nextDailyPuzzle(
    DateTime.now(),
  );
  final PuzzleProgressState puzzle = puzzleService.ensurePuzzle(
    await storageService.loadPuzzle(),
    dailyPuzzle,
  );

  return AppBootstrap(
    storageService: storageService,
    telemetryService: telemetryService,
    progressService: progressService,
    monetizationService: monetizationService,
    gameSessionService: gameSessionService,
    puzzleService: puzzleService,
    initialState: AppViewState(
      profile: profile,
      selectedTabIndex: 0,
      game: game,
      puzzle: puzzle,
      aiThinking: false,
    ),
  );
}

class DailyGambitApp extends ConsumerStatefulWidget {
  const DailyGambitApp({super.key});

  @override
  ConsumerState<DailyGambitApp> createState() => _DailyGambitAppState();
}

class _DailyGambitAppState extends ConsumerState<DailyGambitApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(appControllerProvider.notifier).syncDailyState());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref
            .read(appControllerProvider.notifier)
            .syncDailyState(fromResume: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppViewState viewState = ref.watch(appControllerProvider);
    final AppThemePack theme = themePacks.firstWhere(
      (AppThemePack pack) => pack.id == viewState.profile.selectedThemeId,
      orElse: () => themePacks.first,
    );

    return ShadApp.custom(
      themeMode: ThemeMode.light,
      theme: buildShadTheme(theme),
      appBuilder: (BuildContext context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Daily Gambit',
          theme: buildAppTheme(theme, baseTheme: Theme.of(context)),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalShadLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const HomeShell(),
          builder: (BuildContext context, Widget? child) {
            return ShadAppBuilder(child: child!);
          },
        );
      },
    );
  }
}

class DailyGambitController extends Notifier<AppViewState> {
  AppBootstrap get _bootstrap => ref.read(bootstrapProvider);

  @override
  AppViewState build() {
    return _bootstrap.initialState;
  }

  Future<void> completeOnboarding() async {
    final AppProfile profile = state.profile.copyWith(hasSeenOnboarding: true);
    state = state.copyWith(profile: profile);
    _bootstrap.telemetryService.track('onboarding_completed');
    await _persistProfile(profile);
    await syncDailyState();
  }

  void switchTab(int index) {
    state = state.copyWith(selectedTabIndex: index, bannerMessage: null);
    unawaited(syncDailyState());
  }

  void clearBanner() {
    state = state.copyWith(bannerMessage: null);
  }

  void showBanner(String message) {
    state = state.copyWith(bannerMessage: message);
  }

  Future<void> playNow() async {
    final LiveGameState live = _bootstrap.gameSessionService.inspect(
      state.game,
    );
    PersistedGameState game = state.game;
    String? banner;

    if (live.gameOver || state.game.sanHistory.isEmpty) {
      game = _bootstrap.gameSessionService.startGame(
        difficulty: state.game.difficulty,
      );
      banner = 'Fresh board. Your move.';
      _bootstrap.telemetryService.track('game_started', <String, Object?>{
        'difficulty': game.difficulty,
        'entry': 'home_play',
      });
      await _persistGame(game);
    }

    state = state.copyWith(
      game: game,
      selectedTabIndex: 1,
      aiThinking: false,
      bannerMessage: banner,
    );
    unawaited(syncDailyState());
  }

  Future<void> startNewGame([int? difficulty]) async {
    final PersistedGameState next = _bootstrap.gameSessionService.startGame(
      difficulty: difficulty ?? state.game.difficulty,
    );
    state = state.copyWith(
      game: next,
      aiThinking: false,
      bannerMessage: 'Fresh board. Your move.',
    );
    _bootstrap.telemetryService.track('game_started', <String, Object?>{
      'difficulty': next.difficulty,
    });
    await _persistGame(next);
  }

  Future<void> setDifficulty(int difficulty) async {
    await startNewGame(difficulty);
  }

  Future<void> playGameMove(String from, String to) async {
    if (state.aiThinking) {
      return;
    }

    final bool wasGameOver = _bootstrap.gameSessionService
        .inspect(state.game)
        .gameOver;
    final PersistedGameState? playerState = _bootstrap.gameSessionService
        .applyPlayerMove(state.game, from: from, to: to);
    if (playerState == null) {
      state = state.copyWith(
        bannerMessage: 'That move is not legal from the current board.',
      );
      return;
    }

    state = state.copyWith(game: playerState, bannerMessage: null);
    await _persistGame(playerState);
    _bootstrap.telemetryService.track('game_move', <String, Object?>{
      'from': from,
      'to': to,
      'ply': playerState.sanHistory.length,
    });

    final bool playerEndedGame =
        !wasGameOver &&
        _bootstrap.gameSessionService.inspect(playerState).gameOver;
    if (playerEndedGame) {
      await _finalizeMatch(playerState);
      return;
    }

    state = state.copyWith(
      aiThinking: true,
      bannerMessage: 'Engine thinking...',
    );
    await Future<void>.delayed(const Duration(milliseconds: 410));
    final PersistedGameState aiState = await _bootstrap.gameSessionService
        .runAiTurn(playerState);
    state = state.copyWith(
      game: aiState,
      aiThinking: false,
      bannerMessage: null,
    );
    await _persistGame(aiState);

    final bool aiEndedGame = _bootstrap.gameSessionService
        .inspect(aiState)
        .gameOver;
    if (aiEndedGame) {
      await _finalizeMatch(aiState);
    }
  }

  Future<void> undoGame() async {
    if (state.aiThinking) {
      return;
    }
    if (state.game.sanHistory.isEmpty) {
      state = state.copyWith(bannerMessage: 'No move to undo yet.');
      return;
    }

    final PersistedGameState next = _bootstrap.gameSessionService.undo(
      state.game,
    );
    state = state.copyWith(game: next, bannerMessage: 'Turn taken back.');
    await _persistGame(next);
  }

  Future<void> restartGame() async {
    final PersistedGameState next = _bootstrap.gameSessionService.restart(
      state.game,
    );
    state = state.copyWith(
      game: next,
      aiThinking: false,
      selectedTabIndex: 1,
      bannerMessage: 'Fresh board. Your move.',
    );
    await _persistGame(next);
  }

  Future<void> unlockGameHint() async {
    final LiveGameState live = _bootstrap.gameSessionService.inspect(
      state.game,
    );
    if (live.gameOver) {
      state = state.copyWith(
        bannerMessage: 'Start a new match before asking for a hint.',
      );
      return;
    }
    if (!live.playerTurn || state.aiThinking) {
      state = state.copyWith(
        bannerMessage: 'Let the engine finish this move first.',
      );
      return;
    }

    final RewardResult reward = _bootstrap.monetizationService.showRewarded(
      state.profile,
      RewardContext.hint,
    );
    final PersistedGameState game = await _bootstrap.gameSessionService
        .primeHint(state.game);
    state = state.copyWith(
      profile: reward.profile,
      game: game,
      bannerMessage: '${reward.message} Hint ready.',
    );
    await _persistProfile(reward.profile);
    await _persistGame(game);
  }

  Future<void> unlockAnalysisPreview() async {
    final RewardResult reward = _bootstrap.monetizationService.showRewarded(
      state.profile,
      RewardContext.analysisPreview,
    );
    final PersistedGameState game = await _bootstrap.gameSessionService
        .unlockAnalysisPreview(state.game);
    state = state.copyWith(
      profile: reward.profile,
      game: game,
      bannerMessage: reward.message,
    );
    await _persistProfile(reward.profile);
    await _persistGame(game);
  }

  Future<void> playPuzzleMove(String from, String to) async {
    final bool wasCompleted = state.puzzle.completed;
    final PuzzleProgressState next = _bootstrap.puzzleService.submitSolution(
      state.puzzle,
      from: from,
      to: to,
    );

    AppProfile profile = state.profile;
    String banner = 'Keep looking for the cleanest continuation.';

    if (next.completed && !wasCompleted) {
      profile = _bootstrap.progressService.recordPuzzle(
        profile,
        solved: true,
        now: DateTime.now(),
      );
      profile = _bootstrap.monetizationService.resetPuzzleFailureCounter(
        profile,
      );
      banner = 'Puzzle solved. Daily progress banked.';
      _bootstrap.telemetryService.track('puzzle_solved', <String, Object?>{
        'puzzleId': next.activePuzzleId,
      });
    } else if (next.failedAttempts > state.puzzle.failedAttempts) {
      profile = _bootstrap.progressService.recordPuzzle(
        profile,
        solved: false,
        now: DateTime.now(),
      );
      final InterstitialResult interstitial = _bootstrap.monetizationService
          .registerPuzzleFailure(profile, DateTime.now());
      profile = interstitial.profile;
      banner = interstitial.message;
    }

    state = state.copyWith(
      profile: profile,
      puzzle: next,
      bannerMessage: banner,
    );
    await _persistProfile(profile);
    await _persistPuzzle(next);
  }

  Future<void> unlockPuzzleHint() async {
    if (state.puzzle.completed) {
      state = state.copyWith(
        bannerMessage:
            'This puzzle is already solved. Continue to the next one.',
      );
      return;
    }

    final RewardResult reward = _bootstrap.monetizationService.showRewarded(
      state.profile,
      RewardContext.hint,
    );
    final PuzzleProgressState next = _bootstrap.puzzleService.primeHint(
      state.puzzle,
    );
    state = state.copyWith(
      profile: reward.profile,
      puzzle: next,
      bannerMessage: '${reward.message} Best move highlighted.',
    );
    await _persistProfile(reward.profile);
    await _persistPuzzle(next);
  }

  Future<void> continuePuzzle() async {
    final PuzzleDefinition? nextPuzzle = _bootstrap.puzzleService
        .nextUnsolvedPuzzle(
          state.puzzle.completedPuzzleIds,
          afterId: state.puzzle.activePuzzleId,
        );

    if (nextPuzzle == null) {
      state = state.copyWith(
        selectedTabIndex: 0,
        bannerMessage: 'Puzzle pack cleared. Come back for a fresh daily run.',
      );
      return;
    }

    final PuzzleProgressState next = _bootstrap.puzzleService.switchToPuzzle(
      state.puzzle,
      nextPuzzle.id,
    );
    state = state.copyWith(
      puzzle: next,
      selectedTabIndex: 2,
      bannerMessage: 'Next tactic loaded.',
    );
    await _persistPuzzle(next);
  }

  Future<void> switchToDailyPuzzle() async {
    await syncDailyState();
    final PuzzleDefinition daily = _bootstrap.puzzleService.nextDailyPuzzle(
      DateTime.now(),
    );
    final PuzzleProgressState next = _bootstrap.puzzleService.switchToPuzzle(
      state.puzzle,
      daily.id,
    );
    state = state.copyWith(
      puzzle: next,
      selectedTabIndex: 2,
      bannerMessage: null,
    );
    await _persistPuzzle(next);
  }

  Future<void> purchase(String productId) async {
    final AppProfile profile = _bootstrap.monetizationService.purchase(
      state.profile,
      productId,
    );
    state = state.copyWith(
      profile: profile,
      bannerMessage: '$productId unlocked for this local build.',
    );
    _bootstrap.telemetryService.track('purchase_stub', <String, Object?>{
      'productId': productId,
    });
    await _persistProfile(profile);
  }

  Future<void> restorePurchases() async {
    final AppProfile profile = _bootstrap.monetizationService.restorePurchases(
      state.profile,
    );
    state = state.copyWith(
      profile: profile,
      bannerMessage: 'Owned products restored from local state.',
    );
    await _persistProfile(profile);
  }

  Future<void> selectTheme(String themeId) async {
    if (!state.profile.unlockedThemeIds.contains(themeId)) {
      state = state.copyWith(
        bannerMessage: 'That board theme is still locked in the shop.',
      );
      return;
    }

    final AppProfile profile = state.profile.copyWith(selectedThemeId: themeId);
    state = state.copyWith(profile: profile, bannerMessage: null);
    await _persistProfile(profile);
  }

  Future<void> toggleSound(bool enabled) async {
    final AppProfile profile = state.profile.copyWith(soundEnabled: enabled);
    state = state.copyWith(profile: profile);
    await _persistProfile(profile);
  }

  Future<void> toggleHaptics(bool enabled) async {
    final AppProfile profile = state.profile.copyWith(hapticsEnabled: enabled);
    state = state.copyWith(profile: profile);
    await _persistProfile(profile);
  }

  Future<void> toggleBoardFlip() async {
    final AppProfile profile = state.profile.copyWith(
      boardFlipped: !state.profile.boardFlipped,
    );
    state = state.copyWith(profile: profile);
    await _persistProfile(profile);
  }

  Future<void> _finalizeMatch(PersistedGameState game) async {
    AppProfile profile = _bootstrap.progressService.recordMatch(
      state.profile,
      won: _bootstrap.gameSessionService.didPlayerWin(game),
      now: DateTime.now(),
    );
    final InterstitialResult interstitial = _bootstrap.monetizationService
        .registerMatchCompletion(profile, DateTime.now());
    profile = interstitial.profile;
    state = state.copyWith(
      profile: profile,
      game: game,
      aiThinking: false,
      bannerMessage: interstitial.message,
    );
    await _persistProfile(profile);
    await _persistGame(game);
  }

  Future<void> _persistProfile(AppProfile profile) async {
    await _bootstrap.storageService.saveProfile(profile);
  }

  Future<void> _persistGame(PersistedGameState game) async {
    await _bootstrap.storageService.saveGame(game);
  }

  Future<void> _persistPuzzle(PuzzleProgressState puzzle) async {
    await _bootstrap.storageService.savePuzzle(puzzle);
  }

  Future<void> syncDailyState({bool fromResume = false}) async {
    final DateTime now = DateTime.now();
    final AppProfile nextProfile = _bootstrap.progressService.recordDailyVisit(
      state.profile,
      now: now,
    );
    final PuzzleDefinition dailyPuzzle = _bootstrap.puzzleService
        .nextDailyPuzzle(now);
    final PuzzleProgressState nextPuzzle = _bootstrap.puzzleService
        .ensurePuzzle(state.puzzle, dailyPuzzle);

    final bool profileChanged =
        jsonEncode(nextProfile.toJson()) != jsonEncode(state.profile.toJson());
    final bool puzzleChanged =
        jsonEncode(nextPuzzle.toJson()) != jsonEncode(state.puzzle.toJson());

    if (!profileChanged && !puzzleChanged) {
      return;
    }

    final bool dailyPuzzleChanged =
        nextPuzzle.activePuzzleId != state.puzzle.activePuzzleId;
    final String? bannerMessage = dailyPuzzleChanged
        ? 'New daily puzzle is ready.'
        : (fromResume
              ? 'Session refreshed from local state.'
              : state.bannerMessage);

    state = state.copyWith(
      profile: nextProfile,
      puzzle: nextPuzzle,
      bannerMessage: bannerMessage,
    );

    if (profileChanged) {
      await _persistProfile(nextProfile);
    }
    if (puzzleChanged) {
      await _persistPuzzle(nextPuzzle);
    }
  }
}
