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
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _AmbientBackdrop(theme: theme),
          SafeArea(
            child: Column(
              children: <Widget>[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: viewState.bannerMessage == null
                      ? const SizedBox.shrink()
                      : Padding(
                          key: ValueKey<String>(viewState.bannerMessage!),
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: _RevealOnMount(
                            delay: const Duration(milliseconds: 60),
                            child: _InlineBanner(
                              message: viewState.bannerMessage!,
                              accent: theme.accent,
                              onClose: controller.clearBanner,
                            ),
                          ),
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
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: _FloatingNavShell(
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
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _AmbientBackdrop(theme: theme),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _RevealOnMount(
                    child: _HeroCard(
                      accent: theme.accent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.white.withValues(alpha: 0.18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30),
                              ),
                            ),
                            child: Text(
                              'ANDROID EARLY ACCESS',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Daily Gambit',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sade, yetişkin ve premium bir satranç deneyimi: hızlı maç, günlük puzzle, temiz monetization.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                          ),
                          const SizedBox(height: 24),
                          _FeatureBullet(
                            title: 'Akış bozmayan tempo',
                            detail: 'Aktif oyun ortasında reklam yok, sadece kontrollü tetikleme.',
                            accent: Colors.white,
                          ),
                          _FeatureBullet(
                            title: 'Tam lokal çalışma',
                            detail: 'Offline açılır, ilerleme ve puzzle durumu cihazda tutulur.',
                            accent: Colors.white,
                          ),
                          _FeatureBullet(
                            title: 'Büyümeye hazır temel',
                            detail: 'Şimdi single-player; sonra istersek cloud ve multiplayer ekleriz.',
                            accent: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: theme.darkSquare,
                              ),
                              onPressed: controller.completeOnboarding,
                              child: const Text('Oyuna Gir'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

    return _TabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _RevealOnMount(
            child: _HeroCard(
              accent: theme.accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Bugün tek hamle: ritmini koru.',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bir maç, bir puzzle, küçük bir gelişim. Fazla yük bindirmeyen ama güçlü hissettiren satranç akışı.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.darkSquare,
                        ),
                        onPressed: () {
                          controller.switchTab(1);
                        },
                        child: const Text('Maça Devam Et'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.44),
                          ),
                        ),
                        onPressed: controller.switchToDailyPuzzle,
                        child: const Text('Günlük Puzzle'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _RevealOnMount(
            delay: const Duration(milliseconds: 90),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _MetricCard(
                    label: 'Wins',
                    value: '${viewState.profile.wins}',
                    caption: '${viewState.profile.gamesPlayed} total games',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Streak',
                    value: '${viewState.profile.streakDays}',
                    caption: 'active days',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Solved',
                    value: '${viewState.profile.puzzlesSolved}',
                    caption: 'local puzzles',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _RevealOnMount(
            delay: const Duration(milliseconds: 150),
            child: _SectionCard(
              title: 'Starter Missions',
              subtitle: 'Short goals that keep the first week sticky.',
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
                            backgroundColor: theme.accent.withValues(alpha: 0.10),
                            color: theme.accent,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _RevealOnMount(
            delay: const Duration(milliseconds: 210),
            child: _SectionCard(
              title: 'Achievements',
              subtitle: achievements.isEmpty
                  ? 'İlk başarılar bir maç ve birkaç puzzle sonrasında açılır.'
                  : 'Küçük ama motive eden kilometre taşları.',
              child: achievements.isEmpty
                  ? Text(
                      'İlk rozeti almak için bir maçı bitir.',
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

    return _TabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            title: 'Engine Match',
            subtitle: game.statusDetail,
          ),
          const SizedBox(height: 16),
          _RevealOnMount(
            child: _SectionCard(
              title: game.statusTitle,
              subtitle:
                  game.resultDetail ?? 'Seviye seç, temiz hamlelerle akışı kur.',
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: viewState.aiThinking
                        ? Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Row(
                              key: const ValueKey<String>('thinking'),
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
                                  'Engine cevap hesaplıyor...',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey<String>('idle')),
                  ),
                ],
              ),
            ),
          ),
          if (game.gameOver) ...<Widget>[
            const SizedBox(height: 18),
            _RevealOnMount(
              delay: const Duration(milliseconds: 120),
              child: _SectionCard(
                title: game.resultTitle ?? 'Post-game room',
                subtitle: game.resultDetail ??
                    'İstersen analiz aç, istersen direkt yeni maça geç.',
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

    return _TabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            title: 'Offline Daily Puzzle',
            subtitle:
                '${puzzle.puzzle.theme} - ${viewState.puzzle.completedPuzzleIds.length}/500 solved locally',
          ),
          const SizedBox(height: 16),
          _RevealOnMount(
            child: _SectionCard(
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

    return _TabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            title: 'Monetization',
            subtitle: 'Ad + IAP dengesini oyuncuyu boğmadan kur.',
          ),
          const SizedBox(height: 16),
          _RevealOnMount(
            child: _HeroCard(
              accent: theme.darkSquare,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Premium oyuncuya konfor sağlar.',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pro paket reklamları kaldırır, tema kilitlerini açar ve maç sonrası analizi hızlandırır.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...productOffers.map((ProductOffer offer) {
            final bool owned = viewState.profile.ownedProductIds.contains(offer.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _RevealOnMount(
                delay: const Duration(milliseconds: 80),
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
              ),
            );
          }),
          _RevealOnMount(
            delay: const Duration(milliseconds: 140),
            child: _SectionCard(
              title: 'Board Themes',
              subtitle: 'Kozmetik yükseltmeler anında uygulanır.',
              child: Column(
                children: themePacks.map((AppThemePack pack) {
                  final bool unlocked =
                      viewState.profile.unlockedThemeIds.contains(pack.id);
                  final bool selected = viewState.profile.selectedThemeId == pack.id;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: selected
                          ? theme.accent.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.6),
                      border: Border.all(
                        color: selected
                            ? theme.accent
                            : Colors.black.withValues(alpha: 0.08),
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

    return _TabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            title: 'Settings & Launch Notes',
            subtitle: 'Konfor ayarları ve release hazırlık kontrolü.',
          ),
          const SizedBox(height: 16),
          _RevealOnMount(
            child: _SectionCard(
              title: 'Player Comfort',
              subtitle: 'Kısa seanslarda bile akışı yormayan varsayılanlar.',
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    value: viewState.profile.soundEnabled,
                    activeThumbColor: theme.accent,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Move sound'),
                    subtitle: const Text('Hamlede kısa sistem sesi kullan.'),
                    onChanged: controller.toggleSound,
                  ),
                  SwitchListTile(
                    value: viewState.profile.hapticsEnabled,
                    activeThumbColor: theme.accent,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Haptics'),
                    subtitle: const Text('Tahta etkileşiminde titreşim geri bildirimi.'),
                    onChanged: controller.toggleHaptics,
                  ),
                  SwitchListTile(
                    value: viewState.profile.boardFlipped,
                    activeThumbColor: theme.accent,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Flip board'),
                    subtitle: const Text('Pozisyonu iki taraftan da incelemek için.'),
                    onChanged: (_) => controller.toggleBoardFlip(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _RevealOnMount(
            delay: const Duration(milliseconds: 120),
            child: _SectionCard(
              title: 'Launch Hardening Checklist',
              subtitle: 'Store çıkışı öncesi bağlanacak son teknik parçalar.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ChecklistLine(text: 'Satın alma stublarını gerçek Play Billing ürünlerine bağla.'),
                  _ChecklistLine(text: 'Rewarded/interstitial akışını AdMob test ID ile doğrula.'),
                  _ChecklistLine(text: 'Yerel telemetry adapter yerine Firebase Analytics/Crashlytics tak.'),
                  _ChecklistLine(text: 'Mağaza görselleri, privacy policy ve consent akışını tamamla.'),
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
          ),
        ],
      ),
    );
  }
}

class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop({required this.theme});

  final AppThemePack theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            theme.background,
            theme.surface.withValues(alpha: 0.86),
            Colors.white,
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -80,
            right: -30,
            child: _GlowOrb(color: theme.accent.withValues(alpha: 0.18), size: 240),
          ),
          Positioned(
            top: 140,
            left: -70,
            child: _GlowOrb(
              color: theme.darkSquare.withValues(alpha: 0.10),
              size: 210,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: _GlowOrb(
              color: theme.accent.withValues(alpha: 0.12),
              size: 300,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _FloatingNavShell extends StatelessWidget {
  const _FloatingNavShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: ColoredBox(
          color: Colors.white.withValues(alpha: 0.86),
          child: child,
        ),
      ),
    );
  }
}

class _TabScroll extends StatelessWidget {
  const _TabScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: child,
        ),
      ),
    );
  }
}

class _RevealOnMount extends StatefulWidget {
  const _RevealOnMount({
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<_RevealOnMount> createState() => _RevealOnMountState();
}

class _RevealOnMountState extends State<_RevealOnMount> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : const Offset(0, 0.04),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        opacity: _visible ? 1 : 0,
        child: widget.child,
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
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(height: 1.35),
        ),
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
    final Color surfaceTint = Theme.of(context).colorScheme.surface;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.84),
            surfaceTint.withValues(alpha: 0.90),
          ],
        ),
        border: Border.all(color: Colors.black.withValues(alpha: 0.07)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
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
            accent.withValues(alpha: 0.98),
            accent.withValues(alpha: 0.76),
            const Color(0xFF192028),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.34),
            blurRadius: 26,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -26,
            right: -26,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.13),
              ),
            ),
          ),
          child,
        ],
      ),
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
    final Color accent = Theme.of(context).colorScheme.primary;
    return _SectionCard(
      title: label,
      subtitle: caption,
      child: Row(
        children: <Widget>[
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.88),
            ),
          ),
        ],
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
      color: Colors.white.withValues(alpha: 0.70),
      borderRadius: BorderRadius.circular(18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
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
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.92),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.84),
                      ),
                ),
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

