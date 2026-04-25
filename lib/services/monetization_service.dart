import '../core/chess_utils.dart';
import '../core/models.dart';
import 'progress_service.dart';

class MonetizationService {
  const MonetizationService({required ProgressService progressService})
    : _progressService = progressService;

  final ProgressService _progressService;

  RewardResult showRewarded(AppProfile profile, RewardContext context) {
    if (profile.premiumUnlocked) {
      return RewardResult(
        profile: profile,
        granted: true,
        message: 'Premium active. Reward unlocked instantly.',
      );
    }

    AppProfile updated = profile;
    if (context == RewardContext.hint) {
      updated = _progressService.recordHint(updated);
    } else if (context == RewardContext.analysisPreview) {
      updated = _progressService.recordAnalysisUnlock(updated);
    }

    return RewardResult(
      profile: updated,
      granted: true,
      message: 'Rewarded break completed. Benefit granted.',
    );
  }

  InterstitialResult registerMatchCompletion(AppProfile profile, DateTime now) {
    return _registerInterstitial(
      profile,
      now: now,
      matchIncrement: 1,
      puzzleFailureIncrement: 0,
      thresholdReached: profile.matchesTowardInterstitial + 1 >= 2,
      thresholdMessage: 'Interstitial ready after 2 completed matches.',
    );
  }

  InterstitialResult registerPuzzleFailure(AppProfile profile, DateTime now) {
    return _registerInterstitial(
      profile,
      now: now,
      matchIncrement: 0,
      puzzleFailureIncrement: 1,
      thresholdReached: profile.failedPuzzlesTowardInterstitial + 1 >= 3,
      thresholdMessage: 'Interstitial ready after 3 failed puzzle attempts.',
    );
  }

  AppProfile resetPuzzleFailureCounter(AppProfile profile) {
    return profile.copyWith(failedPuzzlesTowardInterstitial: 0);
  }

  AppProfile purchase(AppProfile profile, String productId) {
    final Set<String> owned = Set<String>.from(profile.ownedProductIds)
      ..add(productId);
    AppProfile updated = profile.copyWith(ownedProductIds: owned);

    if (productId == 'pro_pack') {
      final Set<String> allThemes = themePacks
          .map((AppThemePack pack) => pack.id)
          .toSet();
      updated = updated.copyWith(unlockedThemeIds: allThemes);
      for (final AppThemePack pack in themePacks.where(
        (AppThemePack pack) => pack.premium,
      )) {
        updated = _progressService.unlockTheme(updated, pack.id);
      }
    }

    if (productId == 'theme_pack') {
      for (final AppThemePack pack in themePacks.where(
        (AppThemePack pack) => pack.premium,
      )) {
        updated = _progressService.unlockTheme(updated, pack.id);
      }
    }

    return updated;
  }

  AppProfile restorePurchases(AppProfile profile) {
    AppProfile updated = profile;
    for (final String productId in profile.ownedProductIds) {
      updated = purchase(updated, productId);
    }
    return updated;
  }

  InterstitialResult _registerInterstitial(
    AppProfile profile, {
    required DateTime now,
    required int matchIncrement,
    required int puzzleFailureIncrement,
    required bool thresholdReached,
    required String thresholdMessage,
  }) {
    final String todayKey = formattedDateKey(now);
    AppProfile normalized = profile;
    if (profile.dailyInterstitialDateKey != todayKey) {
      normalized = normalized.copyWith(
        dailyInterstitialDateKey: todayKey,
        dailyInterstitialShown: 0,
        matchesTowardInterstitial: 0,
        failedPuzzlesTowardInterstitial: 0,
      );
    }

    normalized = normalized.copyWith(
      matchesTowardInterstitial:
          normalized.matchesTowardInterstitial + matchIncrement,
      failedPuzzlesTowardInterstitial:
          normalized.failedPuzzlesTowardInterstitial + puzzleFailureIncrement,
    );

    if (!thresholdReached) {
      return InterstitialResult(
        profile: normalized,
        shouldShow: false,
        message: 'No interstitial. Retention-first pacing preserved.',
      );
    }

    if (normalized.dailyInterstitialShown >= 5 || normalized.premiumUnlocked) {
      return InterstitialResult(
        profile: normalized.copyWith(
          matchesTowardInterstitial: 0,
          failedPuzzlesTowardInterstitial: 0,
        ),
        shouldShow: false,
        message: normalized.premiumUnlocked
            ? 'Premium user: interstitial skipped.'
            : 'Daily interstitial cap reached.',
      );
    }

    return InterstitialResult(
      profile: normalized.copyWith(
        dailyInterstitialShown: normalized.dailyInterstitialShown + 1,
        matchesTowardInterstitial: 0,
        failedPuzzlesTowardInterstitial: 0,
      ),
      shouldShow: true,
      message: thresholdMessage,
    );
  }
}
