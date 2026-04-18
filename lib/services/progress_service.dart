import '../core/chess_utils.dart';
import '../core/models.dart';

class ProgressService {
  const ProgressService();

  AppProfile recordMatch(
    AppProfile profile, {
    required bool won,
    required DateTime now,
  }) {
    AppProfile updated = _applyDailyActivity(profile, now);
    final Map<String, int> missionProgress =
        Map<String, int>.from(updated.missionProgress);
    missionProgress['play_2_games'] =
        (missionProgress['play_2_games'] ?? 0) + 1;
    if (won) {
      missionProgress['win_3_games'] =
          (missionProgress['win_3_games'] ?? 0) + 1;
    }

    updated = updated.copyWith(
      gamesPlayed: updated.gamesPlayed + 1,
      wins: updated.wins + (won ? 1 : 0),
      losses: updated.losses + (won ? 0 : 1),
      missionProgress: missionProgress,
    );

    return _unlockAchievements(updated);
  }

  AppProfile recordPuzzle(
    AppProfile profile, {
    required bool solved,
    required DateTime now,
  }) {
    AppProfile updated = _applyDailyActivity(profile, now);
    final Map<String, int> missionProgress =
        Map<String, int>.from(updated.missionProgress);
    if (solved) {
      missionProgress['solve_5_puzzles'] =
          (missionProgress['solve_5_puzzles'] ?? 0) + 1;
    }
    updated = updated.copyWith(
      puzzleAttempts: updated.puzzleAttempts + 1,
      puzzlesSolved: updated.puzzlesSolved + (solved ? 1 : 0),
      missionProgress: missionProgress,
    );
    return _unlockAchievements(updated);
  }

  AppProfile recordHint(AppProfile profile) {
    final Map<String, int> missionProgress =
        Map<String, int>.from(profile.missionProgress);
    missionProgress['use_1_hint'] = (missionProgress['use_1_hint'] ?? 0) + 1;
    return _unlockAchievements(
      profile.copyWith(
        hintsUsed: profile.hintsUsed + 1,
        missionProgress: missionProgress,
      ),
    );
  }

  AppProfile recordAnalysisUnlock(AppProfile profile) {
    final Map<String, int> missionProgress =
        Map<String, int>.from(profile.missionProgress);
    missionProgress['unlock_analysis'] =
        (missionProgress['unlock_analysis'] ?? 0) + 1;
    return profile.copyWith(
      analysisUnlocks: profile.analysisUnlocks + 1,
      missionProgress: missionProgress,
    );
  }

  AppProfile unlockTheme(AppProfile profile, String themeId) {
    if (profile.unlockedThemeIds.contains(themeId)) {
      return _unlockAchievements(profile);
    }
    final Set<String> unlocked = Set<String>.from(profile.unlockedThemeIds)
      ..add(themeId);
    final Map<String, int> missionProgress =
        Map<String, int>.from(profile.missionProgress);
    missionProgress['unlock_1_theme'] =
        (missionProgress['unlock_1_theme'] ?? 0) + 1;
    return _unlockAchievements(
      profile.copyWith(
        unlockedThemeIds: unlocked,
        missionProgress: missionProgress,
      ),
    );
  }

  AppProfile _applyDailyActivity(AppProfile profile, DateTime now) {
    final String todayKey = formattedDateKey(now);
    if (profile.lastActiveDateKey == todayKey) {
      return profile;
    }

    final DateTime today = DateTime(now.year, now.month, now.day);
    int streak = 1;
    if (profile.lastActiveDateKey != null) {
      final DateTime last = DateTime.parse(profile.lastActiveDateKey!);
      final int gap = today.difference(last).inDays;
      if (gap == 1) {
        streak = profile.streakDays + 1;
      }
    }

    final Map<String, int> missionProgress =
        Map<String, int>.from(profile.missionProgress);
    missionProgress['finish_3_days'] = streak;

    return profile.copyWith(
      streakDays: streak,
      lastActiveDateKey: todayKey,
      missionProgress: missionProgress,
    );
  }

  AppProfile _unlockAchievements(AppProfile profile) {
    final Set<String> unlocked = Set<String>.from(profile.unlockedAchievementIds);
    if (profile.gamesPlayed >= 1) {
      unlocked.add('opening_night');
    }
    if (profile.wins >= 1) {
      unlocked.add('first_win');
    }
    if (profile.puzzlesSolved >= 5) {
      unlocked.add('puzzle_hunter');
    }
    if (profile.streakDays >= 3) {
      unlocked.add('three_day_streak');
    }
    if (profile.unlockedThemeIds.any(
      (String id) => themePacks.any((AppThemePack pack) => pack.id == id && pack.premium),
    )) {
      unlocked.add('collector');
    }
    return profile.copyWith(unlockedAchievementIds: unlocked);
  }
}
