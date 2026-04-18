part of 'home_shell.dart';

class _HomeTab extends ConsumerWidget {
  const _HomeTab({required this.theme});

  final AppThemePack theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppViewState viewState = ref.watch(appControllerProvider);
    final DailyGambitController controller = ref.read(
      appControllerProvider.notifier,
    );
    final List<StarterMission> missions = buildStarterMissions(
      viewState.profile,
    );
    final List<AchievementDefinition> achievements = achievementDefinitions
        .where((AchievementDefinition achievement) {
          return viewState.profile.unlockedAchievementIds.contains(
            achievement.id,
          );
        })
        .toList();

    return _TabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _RevealOnMount(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 860;
                return Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: wide ? 6 : 0,
                      child: _GlassPanel(
                        blurSigma: 18,
                        padding: const EdgeInsets.all(26),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            theme.darkSquare.withValues(alpha: 0.94),
                            theme.accent.withValues(alpha: 0.86),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _BadgePill(
                              label: 'Daily loop',
                              foreground: Colors.white,
                              background: Colors.white.withValues(alpha: 0.14),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Train sharp. Monetize clean. Keep the rhythm alive.',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'One match, one puzzle, one respectful upsell surface. That is the entire operating system for v1.',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.86),
                                    height: 1.45,
                                  ),
                            ),
                            const SizedBox(height: 22),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: <Widget>[
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: theme.darkSquare,
                                  ),
                                  onPressed: () => controller.switchTab(1),
                                  child: const Text('Continue Match'),
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.44,
                                      ),
                                    ),
                                  ),
                                  onPressed: controller.switchToDailyPuzzle,
                                  child: const Text('Open Daily Puzzle'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 18),
                    Expanded(
                      flex: wide ? 4 : 0,
                      child: Column(
                        children: <Widget>[
                          _SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _SectionEyebrow(
                                  label: 'Retention posture',
                                  accent: theme.accent,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Designed for short adult sessions, not noisy dopamine spam.',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                const _ChecklistLine(
                                  text:
                                      'No ad interruptions inside active play.',
                                ),
                                const _ChecklistLine(
                                  text:
                                      'Rewarded utility only when the player asks for help.',
                                ),
                                const _ChecklistLine(
                                  text:
                                      'Cosmetics and analysis sit behind clear premium boundaries.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _RevealOnMount(
            delay: const Duration(milliseconds: 80),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 760;
                if (!wide) {
                  return Column(
                    children: <Widget>[
                      _MetricTile(
                        label: 'Streak',
                        value: '${viewState.profile.streakDays}',
                        caption: 'consecutive active days',
                        accent: theme.accent,
                        icon: Icons.local_fire_department_outlined,
                        emphasized: true,
                      ),
                      const SizedBox(height: 12),
                      _MetricTile(
                        label: 'Wins',
                        value: '${viewState.profile.wins}',
                        caption:
                            '${viewState.profile.gamesPlayed} games played',
                        accent: theme.darkSquare,
                        icon: Icons.emoji_events_outlined,
                      ),
                      const SizedBox(height: 12),
                      _MetricTile(
                        label: 'Solved',
                        value: '${viewState.profile.puzzlesSolved}',
                        caption: 'local tactics cleared',
                        accent: theme.accent,
                        icon: Icons.extension_outlined,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: _MetricTile(
                        label: 'Streak',
                        value: '${viewState.profile.streakDays}',
                        caption: 'consecutive active days',
                        accent: theme.accent,
                        icon: Icons.local_fire_department_outlined,
                        emphasized: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: _MetricTile(
                              label: 'Wins',
                              value: '${viewState.profile.wins}',
                              caption:
                                  '${viewState.profile.gamesPlayed} games played',
                              accent: theme.darkSquare,
                              icon: Icons.emoji_events_outlined,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _MetricTile(
                              label: 'Solved',
                              value: '${viewState.profile.puzzlesSolved}',
                              caption: 'local tactics cleared',
                              accent: theme.accent,
                              icon: Icons.extension_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _RevealOnMount(
            delay: const Duration(milliseconds: 140),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 860;
                return Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: wide ? 6 : 0,
                      child: _SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _SectionHeader(
                              title: 'Starter missions',
                              subtitle:
                                  'The first-week loop should feel guided, not gamified to death.',
                              accent: theme.accent,
                            ),
                            const SizedBox(height: 18),
                            ...missions.map((StarterMission mission) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _MissionProgressCard(
                                  mission: mission,
                                  accent: theme.accent,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 18),
                    Expanded(
                      flex: wide ? 4 : 0,
                      child: Column(
                        children: <Widget>[
                          _SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _SectionHeader(
                                  title: 'Achievements',
                                  subtitle: achievements.isEmpty
                                      ? 'The first badge should land quickly so the app does not feel empty.'
                                      : 'Lightweight status markers, not a bloated trophy room.',
                                  accent: theme.darkSquare,
                                ),
                                const SizedBox(height: 18),
                                if (achievements.isEmpty)
                                  Text(
                                    'Finish one match to unlock the first achievement and start visual progression.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(height: 1.45),
                                  )
                                else
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: achievements.map((
                                      AchievementDefinition achievement,
                                    ) {
                                      return _BadgePill(
                                        label: achievement.title,
                                        foreground: theme.darkSquare,
                                        background: theme.accent.withValues(
                                          alpha: 0.12,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _SurfaceCard(
                            backgroundColor: theme.darkSquare.withValues(
                              alpha: 0.05,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _SectionHeader(
                                  title: 'Revenue stance',
                                  subtitle:
                                      'This product should make money by reducing friction, not by being annoying.',
                                  accent: theme.darkSquare,
                                ),
                                const SizedBox(height: 18),
                                const _ChecklistLine(
                                  text:
                                      'Rewarded hint, extra undo, and analysis preview stay utility-shaped.',
                                ),
                                const _ChecklistLine(
                                  text:
                                      'Pro removes ads and opens cosmetic + analysis depth.',
                                ),
                                const _ChecklistLine(
                                  text:
                                      'Interstitials stay capped and never break the core board loop.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
    final DailyGambitController controller = ref.read(
      appControllerProvider.notifier,
    );
    final AppBootstrap bootstrap = ref.read(bootstrapProvider);
    final LiveGameState game = bootstrap.gameSessionService.inspect(
      viewState.game,
    );

    if (selectedSquare != null &&
        !game.targetsBySource.containsKey(selectedSquare)) {
      selectedSquare = null;
    }

    final Set<String> highlighted = selectedSquare == null
        ? <String>{}
        : game.targetsBySource[selectedSquare!] ?? <String>{};
    final Set<String> hintSquares = viewState.game.hintMove == null
        ? <String>{}
        : <String>{
            viewState.game.hintMove!.substring(0, 2),
            viewState.game.hintMove!.substring(2, 4),
          };
    final String turnLabel = game.gameOver
        ? 'Session closed'
        : game.playerTurn
        ? 'White to move'
        : 'Engine to move';

    return _TabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _RevealOnMount(
            child: _SectionHeader(
              title: 'Engine match',
              subtitle:
                  'Board-first play surface with calm controls around it.',
              accent: widget.theme.accent,
            ),
          ),
          const SizedBox(height: 18),
          _RevealOnMount(
            delay: const Duration(milliseconds: 80),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 920;
                return Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: wide ? 6 : 0,
                      child: _SurfaceCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                _StatusPill(
                                  label: turnLabel,
                                  accent: widget.theme.accent,
                                ),
                                _StatusPill(
                                  label: 'Level ${viewState.game.difficulty}',
                                  accent: widget.theme.darkSquare,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            RepaintBoundary(
                              child: ChessBoard(
                                fen: game.fen,
                                themePack: widget.theme,
                                flipped: viewState.profile.boardFlipped,
                                selectedSquare: selectedSquare,
                                highlightedSquares: highlighted,
                                hintSquares: hintSquares,
                                onSquareTap: (String square) => _handleTap(
                                  square,
                                  game,
                                  viewState,
                                  controller,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap source then destination. Hint and undo stay outside the playfield so the board remains clean.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(height: 1.45),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 18),
                    Expanded(
                      flex: wide ? 4 : 0,
                      child: Column(
                        children: <Widget>[
                          _SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  game.statusTitle,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  game.resultDetail ?? game.statusDetail,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(height: 1.45),
                                ),
                                const SizedBox(height: 18),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List<Widget>.generate(5, (
                                    int index,
                                  ) {
                                    final int difficulty = index + 1;
                                    return ChoiceChip(
                                      label: Text('Level $difficulty'),
                                      selected:
                                          viewState.game.difficulty ==
                                          difficulty,
                                      onSelected: (_) =>
                                          controller.setDifficulty(difficulty),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _SectionEyebrow(
                                  label: 'Control rail',
                                  accent: widget.theme.accent,
                                ),
                                const SizedBox(height: 14),
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.28,
                                  children: <Widget>[
                                    _ActionTile(
                                      icon: Icons.undo_rounded,
                                      title: 'Undo',
                                      detail:
                                          'Use a granted extra step without leaving the board.',
                                      accent: widget.theme.darkSquare,
                                      onTap: controller.undoGame,
                                    ),
                                    _ActionTile(
                                      icon: Icons.lightbulb_outline_rounded,
                                      title: 'Hint',
                                      detail:
                                          'Rewarded guidance for the next move only.',
                                      accent: widget.theme.accent,
                                      onTap: controller.unlockGameHint,
                                    ),
                                    _ActionTile(
                                      icon: Icons.flip_rounded,
                                      title: 'Flip',
                                      detail:
                                          'Review the same position from the other side.',
                                      accent: widget.theme.darkSquare,
                                      onTap: controller.toggleBoardFlip,
                                    ),
                                    _ActionTile(
                                      icon: Icons.replay_rounded,
                                      title: 'Restart',
                                      detail:
                                          'Reset the session fast and keep the pace moving.',
                                      accent: widget.theme.accent,
                                      onTap: controller.restartGame,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: viewState.aiThinking
                                ? _GlassPanel(
                                    key: const ValueKey<String>('thinking'),
                                    blurSigma: 12,
                                    padding: const EdgeInsets.all(18),
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: widget.theme.accent,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Engine is calculating a reply. The board stays interactive only after the line is resolved.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(height: 1.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey<String>('idle'),
                                  ),
                          ),
                          if (game.gameOver) ...<Widget>[
                            const SizedBox(height: 18),
                            _SurfaceCard(
                              backgroundColor: widget.theme.accent.withValues(
                                alpha: 0.08,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _SectionEyebrow(
                                    label: game.resultTitle ?? 'Post-game room',
                                    accent: widget.theme.accent,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    game.resultDetail ??
                                        'Analysis should appear as a clear premium value add.',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(height: 1.45),
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed:
                                          controller.unlockAnalysisPreview,
                                      icon: const Icon(
                                        Icons.analytics_outlined,
                                      ),
                                      label: Text(
                                        viewState.profile.premiumUnlocked
                                            ? 'Show Analysis'
                                            : 'Rewarded Analysis',
                                      ),
                                    ),
                                  ),
                                  if (viewState.game.analysisUnlocked &&
                                      viewState.game.analysisSummary !=
                                          null) ...<Widget>[
                                    const SizedBox(height: 14),
                                    Text(
                                      viewState.game.analysisSummary!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(height: 1.45),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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

    final Set<String> currentTargets = selectedSquare == null
        ? <String>{}
        : game.targetsBySource[selectedSquare!] ?? <String>{};

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
    final DailyGambitController controller = ref.read(
      appControllerProvider.notifier,
    );
    final AppBootstrap bootstrap = ref.read(bootstrapProvider);
    final LivePuzzleState puzzle = bootstrap.puzzleService.inspect(
      viewState.puzzle,
    );

    if (selectedSquare != null &&
        !puzzle.targetsBySource.containsKey(selectedSquare)) {
      selectedSquare = null;
    }

    final Set<String> highlighted = selectedSquare == null
        ? <String>{}
        : puzzle.targetsBySource[selectedSquare!] ?? <String>{};
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
          _RevealOnMount(
            child: _SectionHeader(
              title: 'Daily puzzle',
              subtitle:
                  'A local tactic loop that resets with device date, no backend ceremony required.',
              accent: widget.theme.accent,
            ),
          ),
          const SizedBox(height: 18),
          _RevealOnMount(
            delay: const Duration(milliseconds: 80),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 920;
                return Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: wide ? 6 : 0,
                      child: _SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                _StatusPill(
                                  label: puzzle.puzzle.theme,
                                  accent: widget.theme.accent,
                                ),
                                _StatusPill(
                                  label:
                                      'Difficulty ${puzzle.puzzle.difficulty}/5',
                                  accent: widget.theme.darkSquare,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            RepaintBoundary(
                              child: ChessBoard(
                                fen: puzzle.fen,
                                themePack: widget.theme,
                                flipped: viewState.profile.boardFlipped,
                                selectedSquare: selectedSquare,
                                highlightedSquares: highlighted,
                                hintSquares: hintSquares,
                                onSquareTap: (String square) => _handleTap(
                                  square,
                                  puzzle,
                                  viewState,
                                  controller,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Solved locally: ${viewState.puzzle.completedPuzzleIds.length}/500',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 18),
                    Expanded(
                      flex: wide ? 4 : 0,
                      child: Column(
                        children: <Widget>[
                          _GlassPanel(
                            blurSigma: 16,
                            padding: const EdgeInsets.all(22),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                widget.theme.accent.withValues(alpha: 0.92),
                                widget.theme.darkSquare.withValues(alpha: 0.84),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _BadgePill(
                                  label: puzzle.statusTitle,
                                  foreground: Colors.white,
                                  background: Colors.white.withValues(
                                    alpha: 0.14,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  puzzle.statusDetail,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.88,
                                        ),
                                        height: 1.45,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _SectionEyebrow(
                                  label: 'Puzzle actions',
                                  accent: widget.theme.accent,
                                ),
                                const SizedBox(height: 14),
                                _ActionTile(
                                  icon: Icons.lightbulb_outline_rounded,
                                  title: 'Rewarded hint',
                                  detail:
                                      'Reveal only the next move and keep the learning loop intact.',
                                  accent: widget.theme.accent,
                                  onTap: controller.unlockPuzzleHint,
                                ),
                                const SizedBox(height: 12),
                                _ActionTile(
                                  icon: Icons.refresh_rounded,
                                  title: 'Reset daily line',
                                  detail:
                                      'Restart the active tactic instantly when you want a cleaner read.',
                                  accent: widget.theme.darkSquare,
                                  onTap: controller.switchToDailyPuzzle,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _SurfaceCard(
                            backgroundColor: widget.theme.darkSquare.withValues(
                              alpha: 0.05,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _SectionHeader(
                                  title: 'Retention role',
                                  subtitle:
                                      'Daily puzzle is the cleanest reason to reopen the app tomorrow.',
                                  accent: widget.theme.darkSquare,
                                ),
                                const SizedBox(height: 18),
                                const _ChecklistLine(
                                  text:
                                      'Date-driven puzzle rotation works fully offline.',
                                ),
                                const _ChecklistLine(
                                  text:
                                      'Rewarded help can monetize without corrupting the board flow.',
                                ),
                                const _ChecklistLine(
                                  text:
                                      'Solved count, streak, and achievements reinforce the return habit.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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

    final Set<String> currentTargets = selectedSquare == null
        ? <String>{}
        : puzzle.targetsBySource[selectedSquare!] ?? <String>{};

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
    final DailyGambitController controller = ref.read(
      appControllerProvider.notifier,
    );

    return _TabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _RevealOnMount(
            child: _SectionHeader(
              title: 'Shop',
              subtitle:
                  'Premium surfaces should feel cleaner than the free tier, not louder.',
              accent: theme.accent,
            ),
          ),
          const SizedBox(height: 18),
          _RevealOnMount(
            delay: const Duration(milliseconds: 80),
            child: _GlassPanel(
              blurSigma: 18,
              padding: const EdgeInsets.all(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  theme.darkSquare.withValues(alpha: 0.94),
                  theme.accent.withValues(alpha: 0.82),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _BadgePill(
                    label: 'Featured offer',
                    foreground: Colors.white,
                    background: Colors.white.withValues(alpha: 0.14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pro should remove friction, not invent it.',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ads off, themes unlocked, analysis always available. The value prop stays simple enough to convert.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _RevealOnMount(
            delay: const Duration(milliseconds: 120),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final int columns = constraints.maxWidth >= 920
                    ? 3
                    : constraints.maxWidth >= 620
                    ? 2
                    : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productOffers.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.08,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final ProductOffer offer = productOffers[index];
                    final bool owned = viewState.profile.ownedProductIds
                        .contains(offer.id);
                    return _SurfaceCard(
                      backgroundColor: offer.id == 'pro_pack'
                          ? theme.accent.withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.92),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _SectionEyebrow(
                            label: offer.priceLabel,
                            accent: offer.id == 'pro_pack'
                                ? theme.accent
                                : theme.darkSquare,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            offer.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            offer.subtitle,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.45),
                          ),
                          const Spacer(),
                          Text(
                            offer.highlight,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: owned
                                  ? null
                                  : () => controller.purchase(offer.id),
                              child: Text(owned ? 'Owned' : 'Unlock'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          _RevealOnMount(
            delay: const Duration(milliseconds: 160),
            child: _SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SectionHeader(
                    title: 'Board themes',
                    subtitle:
                        'Theme packs should read like premium materials, not random skins.',
                    accent: theme.darkSquare,
                  ),
                  const SizedBox(height: 18),
                  ...themePacks.map((AppThemePack pack) {
                    final bool unlocked = viewState.profile.unlockedThemeIds
                        .contains(pack.id);
                    final bool selected =
                        viewState.profile.selectedThemeId == pack.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ThemeRow(
                        pack: pack,
                        accent: theme.accent,
                        unlocked: unlocked,
                        selected: selected,
                        onSelect: () => controller.selectTheme(pack.id),
                        onUnlock: () => controller.purchase('theme_pack'),
                      ),
                    );
                  }),
                ],
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
    final DailyGambitController controller = ref.read(
      appControllerProvider.notifier,
    );

    return _TabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _RevealOnMount(
            child: _SectionHeader(
              title: 'Settings',
              subtitle:
                  'Comfort controls and launch hardening should feel like part of the product, not a dump zone.',
              accent: theme.accent,
            ),
          ),
          const SizedBox(height: 18),
          _RevealOnMount(
            delay: const Duration(milliseconds: 80),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 860;
                return Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: wide ? 5 : 0,
                      child: _SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _SectionHeader(
                              title: 'Player comfort',
                              subtitle:
                                  'Small control surfaces with clear consequences.',
                              accent: theme.accent,
                            ),
                            const SizedBox(height: 18),
                            _SettingToggleRow(
                              title: 'Move sound',
                              detail:
                                  'Use lightweight click feedback on piece interaction.',
                              value: viewState.profile.soundEnabled,
                              onChanged: controller.toggleSound,
                            ),
                            const SizedBox(height: 12),
                            _SettingToggleRow(
                              title: 'Haptics',
                              detail:
                                  'Reinforce taps without adding noisy vibration patterns.',
                              value: viewState.profile.hapticsEnabled,
                              onChanged: controller.toggleHaptics,
                            ),
                            const SizedBox(height: 12),
                            _SettingToggleRow(
                              title: 'Flip board',
                              detail:
                                  'Review positions from the opposite side whenever needed.',
                              value: viewState.profile.boardFlipped,
                              onChanged: (_) => controller.toggleBoardFlip(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 18),
                    Expanded(
                      flex: wide ? 5 : 0,
                      child: Column(
                        children: <Widget>[
                          _SurfaceCard(
                            backgroundColor: theme.darkSquare.withValues(
                              alpha: 0.05,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _SectionHeader(
                                  title: 'Launch hardening',
                                  subtitle:
                                      'The last-mile store work still needs to become real integrations.',
                                  accent: theme.darkSquare,
                                ),
                                const SizedBox(height: 18),
                                const _ChecklistLine(
                                  text:
                                      'Swap billing stubs for real Google Play Billing products.',
                                ),
                                const _ChecklistLine(
                                  text:
                                      'Validate rewarded and interstitial triggers with AdMob test IDs.',
                                ),
                                const _ChecklistLine(
                                  text:
                                      'Connect Firebase Analytics, Crashlytics, and consent flow.',
                                ),
                                const _ChecklistLine(
                                  text:
                                      'Finalize privacy policy and store metadata before launch.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _GlassPanel(
                            blurSigma: 12,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _SectionEyebrow(
                                  label: 'Purchases',
                                  accent: theme.accent,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Restore ownership cleanly when the player moves devices or reinstalls.',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(height: 1.45),
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.tonalIcon(
                                    onPressed: controller.restorePurchases,
                                    icon: const Icon(Icons.restore),
                                    label: const Text('Restore Purchases'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionProgressCard extends StatelessWidget {
  const _MissionProgressCard({required this.mission, required this.accent});

  final StarterMission mission;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.7),
        border: Border.all(
          color: mission.completed
              ? accent.withValues(alpha: 0.28)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _BadgePill(
                  label: mission.completed ? 'Complete' : 'In progress',
                  foreground: mission.completed ? Colors.white : accent,
                  background: mission.completed
                      ? accent
                      : accent.withValues(alpha: 0.12),
                ),
                const Spacer(),
                Text(
                  '${mission.progress}/${mission.target}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(mission.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              mission.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: (mission.progress / mission.target).clamp(0, 1),
                backgroundColor: accent.withValues(alpha: 0.10),
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.pack,
    required this.accent,
    required this.unlocked,
    required this.selected,
    required this.onSelect,
    required this.onUnlock,
  });

  final AppThemePack pack;
  final Color accent;
  final bool unlocked;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: selected
            ? accent.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.7),
        border: Border.all(
          color: selected ? accent : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
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
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        pack.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (pack.premium)
                      _BadgePill(
                        label: 'Premium',
                        foreground: accent,
                        background: accent.withValues(alpha: 0.12),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  pack.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!unlocked)
            OutlinedButton(onPressed: onUnlock, child: const Text('Unlock'))
          else
            FilledButton.tonal(
              onPressed: selected ? null : onSelect,
              child: Text(selected ? 'Selected' : 'Equip'),
            ),
        ],
      ),
    );
  }
}

class _SettingToggleRow extends StatelessWidget {
  const _SettingToggleRow({
    required this.title,
    required this.detail,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String detail;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.72),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
