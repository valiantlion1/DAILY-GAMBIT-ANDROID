import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import '../core/models.dart';
import '../widgets/chess_board.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppViewState viewState = ref.watch(appControllerProvider);
    final DailyGambitController controller =
        ref.read(appControllerProvider.notifier);
    final AppThemePack theme = themePacks.firstWhere(
      (AppThemePack pack) => pack.id == viewState.profile.selectedThemeId,
      orElse: () => themePacks.first,
    );

    if (!viewState.profile.hasSeenOnboarding) {
      return _OnboardingScreen(theme: theme, controller: controller);
    }

    final List<Widget> pages = <Widget>[
      _HomeTab(theme: theme),
      _GameTab(theme: theme),
      _PuzzleTab(theme: theme),
      _ShopTab(theme: theme),
      _SettingsTab(theme: theme),
    ];

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              theme.background,
              theme.surface.withValues(alpha: 0.72),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              if (viewState.bannerMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _InlineBanner(
                    message: viewState.bannerMessage!,
                    accent: theme.accent,
                    onClose: controller.clearBanner,
                  ),
                ),
              Expanded(
                child: IndexedStack(
                  index: viewState.selectedTabIndex,
                  children: pages,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: NavigationBar(
            selectedIndex: viewState.selectedTabIndex,
            onDestinationSelected: controller.switchTab,
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.sports_esports_outlined),
                selectedIcon: Icon(Icons.sports_esports),
                label: 'Play',
              ),
              NavigationDestination(
                icon: Icon(Icons.extension_outlined),
                selectedIcon: Icon(Icons.extension),
                label: 'Puzzles',
              ),
              NavigationDestination(
                icon: Icon(Icons.diamond_outlined),
                selectedIcon: Icon(Icons.diamond),
                label: 'Shop',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingScreen extends StatelessWidget {
  const _OnboardingScreen({
    required this.theme,
    required this.controller,
  });

  final AppThemePack theme;
  final DailyGambitController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.4),
            radius: 1.2,
            colors: <Color>[
              theme.accent.withValues(alpha: 0.20),
              theme.surface,
              theme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Spacer(),
                Text(
                  'Daily Gambit',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Offline-first chess with premium-casual pacing, daily tactics, and monetization hooks that stay respectful.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                _FeatureBullet(
                  title: 'Play anywhere',
                  detail: 'Full local rules, 5 AI levels, undo, hints, and streaks.',
                  accent: theme.accent,
                ),
                _FeatureBullet(
                  title: 'Monetize without smothering',
                  detail: 'Rewarded hints, capped interstitials, and clear premium upsell.',
                  accent: theme.accent,
                ),
                _FeatureBullet(
                  title: 'Grow from the shell',
                  detail: 'The architecture already separates gameplay, puzzles, shop, and telemetry.',
                  accent: theme.accent,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: controller.completeOnboarding,
                    child: const Text('Enter the Lounge'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab({required this.theme});

  final AppThemePack theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppViewState viewState = ref.watch(appControllerProvider);
    final DailyGambitController controller =
        ref.read(appControllerProvider.notifier);
    final List<StarterMission> missions = buildStarterMissions(viewState.profile);
    final List<AchievementDefinition> achievements =
        achievementDefinitions
            .where(
              (AchievementDefinition achievement) => viewState
                  .profile.unlockedAchievementIds
                  .contains(achievement.id),
            )
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _HeroCard(
            accent: theme.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Retention-first chess that still feels expensive.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Keep players in a calm rhythm: one match, one daily tactic, one clean upsell.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.darkSquare,
                      ),
                      onPressed: () {
                        controller.switchTab(1);
                      },
                      child: const Text('Continue Match'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.42)),
                      ),
                      onPressed: controller.switchToDailyPuzzle,
                      child: const Text('Daily Puzzle'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricCard(
                  label: 'Wins',
                  value: '${viewState.profile.wins}',
                  caption: 'of ${viewState.profile.gamesPlayed} matches',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Streak',
                  value: '${viewState.profile.streakDays}',
                  caption: 'days in rhythm',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Solved',
                  value: '${viewState.profile.puzzlesSolved}',
                  caption: 'offline puzzles',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Starter Missions',
            subtitle: 'Seven low-friction loops designed to bring the player back.',
            child: Column(
              children: missions.map((StarterMission mission) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              mission.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            '${mission.progress}/${mission.target}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mission.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: (mission.progress / mission.target).clamp(0, 1),
                          backgroundColor: theme.accent.withValues(alpha: 0.08),
                          color: theme.accent,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Unlocked Achievements',
            subtitle: achievements.isEmpty
                ? 'None yet. The first win and first five puzzles will light this up.'
                : 'Small dopamine beats for retention without clutter.',
            child: achievements.isEmpty
                ? Text(
                    'Play one full match to start the cabinet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: achievements
                        .map(
                          (AchievementDefinition achievement) => Chip(
                            avatar: Icon(
                              Icons.workspace_premium,
                              size: 18,
                              color: theme.accent,
                            ),
                            label: Text(achievement.title),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _GameTab extends ConsumerStatefulWidget {
  const _GameTab({required this.theme});

  final AppThemePack theme;

  @override
  ConsumerState<_GameTab> createState() => _GameTabState();
}

class _GameTabState extends ConsumerState<_GameTab> {
  String? selectedSquare;

  @override
  Widget build(BuildContext context) {
    final AppViewState viewState = ref.watch(appControllerProvider);
    final DailyGambitController controller =
        ref.read(appControllerProvider.notifier);
    final AppBootstrap bootstrap = ref.read(bootstrapProvider);
    final LiveGameState game = bootstrap.gameSessionService.inspect(viewState.game);

    if (selectedSquare != null &&
        !game.targetsBySource.containsKey(selectedSquare)) {
      selectedSquare = null;
    }

    final Set<String> highlighted =
        selectedSquare == null ? <String>{} : game.targetsBySource[selectedSquare!] ?? <String>{};
    final Set<String> hintSquares = viewState.game.hintMove == null
        ? <String>{}
        : <String>{
            viewState.game.hintMove!.substring(0, 2),
            viewState.game.hintMove!.substring(2, 4),
          };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            title: 'Engine Match',
            subtitle: game.statusDetail,
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: game.statusTitle,
            subtitle: game.resultDetail ?? 'Play white, press cleanly, and bank the result.',
            child: Column(
              children: <Widget>[
                ChessBoard(
                  fen: game.fen,
                  themePack: widget.theme,
                  flipped: viewState.profile.boardFlipped,
                  selectedSquare: selectedSquare,
                  highlightedSquares: highlighted,
                  hintSquares: hintSquares,
                  onSquareTap: (String square) =>
                      _handleTap(square, game, viewState, controller),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List<Widget>.generate(5, (int index) {
                    final int difficulty = index + 1;
                    return ChoiceChip(
                      label: Text('L$difficulty'),
                      selected: viewState.game.difficulty == difficulty,
                      onSelected: (_) => controller.setDifficulty(difficulty),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.undoGame,
                        icon: const Icon(Icons.undo_rounded),
                        label: const Text('Undo'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.unlockGameHint,
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('Hint'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.toggleBoardFlip,
                        icon: const Icon(Icons.flip),
                        label: const Text('Flip'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: controller.restartGame,
                    icon: const Icon(Icons.replay),
                    label: const Text('Restart Match'),
                  ),
                ),
                if (viewState.aiThinking) ...<Widget>[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.theme.accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Engine is choosing a reply...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (game.gameOver) ...<Widget>[
            const SizedBox(height: 18),
            _SectionCard(
              title: game.resultTitle ?? 'Post-game room',
              subtitle: game.resultDetail ??
                  'Unlock an analysis preview or start a new conversion attempt.',
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: controller.unlockAnalysisPreview,
                      icon: const Icon(Icons.analytics_outlined),
                      label: Text(
                        viewState.profile.premiumUnlocked
                            ? 'Show Analysis'
                            : 'Rewarded Analysis',
                      ),
                    ),
                  ),
                  if (viewState.game.analysisUnlocked &&
                      viewState.game.analysisSummary != null) ...<Widget>[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: widget.theme.accent.withValues(alpha: 0.08),
                      ),
                      child: Text(
                        viewState.game.analysisSummary!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleTap(
    String square,
    LiveGameState game,
    AppViewState viewState,
    DailyGambitController controller,
  ) {
    if (!game.playerTurn || game.gameOver || viewState.aiThinking) {
      return;
    }

    if (viewState.profile.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }

    final Set<String> currentTargets =
        selectedSquare == null ? <String>{} : game.targetsBySource[selectedSquare!] ?? <String>{};

    if (selectedSquare != null && currentTargets.contains(square)) {
      final String from = selectedSquare!;
      setState(() => selectedSquare = null);
      controller.playGameMove(from, square);
      if (viewState.profile.soundEnabled) {
        SystemSound.play(SystemSoundType.click);
      }
      return;
    }

    if (selectedSquare == square) {
      setState(() => selectedSquare = null);
      return;
    }

    if (game.targetsBySource.containsKey(square)) {
      setState(() => selectedSquare = square);
      return;
    }

    setState(() => selectedSquare = null);
  }
}

class _PuzzleTab extends ConsumerStatefulWidget {
  const _PuzzleTab({required this.theme});

  final AppThemePack theme;

  @override
  ConsumerState<_PuzzleTab> createState() => _PuzzleTabState();
}

class _PuzzleTabState extends ConsumerState<_PuzzleTab> {
  String? selectedSquare;

  @override
  Widget build(BuildContext context) {
    final AppViewState viewState = ref.watch(appControllerProvider);
    final DailyGambitController controller =
        ref.read(appControllerProvider.notifier);
    final AppBootstrap bootstrap = ref.read(bootstrapProvider);
    final LivePuzzleState puzzle = bootstrap.puzzleService.inspect(viewState.puzzle);

    if (selectedSquare != null &&
        !puzzle.targetsBySource.containsKey(selectedSquare)) {
      selectedSquare = null;
    }

    final Set<String> highlighted =
        selectedSquare == null ? <String>{} : puzzle.targetsBySource[selectedSquare!] ?? <String>{};
    final Set<String> hintSquares = viewState.puzzle.hintMove == null
        ? <String>{}
        : <String>{
            viewState.puzzle.hintMove!.substring(0, 2),
            viewState.puzzle.hintMove!.substring(2, 4),
          };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            title: 'Offline Daily Puzzle',
            subtitle:
                '${puzzle.puzzle.theme} - ${viewState.puzzle.completedPuzzleIds.length}/500 solved locally',
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: puzzle.statusTitle,
            subtitle: puzzle.statusDetail,
            child: Column(
              children: <Widget>[
                ChessBoard(
                  fen: puzzle.fen,
                  themePack: widget.theme,
                  flipped: viewState.profile.boardFlipped,
                  selectedSquare: selectedSquare,
                  highlightedSquares: highlighted,
                  hintSquares: hintSquares,
                  onSquareTap: (String square) =>
                      _handleTap(square, puzzle, viewState, controller),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FilledButton.tonalIcon(
                      onPressed: controller.unlockPuzzleHint,
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('Rewarded Hint'),
                    ),
                    OutlinedButton.icon(
                      onPressed: controller.switchToDailyPuzzle,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Daily Line'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(
    String square,
    LivePuzzleState puzzle,
    AppViewState viewState,
    DailyGambitController controller,
  ) {
    if (puzzle.completed) {
      return;
    }

    if (viewState.profile.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }

    final Set<String> currentTargets =
        selectedSquare == null ? <String>{} : puzzle.targetsBySource[selectedSquare!] ?? <String>{};

    if (selectedSquare != null && currentTargets.contains(square)) {
      final String from = selectedSquare!;
      setState(() => selectedSquare = null);
      controller.playPuzzleMove(from, square);
      if (viewState.profile.soundEnabled) {
        SystemSound.play(SystemSoundType.click);
      }
      return;
    }

    if (selectedSquare == square) {
      setState(() => selectedSquare = null);
      return;
    }

    if (puzzle.targetsBySource.containsKey(square)) {
      setState(() => selectedSquare = square);
      return;
    }

    setState(() => selectedSquare = null);
  }
}

class _ShopTab extends ConsumerWidget {
  const _ShopTab({required this.theme});

  final AppThemePack theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppViewState viewState = ref.watch(appControllerProvider);
    final DailyGambitController controller =
        ref.read(appControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            title: 'Monetization Layer',
            subtitle: 'Rewarded unlocks for utility, IAP for permanence.',
          ),
          const SizedBox(height: 16),
          _HeroCard(
            accent: theme.darkSquare,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Premium should remove friction, not create power creep.',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pro removes ads, unlocks every theme, and keeps post-game analysis one tap away.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...productOffers.map((ProductOffer offer) {
            final bool owned = viewState.profile.ownedProductIds.contains(offer.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SectionCard(
                title: offer.title,
                subtitle: offer.subtitle,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${offer.priceLabel} - ${offer.highlight}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 14),
                    FilledButton(
                      onPressed: owned ? null : () => controller.purchase(offer.id),
                      child: Text(owned ? 'Owned' : 'Unlock'),
                    ),
                  ],
                ),
              ),
            );
          }),
          _SectionCard(
            title: 'Board Themes',
            subtitle: 'Cosmetics are local, instant, and safe to test before store plumbing.',
            child: Column(
              children: themePacks.map((AppThemePack pack) {
                final bool unlocked =
                    viewState.profile.unlockedThemeIds.contains(pack.id);
                final bool selected = viewState.profile.selectedThemeId == pack.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? theme.accent
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[pack.lightSquare, pack.darkSquare],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(pack.name, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(pack.description, style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (!unlocked)
                        OutlinedButton(
                          onPressed: () => controller.purchase('theme_pack'),
                          child: const Text('Unlock'),
                        )
                      else
                        FilledButton.tonal(
                          onPressed: selected ? null : () => controller.selectTheme(pack.id),
                          child: Text(selected ? 'Selected' : 'Equip'),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab({required this.theme});

  final AppThemePack theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppViewState viewState = ref.watch(appControllerProvider);
    final DailyGambitController controller =
        ref.read(appControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            title: 'Settings & Launch Notes',
            subtitle: 'Light controls now, platform services ready to deepen later.',
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Player Comfort',
            subtitle: 'Keep defaults friendly for casual adult sessions.',
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  value: viewState.profile.soundEnabled,
                  activeThumbColor: theme.accent,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Move sound'),
                  subtitle: const Text('Use lightweight system clicks for moves.'),
                  onChanged: controller.toggleSound,
                ),
                SwitchListTile(
                  value: viewState.profile.hapticsEnabled,
                  activeThumbColor: theme.accent,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Haptics'),
                  subtitle: const Text('Tactile tap feedback on board interaction.'),
                  onChanged: controller.toggleHaptics,
                ),
                SwitchListTile(
                  value: viewState.profile.boardFlipped,
                  activeThumbColor: theme.accent,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Flip board'),
                  subtitle: const Text('Useful for studying both sides of the position.'),
                  onChanged: (_) => controller.toggleBoardFlip(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Launch Hardening Checklist',
            subtitle: 'What still needs platform plumbing before store submission.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ChecklistLine(text: 'Swap purchase stubs for real Play Billing products.'),
                _ChecklistLine(text: 'Wire rewarded/interstitial placements to AdMob test IDs first.'),
                _ChecklistLine(text: 'Replace local telemetry adapter with Firebase Analytics/Crashlytics.'),
                _ChecklistLine(text: 'Generate branded icons, screenshots, privacy policy, and consent flow.'),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    FilledButton.tonalIcon(
                      onPressed: controller.restorePurchases,
                      icon: const Icon(Icons.restore),
                      label: const Text('Restore Purchases'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.accent,
    required this.child,
  });

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            accent.withValues(alpha: 0.92),
            accent.withValues(alpha: 0.74),
            const Color(0xFF1B232B),
          ],
        ),
      ),
      child: child,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(caption, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({
    required this.message,
    required this.accent,
    required this.onClose,
  });

  final String message;
  final Color accent;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(Icons.info_outline, color: accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
            ),
            IconButton(
              onPressed: onClose,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({
    required this.title,
    required this.detail,
    required this.accent,
  });

  final String title;
  final String detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(detail, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistLine extends StatelessWidget {
  const _ChecklistLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

