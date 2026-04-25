import 'package:daily_gambit/core/models.dart';
import 'package:daily_gambit/services/monetization_service.dart';
import 'package:daily_gambit/services/progress_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MonetizationService service;

  setUp(() {
    service = MonetizationService(progressService: const ProgressService());
  });

  test('interstitial triggers after every second completed match', () {
    final DateTime now = DateTime(2026, 4, 18);
    AppProfile profile = AppProfile.initial();

    final first = service.registerMatchCompletion(profile, now);
    profile = first.profile;
    expect(first.shouldShow, isFalse);

    final second = service.registerMatchCompletion(profile, now);
    expect(second.shouldShow, isTrue);
    expect(second.profile.dailyInterstitialShown, 1);
  });

  test('daily interstitial cap stops additional ads after five shows', () {
    final DateTime now = DateTime(2026, 4, 18);
    AppProfile profile = AppProfile.initial().copyWith(
      dailyInterstitialDateKey: '2026-04-18',
      dailyInterstitialShown: 5,
      matchesTowardInterstitial: 1,
    );

    final result = service.registerMatchCompletion(profile, now);
    expect(result.shouldShow, isFalse);
    expect(result.message, contains('cap'));
  });

  test('pro pack unlocks premium themes and disables interstitial need', () {
    AppProfile profile = service.purchase(AppProfile.initial(), 'pro_pack');
    expect(profile.premiumUnlocked, isTrue);
    expect(
      themePacks
          .where((AppThemePack pack) => pack.premium)
          .every(
            (AppThemePack pack) => profile.unlockedThemeIds.contains(pack.id),
          ),
      isTrue,
    );
  });
}
