import 'package:flutter/material.dart';

class AppThemePack {
  const AppThemePack({
    required this.id,
    required this.name,
    required this.description,
    required this.lightSquare,
    required this.darkSquare,
    required this.accent,
    required this.surface,
    required this.background,
    this.premium = false,
  });

  final String id;
  final String name;
  final String description;
  final Color lightSquare;
  final Color darkSquare;
  final Color accent;
  final Color surface;
  final Color background;
  final bool premium;
}

class ProductOffer {
  const ProductOffer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.highlight,
  });

  final String id;
  final String title;
  final String subtitle;
  final String priceLabel;
  final String highlight;
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

class StarterMission {
  const StarterMission({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.progress,
  });

  final String id;
  final String title;
  final String description;
  final int target;
  final int progress;

  bool get completed => progress >= target;
}

class PuzzleDefinition {
  const PuzzleDefinition({
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

  factory PuzzleDefinition.fromJson(Map<String, dynamic> json) {
    return PuzzleDefinition(
      id: json['id'] as String,
      fen: json['fen'] as String,
      solution: List<String>.from(json['solution'] as List<dynamic>),
      prompt: json['prompt'] as String,
      theme: json['theme'] as String,
      difficulty: json['difficulty'] as int,
    );
  }

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

class AppProfile {
  const AppProfile({
    required this.hasSeenOnboarding,
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.boardFlipped,
    required this.selectedThemeId,
    required this.unlockedThemeIds,
    required this.unlockedAchievementIds,
    required this.ownedProductIds,
    required this.gamesPlayed,
    required this.wins,
    required this.losses,
    required this.puzzlesSolved,
    required this.puzzleAttempts,
    required this.hintsUsed,
    required this.analysisUnlocks,
    required this.streakDays,
    required this.lastActiveDateKey,
    required this.dailyInterstitialShown,
    required this.dailyInterstitialDateKey,
    required this.matchesTowardInterstitial,
    required this.failedPuzzlesTowardInterstitial,
    required this.missionProgress,
  });

  factory AppProfile.initial() {
    return AppProfile(
      hasSeenOnboarding: false,
      soundEnabled: true,
      hapticsEnabled: true,
      boardFlipped: false,
      selectedThemeId: 'classic_ivory',
      unlockedThemeIds: const <String>{'classic_ivory', 'walnut_stone'},
      unlockedAchievementIds: const <String>{},
      ownedProductIds: const <String>{},
      gamesPlayed: 0,
      wins: 0,
      losses: 0,
      puzzlesSolved: 0,
      puzzleAttempts: 0,
      hintsUsed: 0,
      analysisUnlocks: 0,
      streakDays: 0,
      lastActiveDateKey: null,
      dailyInterstitialShown: 0,
      dailyInterstitialDateKey: null,
      matchesTowardInterstitial: 0,
      failedPuzzlesTowardInterstitial: 0,
      missionProgress: defaultMissionProgress(),
    );
  }

  factory AppProfile.fromJson(Map<String, dynamic> json) {
    return AppProfile(
      hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      boardFlipped: json['boardFlipped'] as bool? ?? false,
      selectedThemeId: json['selectedThemeId'] as String? ?? 'classic_ivory',
      unlockedThemeIds: Set<String>.from(
        (json['unlockedThemeIds'] as List<dynamic>? ?? const <dynamic>[])
            .cast<String>(),
      ),
      unlockedAchievementIds: Set<String>.from(
        (json['unlockedAchievementIds'] as List<dynamic>? ?? const <dynamic>[])
            .cast<String>(),
      ),
      ownedProductIds: Set<String>.from(
        (json['ownedProductIds'] as List<dynamic>? ?? const <dynamic>[])
            .cast<String>(),
      ),
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      puzzlesSolved: json['puzzlesSolved'] as int? ?? 0,
      puzzleAttempts: json['puzzleAttempts'] as int? ?? 0,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      analysisUnlocks: json['analysisUnlocks'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      lastActiveDateKey: json['lastActiveDateKey'] as String?,
      dailyInterstitialShown: json['dailyInterstitialShown'] as int? ?? 0,
      dailyInterstitialDateKey: json['dailyInterstitialDateKey'] as String?,
      matchesTowardInterstitial: json['matchesTowardInterstitial'] as int? ?? 0,
      failedPuzzlesTowardInterstitial:
          json['failedPuzzlesTowardInterstitial'] as int? ?? 0,
      missionProgress: Map<String, int>.from(
        json['missionProgress'] as Map? ?? defaultMissionProgress(),
      ),
    );
  }

  final bool hasSeenOnboarding;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool boardFlipped;
  final String selectedThemeId;
  final Set<String> unlockedThemeIds;
  final Set<String> unlockedAchievementIds;
  final Set<String> ownedProductIds;
  final int gamesPlayed;
  final int wins;
  final int losses;
  final int puzzlesSolved;
  final int puzzleAttempts;
  final int hintsUsed;
  final int analysisUnlocks;
  final int streakDays;
  final String? lastActiveDateKey;
  final int dailyInterstitialShown;
  final String? dailyInterstitialDateKey;
  final int matchesTowardInterstitial;
  final int failedPuzzlesTowardInterstitial;
  final Map<String, int> missionProgress;

  bool get premiumUnlocked => ownedProductIds.contains('pro_pack');

  AppProfile copyWith({
    bool? hasSeenOnboarding,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? boardFlipped,
    String? selectedThemeId,
    Set<String>? unlockedThemeIds,
    Set<String>? unlockedAchievementIds,
    Set<String>? ownedProductIds,
    int? gamesPlayed,
    int? wins,
    int? losses,
    int? puzzlesSolved,
    int? puzzleAttempts,
    int? hintsUsed,
    int? analysisUnlocks,
    int? streakDays,
    Object? lastActiveDateKey = _sentinel,
    int? dailyInterstitialShown,
    Object? dailyInterstitialDateKey = _sentinel,
    int? matchesTowardInterstitial,
    int? failedPuzzlesTowardInterstitial,
    Map<String, int>? missionProgress,
  }) {
    return AppProfile(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      boardFlipped: boardFlipped ?? this.boardFlipped,
      selectedThemeId: selectedThemeId ?? this.selectedThemeId,
      unlockedThemeIds: unlockedThemeIds ?? this.unlockedThemeIds,
      unlockedAchievementIds:
          unlockedAchievementIds ?? this.unlockedAchievementIds,
      ownedProductIds: ownedProductIds ?? this.ownedProductIds,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      puzzlesSolved: puzzlesSolved ?? this.puzzlesSolved,
      puzzleAttempts: puzzleAttempts ?? this.puzzleAttempts,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      analysisUnlocks: analysisUnlocks ?? this.analysisUnlocks,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDateKey: lastActiveDateKey == _sentinel
          ? this.lastActiveDateKey
          : lastActiveDateKey as String?,
      dailyInterstitialShown:
          dailyInterstitialShown ?? this.dailyInterstitialShown,
      dailyInterstitialDateKey: dailyInterstitialDateKey == _sentinel
          ? this.dailyInterstitialDateKey
          : dailyInterstitialDateKey as String?,
      matchesTowardInterstitial:
          matchesTowardInterstitial ?? this.matchesTowardInterstitial,
      failedPuzzlesTowardInterstitial:
          failedPuzzlesTowardInterstitial ??
          this.failedPuzzlesTowardInterstitial,
      missionProgress: missionProgress ?? this.missionProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hasSeenOnboarding': hasSeenOnboarding,
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
      'boardFlipped': boardFlipped,
      'selectedThemeId': selectedThemeId,
      'unlockedThemeIds': unlockedThemeIds.toList()..sort(),
      'unlockedAchievementIds': unlockedAchievementIds.toList()..sort(),
      'ownedProductIds': ownedProductIds.toList()..sort(),
      'gamesPlayed': gamesPlayed,
      'wins': wins,
      'losses': losses,
      'puzzlesSolved': puzzlesSolved,
      'puzzleAttempts': puzzleAttempts,
      'hintsUsed': hintsUsed,
      'analysisUnlocks': analysisUnlocks,
      'streakDays': streakDays,
      'lastActiveDateKey': lastActiveDateKey,
      'dailyInterstitialShown': dailyInterstitialShown,
      'dailyInterstitialDateKey': dailyInterstitialDateKey,
      'matchesTowardInterstitial': matchesTowardInterstitial,
      'failedPuzzlesTowardInterstitial': failedPuzzlesTowardInterstitial,
      'missionProgress': missionProgress,
    };
  }
}

class PersistedGameState {
  const PersistedGameState({
    required this.difficulty,
    required this.sanHistory,
    required this.analysisUnlocked,
    this.hintMove,
    this.analysisSummary,
    this.lastMove,
  });

  factory PersistedGameState.initial({int difficulty = 2}) {
    return PersistedGameState(
      difficulty: difficulty,
      sanHistory: const <String>[],
      analysisUnlocked: false,
    );
  }

  factory PersistedGameState.fromJson(Map<String, dynamic> json) {
    return PersistedGameState(
      difficulty: json['difficulty'] as int? ?? 2,
      sanHistory: List<String>.from(
        json['sanHistory'] as List<dynamic>? ?? const <dynamic>[],
      ),
      analysisUnlocked: json['analysisUnlocked'] as bool? ?? false,
      hintMove: json['hintMove'] as String?,
      analysisSummary: json['analysisSummary'] as String?,
      lastMove: json['lastMove'] as String?,
    );
  }

  final int difficulty;
  final List<String> sanHistory;
  final bool analysisUnlocked;
  final String? hintMove;
  final String? analysisSummary;
  final String? lastMove;

  PersistedGameState copyWith({
    int? difficulty,
    List<String>? sanHistory,
    bool? analysisUnlocked,
    Object? hintMove = _sentinel,
    Object? analysisSummary = _sentinel,
    Object? lastMove = _sentinel,
  }) {
    return PersistedGameState(
      difficulty: difficulty ?? this.difficulty,
      sanHistory: sanHistory ?? this.sanHistory,
      analysisUnlocked: analysisUnlocked ?? this.analysisUnlocked,
      hintMove: hintMove == _sentinel ? this.hintMove : hintMove as String?,
      analysisSummary: analysisSummary == _sentinel
          ? this.analysisSummary
          : analysisSummary as String?,
      lastMove: lastMove == _sentinel ? this.lastMove : lastMove as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'difficulty': difficulty,
      'sanHistory': sanHistory,
      'analysisUnlocked': analysisUnlocked,
      'hintMove': hintMove,
      'analysisSummary': analysisSummary,
      'lastMove': lastMove,
    };
  }
}

class PuzzleProgressState {
  const PuzzleProgressState({
    required this.activePuzzleId,
    required this.playedMoves,
    required this.completed,
    required this.failedAttempts,
    required this.completedPuzzleIds,
    this.hintMove,
  });

  factory PuzzleProgressState.initial(String puzzleId) {
    return PuzzleProgressState(
      activePuzzleId: puzzleId,
      playedMoves: const <String>[],
      completed: false,
      failedAttempts: 0,
      completedPuzzleIds: const <String>{},
    );
  }

  factory PuzzleProgressState.fromJson(Map<String, dynamic> json) {
    return PuzzleProgressState(
      activePuzzleId: json['activePuzzleId'] as String,
      playedMoves: List<String>.from(
        json['playedMoves'] as List<dynamic>? ?? const <dynamic>[],
      ),
      completed: json['completed'] as bool? ?? false,
      failedAttempts: json['failedAttempts'] as int? ?? 0,
      completedPuzzleIds: Set<String>.from(
        json['completedPuzzleIds'] as List<dynamic>? ?? const <dynamic>[],
      ),
      hintMove: json['hintMove'] as String?,
    );
  }

  final String activePuzzleId;
  final List<String> playedMoves;
  final bool completed;
  final int failedAttempts;
  final Set<String> completedPuzzleIds;
  final String? hintMove;

  PuzzleProgressState copyWith({
    String? activePuzzleId,
    List<String>? playedMoves,
    bool? completed,
    int? failedAttempts,
    Set<String>? completedPuzzleIds,
    Object? hintMove = _sentinel,
  }) {
    return PuzzleProgressState(
      activePuzzleId: activePuzzleId ?? this.activePuzzleId,
      playedMoves: playedMoves ?? this.playedMoves,
      completed: completed ?? this.completed,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      completedPuzzleIds: completedPuzzleIds ?? this.completedPuzzleIds,
      hintMove: hintMove == _sentinel ? this.hintMove : hintMove as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'activePuzzleId': activePuzzleId,
      'playedMoves': playedMoves,
      'completed': completed,
      'failedAttempts': failedAttempts,
      'completedPuzzleIds': completedPuzzleIds.toList()..sort(),
      'hintMove': hintMove,
    };
  }
}

class AppViewState {
  const AppViewState({
    required this.profile,
    required this.selectedTabIndex,
    required this.game,
    required this.puzzle,
    required this.aiThinking,
    this.bannerMessage,
  });

  final AppProfile profile;
  final int selectedTabIndex;
  final PersistedGameState game;
  final PuzzleProgressState puzzle;
  final bool aiThinking;
  final String? bannerMessage;

  AppViewState copyWith({
    AppProfile? profile,
    int? selectedTabIndex,
    PersistedGameState? game,
    PuzzleProgressState? puzzle,
    bool? aiThinking,
    Object? bannerMessage = _sentinel,
  }) {
    return AppViewState(
      profile: profile ?? this.profile,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      game: game ?? this.game,
      puzzle: puzzle ?? this.puzzle,
      aiThinking: aiThinking ?? this.aiThinking,
      bannerMessage: bannerMessage == _sentinel
          ? this.bannerMessage
          : bannerMessage as String?,
    );
  }
}

class LiveGameState {
  const LiveGameState({
    required this.fen,
    required this.targetsBySource,
    required this.capturedByWhite,
    required this.capturedByBlack,
    required this.playerTurn,
    required this.gameOver,
    required this.statusTitle,
    required this.statusDetail,
    required this.resultTitle,
    required this.resultDetail,
    this.lastCapturedPiece,
    this.evaluation,
    this.bestMoveSan,
  });

  final String fen;
  final Map<String, Set<String>> targetsBySource;
  final List<String> capturedByWhite;
  final List<String> capturedByBlack;
  final bool playerTurn;
  final bool gameOver;
  final String statusTitle;
  final String statusDetail;
  final String? resultTitle;
  final String? resultDetail;
  final String? lastCapturedPiece;
  final int? evaluation;
  final String? bestMoveSan;
}

class LivePuzzleState {
  const LivePuzzleState({
    required this.puzzle,
    required this.fen,
    required this.targetsBySource,
    required this.completed,
    required this.statusTitle,
    required this.statusDetail,
  });

  final PuzzleDefinition puzzle;
  final String fen;
  final Map<String, Set<String>> targetsBySource;
  final bool completed;
  final String statusTitle;
  final String statusDetail;
}

class RewardResult {
  const RewardResult({
    required this.profile,
    required this.granted,
    required this.message,
  });

  final AppProfile profile;
  final bool granted;
  final String message;
}

class InterstitialResult {
  const InterstitialResult({
    required this.profile,
    required this.shouldShow,
    required this.message,
  });

  final AppProfile profile;
  final bool shouldShow;
  final String message;
}

enum RewardContext { hint, extraUndo, analysisPreview }

const List<AppThemePack> themePacks = <AppThemePack>[
  AppThemePack(
    id: 'classic_ivory',
    name: 'Ivory Elegance',
    description: 'Soft ivory stone with espresso wood and a gold accent line.',
    lightSquare: Color(0xFFF0DFBF),
    darkSquare: Color(0xFF8A6342),
    accent: Color(0xFFC99A52),
    surface: Color(0xFFF8F1E4),
    background: Color(0xFFFFFBF5),
  ),
  AppThemePack(
    id: 'walnut_stone',
    name: 'Classic Walnut',
    description:
        'Grounded walnut planks and soft cream for calm daily sessions.',
    lightSquare: Color(0xFFE5D0B4),
    darkSquare: Color(0xFF6D4D33),
    accent: Color(0xFFC6904E),
    surface: Color(0xFFF5EEE3),
    background: Color(0xFFF9F4EC),
  ),
  AppThemePack(
    id: 'royal_navy',
    name: 'Obsidian',
    description:
        'Charcoal lacquer with brass trim for premium late-night play.',
    lightSquare: Color(0xFF5D5A55),
    darkSquare: Color(0xFF1D1B1A),
    accent: Color(0xFFD0A15A),
    surface: Color(0xFFF0EBE3),
    background: Color(0xFFFAF7F1),
    premium: true,
  ),
  AppThemePack(
    id: 'ember_sand',
    name: 'Emerald Court',
    description:
        'Muted emerald velvet over warm stone for a richer collectible feel.',
    lightSquare: Color(0xFFD7D8BE),
    darkSquare: Color(0xFF324A3C),
    accent: Color(0xFFB78B52),
    surface: Color(0xFFF3F0E7),
    background: Color(0xFFFBF8F1),
    premium: true,
  ),
];

const List<ProductOffer> productOffers = <ProductOffer>[
  ProductOffer(
    id: 'pro_pack',
    title: 'Pro Pack',
    subtitle: 'Remove ads, unlock every board theme, and open full analysis.',
    priceLabel: '\$7.99',
    highlight: 'Best long-term value',
  ),
  ProductOffer(
    id: 'theme_pack',
    title: 'Signature Themes',
    subtitle: 'Unlock Royal Navy and Ember Sand boards immediately.',
    priceLabel: '\$2.99',
    highlight: 'Fast cosmetic upgrade',
  ),
];

const List<AchievementDefinition> achievementDefinitions =
    <AchievementDefinition>[
      AchievementDefinition(
        id: 'opening_night',
        title: 'Opening Night',
        description: 'Play your first complete match.',
      ),
      AchievementDefinition(
        id: 'first_win',
        title: 'First Blood',
        description: 'Beat the engine once.',
      ),
      AchievementDefinition(
        id: 'puzzle_hunter',
        title: 'Puzzle Hunter',
        description: 'Solve 5 bundled puzzles.',
      ),
      AchievementDefinition(
        id: 'three_day_streak',
        title: 'Three Day Rhythm',
        description: 'Keep a 3-day activity streak alive.',
      ),
      AchievementDefinition(
        id: 'collector',
        title: 'Collector',
        description: 'Unlock a premium board style.',
      ),
    ];

Map<String, int> defaultMissionProgress() {
  return <String, int>{
    'play_2_games': 0,
    'solve_5_puzzles': 0,
    'use_1_hint': 0,
    'win_3_games': 0,
    'unlock_1_theme': 0,
    'finish_3_days': 0,
    'unlock_analysis': 0,
  };
}

List<StarterMission> buildStarterMissions(AppProfile profile) {
  return <StarterMission>[
    StarterMission(
      id: 'play_2_games',
      title: 'Warm up',
      description: 'Finish 2 engine matches.',
      target: 2,
      progress: profile.missionProgress['play_2_games'] ?? 0,
    ),
    StarterMission(
      id: 'solve_5_puzzles',
      title: 'Daily grind',
      description: 'Solve 5 offline puzzles.',
      target: 5,
      progress: profile.missionProgress['solve_5_puzzles'] ?? 0,
    ),
    StarterMission(
      id: 'use_1_hint',
      title: 'Call the coach',
      description: 'Use one rewarded hint.',
      target: 1,
      progress: profile.missionProgress['use_1_hint'] ?? 0,
    ),
    StarterMission(
      id: 'win_3_games',
      title: 'Beat the house',
      description: 'Win 3 games against the engine.',
      target: 3,
      progress: profile.missionProgress['win_3_games'] ?? 0,
    ),
    StarterMission(
      id: 'unlock_1_theme',
      title: 'Dress the board',
      description: 'Unlock a premium visual theme.',
      target: 1,
      progress: profile.missionProgress['unlock_1_theme'] ?? 0,
    ),
    StarterMission(
      id: 'finish_3_days',
      title: 'Keep momentum',
      description: 'Touch the app on 3 different days.',
      target: 3,
      progress: profile.missionProgress['finish_3_days'] ?? 0,
    ),
    StarterMission(
      id: 'unlock_analysis',
      title: 'Post-game room',
      description: 'Unlock one analysis preview.',
      target: 1,
      progress: profile.missionProgress['unlock_analysis'] ?? 0,
    ),
  ];
}

const Object _sentinel = Object();
