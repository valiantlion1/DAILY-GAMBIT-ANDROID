import 'package:daily_gambit/core/models.dart';
import 'package:daily_gambit/services/progress_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProgressService service;

  setUp(() {
    service = const ProgressService();
  });

  test('daily visit initializes streak and mission progress', () {
    final AppProfile next = service.recordDailyVisit(
      AppProfile.initial(),
      now: DateTime(2026, 4, 18),
    );

    expect(next.streakDays, 1);
    expect(next.lastActiveDateKey, '2026-04-18');
    expect(next.missionProgress['finish_3_days'], 1);
  });

  test('three consecutive daily visits unlock streak achievement', () {
    AppProfile profile = AppProfile.initial();

    profile = service.recordDailyVisit(profile, now: DateTime(2026, 4, 18));
    profile = service.recordDailyVisit(profile, now: DateTime(2026, 4, 19));
    profile = service.recordDailyVisit(profile, now: DateTime(2026, 4, 20));

    expect(profile.streakDays, 3);
    expect(profile.unlockedAchievementIds.contains('three_day_streak'), isTrue);
  });

  test('gap longer than one day resets streak to one', () {
    final AppProfile profile = AppProfile.initial().copyWith(
      streakDays: 4,
      lastActiveDateKey: '2026-04-18',
      missionProgress: <String, int>{
        ...defaultMissionProgress(),
        'finish_3_days': 4,
      },
    );

    final AppProfile next = service.recordDailyVisit(
      profile,
      now: DateTime(2026, 4, 21),
    );

    expect(next.streakDays, 1);
    expect(next.missionProgress['finish_3_days'], 1);
  });

  test('graphics quality persists through profile json', () {
    final AppProfile profile = AppProfile.initial().copyWith(
      graphicsQuality: GraphicsQuality.ultra,
    );

    final AppProfile restored = AppProfile.fromJson(profile.toJson());

    expect(restored.graphicsQuality, GraphicsQuality.ultra);
  });
}
