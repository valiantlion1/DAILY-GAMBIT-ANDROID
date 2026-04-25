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
    final int estimatedRating = _estimatedRating(viewState.profile);

    return _TabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _RevealOnMount(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 920;
                final Widget dashboard = _SurfaceCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _DashboardOverviewCard(
                              title: 'Daily Streak',
                              value: '${viewState.profile.streakDays}',
                              subtitle: 'days',
                              accent: theme.accent,
                              leading: Icons.local_fire_department_rounded,
                              footer: _WeekProgressDots(
                                activeCount: viewState.profile.streakDays,
                                accent: theme.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DashboardOverviewCard(
                              title: 'Rating',
                              value: '$estimatedRating',
                              subtitle: 'rapid',
                              accent: theme.accent,
                              leading: Icons.workspace_premium_rounded,
                              valueStyle: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(fontSize: 32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => controller.switchTab(1),
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                theme.accent,
                                theme.accent.withValues(alpha: 0.82),
                              ],
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: theme.accent.withValues(alpha: 0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Play',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontSize: 24,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'AI Match',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.84,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 24,
                                  color: Colors.white.withValues(alpha: 0.94),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _QuickHomeTile(
                              icon: Icons.extension_rounded,
                              title: 'Puzzles',
                              subtitle: 'Solve Daily',
                              accent: theme.darkSquare,
                              onTap: controller.switchToDailyPuzzle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickHomeTile(
                              icon: Icons.emoji_events_outlined,
                              title: 'Missions',
                              subtitle:
                                  '${missions.where((StarterMission mission) => !mission.completed).length} Active',
                              accent: theme.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Achievements',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List<Widget>.generate(4, (int index) {
                          final bool unlocked = index < achievements.length;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index == 3 ? 0 : 8,
                              ),
                              child: _AchievementMedallion(
                                label: unlocked
                                    ? achievements[index].title
                                    : 'Locked',
                                unlocked: unlocked,
                                accent: theme.accent,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),
                      _PremiumRibbon(
                        accent: theme.accent,
                        owned: viewState.profile.premiumUnlocked,
                        onTap: () => controller.switchTab(3),
                      ),
                    ],
                  ),
                );

                final Widget sideRail = Column(
                  children: <Widget>[
                    _SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _SectionEyebrow(label: 'Today', accent: theme.accent),
                          const SizedBox(height: 12),
                          Text(
                            'One match, one puzzle, one clean return.',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          const _ChecklistLine(
                            text:
                                'Open the AI match without interruptive ad pressure.',
                          ),
                          const _ChecklistLine(
                            text:
                                'Solve the daily tactic before the streak cools down.',
                          ),
                          const _ChecklistLine(
                            text:
                                'Keep premium offers utility-shaped and visually calm.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SurfaceCard(
                      backgroundColor: theme.darkSquare.withValues(alpha: 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _SectionEyebrow(
                            label: 'Conversion posture',
                            accent: theme.darkSquare,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Premium should feel like polish, not pressure.',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Themes, analysis depth, and ad removal read better when the free product already feels composed.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.45),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 6, child: dashboard),
                      const SizedBox(width: 18),
                      Expanded(flex: 4, child: sideRail),
                    ],
                  );
                }

                return Column(
                  children: <Widget>[
                    dashboard,
                    const SizedBox(height: 18),
                    sideRail,
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
                final Widget missionsCard = _SurfaceCard(
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
                );
                final Widget supportRail = Column(
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
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(height: 1.45),
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
                      backgroundColor: theme.darkSquare.withValues(alpha: 0.05),
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
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 6, child: missionsCard),
                      const SizedBox(width: 18),
                      Expanded(flex: 4, child: supportRail),
                    ],
                  );
                }

                return Column(
                  children: <Widget>[
                    missionsCard,
                    const SizedBox(height: 18),
                    supportRail,
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
    final int estimatedRating = _estimatedRating(viewState.profile);

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
                final Widget stage = _SurfaceCard(
                  backgroundColor: const Color(0xFF221C18),
                  padding: const EdgeInsets.all(16),
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _MatchSideStrip(
                                title: 'Black (AI)',
                                value: '1200',
                                accent: widget.theme.lightSquare,
                                dark: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _StagePill(
                              label: 'Level ${viewState.game.difficulty}',
                              dark: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        RepaintBoundary(
                          child: ChessBoard(
                            fen: game.fen,
                            themePack: widget.theme,
                            flipped: viewState.profile.boardFlipped,
                            selectedSquare: selectedSquare,
                            highlightedSquares: highlighted,
                            hintSquares: hintSquares,
                            onSquareTap: (String square) =>
                                _handleTap(square, game, viewState, controller),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _MatchSideStrip(
                                title: 'You',
                                value: '$estimatedRating',
                                accent: widget.theme.accent,
                                dark: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _StagePill(label: turnLabel, dark: true),
                          ],
                        ),
                        const SizedBox(height: 14),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.white.withValues(alpha: 0.08),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: _DockActionButton(
                                    icon: Icons.undo_rounded,
                                    label: 'Undo',
                                    onTap: controller.undoGame,
                                  ),
                                ),
                                Expanded(
                                  child: _DockActionButton(
                                    icon: Icons.lightbulb_outline_rounded,
                                    label: 'Hint',
                                    onTap: controller.unlockGameHint,
                                  ),
                                ),
                                Expanded(
                                  child: _DockActionButton(
                                    icon: Icons.replay_rounded,
                                    label: 'Restart',
                                    onTap: controller.restartGame,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                final Widget rail = Column(
                  children: <Widget>[
                    _SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            game.statusTitle,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            game.resultDetail ?? game.statusDetail,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(height: 1.45),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List<Widget>.generate(5, (int index) {
                              final int difficulty = index + 1;
                              return ChoiceChip(
                                label: Text('Level $difficulty'),
                                selected:
                                    viewState.game.difficulty == difficulty,
                                onSelected: (_) =>
                                    controller.setDifficulty(difficulty),
                              );
                            }),
                          ),
                          const SizedBox(height: 14),
                          _StageNotice(
                            icon: Icons.flip_rounded,
                            title: 'Board orientation',
                            detail: viewState.profile.boardFlipped
                                ? 'Viewing from Black.'
                                : 'Viewing from White.',
                            actionLabel: 'Flip',
                            onTap: controller.toggleBoardFlip,
                          ),
                        ],
                      ),
                    ),
                    if (viewState.aiThinking) ...<Widget>[
                      const SizedBox(height: 18),
                      _GlassPanel(
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
                                'Engine is calculating a reply.',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    if (game.gameOver)
                      _MatchResultPanel(
                        accent: widget.theme.accent,
                        youRating: estimatedRating,
                        aiRating: 1200,
                        resultTitle: game.resultTitle ?? 'Game finished',
                        resultDetail:
                            game.resultDetail ??
                            'Analysis should appear as a clear premium value add.',
                        scoreLabel: _resultScoreLabel(game.resultTitle),
                        analysisSummary: viewState.game.analysisSummary,
                        analysisUnlocked: viewState.game.analysisUnlocked,
                        premiumUnlocked: viewState.profile.premiumUnlocked,
                        onReview: controller.unlockAnalysisPreview,
                      )
                    else
                      _SurfaceCard(
                        backgroundColor: widget.theme.accent.withValues(
                          alpha: 0.08,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _SectionEyebrow(
                              label: 'Board discipline',
                              accent: widget.theme.accent,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap source then destination. Keep the board clean.',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Hint and restart live outside the playfield so the match keeps its focus.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(height: 1.45),
                            ),
                          ],
                        ),
                      ),
                  ],
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 6, child: stage),
                      const SizedBox(width: 18),
                      Expanded(flex: 4, child: rail),
                    ],
                  );
                }

                return Column(
                  children: <Widget>[stage, const SizedBox(height: 18), rail],
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
                final Widget puzzleBoard = _SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          _StagePill(label: puzzle.puzzle.theme),
                          const SizedBox(width: 8),
                          _StagePill(
                            label: 'Difficulty ${puzzle.puzzle.difficulty}/5',
                          ),
                          const Spacer(),
                          Text(
                            'Solved ${viewState.puzzle.completedPuzzleIds.length}/500',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RepaintBoundary(
                        child: ChessBoard(
                          fen: puzzle.fen,
                          themePack: widget.theme,
                          flipped: viewState.profile.boardFlipped,
                          selectedSquare: selectedSquare,
                          highlightedSquares: highlighted,
                          hintSquares: hintSquares,
                          onSquareTap: (String square) =>
                              _handleTap(square, puzzle, viewState, controller),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        puzzle.completed
                            ? 'Puzzle solved.'
                            : puzzle.puzzle.prompt,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        puzzle.statusDetail,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.45),
                      ),
                      const SizedBox(height: 18),
                      if (!puzzle.completed)
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ShadButton.outline(
                                onPressed: controller.unlockPuzzleHint,
                                leading: const Icon(
                                  Icons.lightbulb_outline_rounded,
                                ),
                                child: const Text('Hint'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ShadButton.secondary(
                                onPressed: controller.switchToDailyPuzzle,
                                leading: const Icon(Icons.refresh_rounded),
                                child: const Text('Reset'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );

                final Widget aside = puzzle.completed
                    ? _PuzzleVictoryPanel(
                        accent: widget.theme.accent,
                        onContinue: controller.switchToDailyPuzzle,
                      )
                    : Column(
                        children: <Widget>[
                          _SurfaceCard(
                            backgroundColor: widget.theme.darkSquare.withValues(
                              alpha: 0.05,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _SectionEyebrow(
                                  label: 'Daily role',
                                  accent: widget.theme.darkSquare,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'This is the cleanest reason to reopen tomorrow.',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 10),
                                const _ChecklistLine(
                                  text:
                                      'Date-driven rotation works fully offline.',
                                ),
                                const _ChecklistLine(
                                  text:
                                      'Hints monetize without breaking the board.',
                                ),
                                const _ChecklistLine(
                                  text:
                                      'Solved count strengthens the daily habit.',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _GlassPanel(
                            blurSigma: 14,
                            padding: const EdgeInsets.all(22),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                widget.theme.accent.withValues(alpha: 0.94),
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
                                  'Return fast, solve one precise idea, keep the streak moving.',
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
                        ],
                      );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 6, child: puzzleBoard),
                      const SizedBox(width: 18),
                      Expanded(flex: 4, child: aside),
                    ],
                  );
                }

                return Column(
                  children: <Widget>[
                    puzzleBoard,
                    const SizedBox(height: 18),
                    aside,
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
            child: _SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const <Widget>[
                          _StagePill(label: 'Themes'),
                          _StagePill(label: 'Pieces'),
                          _StagePill(label: 'Boards'),
                          _StagePill(label: 'Avatars'),
                        ],
                      ),
                      const Spacer(),
                      _StagePill(label: '250'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Collect board materials, not noisy skins.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Premium surfaces should feel like a refined cabinet: calmer previews, clearer ownership, and no fake scarcity tricks.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.45),
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
                    ? 4
                    : constraints.maxWidth >= 620
                    ? 2
                    : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: themePacks.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.80,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final AppThemePack pack = themePacks[index];
                    final bool unlocked = viewState.profile.unlockedThemeIds
                        .contains(pack.id);
                    final bool selected =
                        viewState.profile.selectedThemeId == pack.id;
                    return _ThemePreviewCard(
                      pack: pack,
                      unlocked: unlocked,
                      selected: selected,
                      onSelect: () => controller.selectTheme(pack.id),
                      onUnlock: () => controller.purchase('theme_pack'),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          _RevealOnMount(
            delay: const Duration(milliseconds: 160),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 760;
                final List<Widget> offerCards = productOffers.map((
                  ProductOffer offer,
                ) {
                  final bool owned = viewState.profile.ownedProductIds.contains(
                    offer.id,
                  );
                  return _OfferFeatureCard(
                    offer: offer,
                    owned: owned,
                    accent: theme.accent,
                    onTap: owned ? null : () => controller.purchase(offer.id),
                  );
                }).toList();
                if (wide) {
                  return Row(
                    children: <Widget>[
                      Expanded(child: offerCards[0]),
                      const SizedBox(width: 12),
                      Expanded(child: offerCards[1]),
                    ],
                  );
                }
                return Column(
                  children: <Widget>[
                    offerCards[0],
                    const SizedBox(height: 12),
                    offerCards[1],
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  children: <Widget>[
                    _SettingsSectionCard(
                      title: 'Account',
                      children: <Widget>[
                        _SettingsValueRow(
                          icon: Icons.person_outline_rounded,
                          title: 'Profile',
                          value: 'Local Player',
                        ),
                        _SettingsValueRow(
                          icon: Icons.link_rounded,
                          title: 'Linked Account',
                          value: 'Offline only',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SettingsSectionCard(
                      title: 'Preferences',
                      children: <Widget>[
                        _SettingsValueRow(
                          icon: Icons.dashboard_customize_outlined,
                          title: 'Board Theme',
                          value: theme.name,
                        ),
                        const _SettingsValueRow(
                          icon: Icons.extension_outlined,
                          title: 'Piece Set',
                          value: 'Staunton',
                        ),
                        _SettingToggleRow(
                          title: 'Move sound',
                          detail: 'Piece interaction clicks',
                          value: viewState.profile.soundEnabled,
                          onChanged: controller.toggleSound,
                        ),
                        _SettingToggleRow(
                          title: 'Vibration',
                          detail: 'Light haptic reinforcement',
                          value: viewState.profile.hapticsEnabled,
                          onChanged: controller.toggleHaptics,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SettingsSectionCard(
                      title: 'Gameplay',
                      children: <Widget>[
                        _SettingsValueRow(
                          icon: Icons.flag_outlined,
                          title: 'Play as',
                          value: viewState.profile.boardFlipped
                              ? 'Black'
                              : 'White',
                        ),
                        _SettingToggleRow(
                          title: 'Flip board',
                          detail: 'Review from the opposite side',
                          value: viewState.profile.boardFlipped,
                          onChanged: (_) => controller.toggleBoardFlip(),
                        ),
                        const _SettingsValueRow(
                          icon: Icons.remove_red_eye_outlined,
                          title: 'Hint Surface',
                          value: 'Rewarded only',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SettingsSectionCard(
                      title: 'About',
                      children: const <Widget>[
                        _SettingsValueRow(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          value: 'Required before launch',
                        ),
                        _SettingsValueRow(
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          value: 'Store-ready draft',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
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
                            child: ShadButton.secondary(
                              onPressed: controller.restorePurchases,
                              leading: const Icon(Icons.restore),
                              child: const Text('Restore Purchases'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.72),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            ShadSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

int _estimatedRating(AppProfile profile) {
  return (1200 +
          (profile.wins * 14) -
          (profile.losses * 8) +
          (profile.puzzlesSolved * 2))
      .clamp(1100, 1850);
}

String _resultScoreLabel(String? resultTitle) {
  final String normalized = (resultTitle ?? '').toLowerCase();
  if (normalized.contains('draw') || normalized.contains('stalemate')) {
    return '1/2-1/2';
  }
  if (normalized.contains('lost') ||
      normalized.contains('defeat') ||
      normalized.contains('black')) {
    return '0-1';
  }
  return '1-0';
}

class _StagePill extends StatelessWidget {
  const _StagePill({required this.label, this.dark = false});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color background = dark
        ? Colors.white.withValues(alpha: 0.08)
        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.10);
    final Color foreground = dark
        ? Colors.white.withValues(alpha: 0.86)
        : Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: background,
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: foreground),
        ),
      ),
    );
  }
}

class _DashboardOverviewCard extends StatelessWidget {
  const _DashboardOverviewCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.leading,
    this.footer,
    this.valueStyle,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final IconData leading;
  final Widget? footer;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.88),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(leading, size: 18, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style:
                  valueStyle ??
                  Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: 34),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            if (footer != null) ...<Widget>[
              const SizedBox(height: 10),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _WeekProgressDots extends StatelessWidget {
  const _WeekProgressDots({required this.activeCount, required this.accent});

  final int activeCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    const List<String> labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final int clamped = activeCount.clamp(0, labels.length);
    return Column(
      children: <Widget>[
        Row(
          children: List<Widget>.generate(labels.length, (int index) {
            return Expanded(
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < clamped ? accent : Colors.transparent,
                    border: Border.all(
                      color: index < clamped
                          ? accent
                          : accent.withValues(alpha: 0.34),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: labels.map((String label) {
            return Expanded(
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuickHomeTile extends StatelessWidget {
  const _QuickHomeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: 0.88),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: accent.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementMedallion extends StatelessWidget {
  const _AchievementMedallion({
    required this.label,
    required this.unlocked,
    required this.accent,
  });

  final String label;
  final bool unlocked;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: unlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      accent.withValues(alpha: 0.92),
                      accent.withValues(alpha: 0.68),
                    ],
                  )
                : null,
            color: unlocked ? null : Colors.black.withValues(alpha: 0.06),
            border: Border.all(
              color: unlocked
                  ? accent.withValues(alpha: 0.24)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Icon(
            unlocked
                ? Icons.workspace_premium_rounded
                : Icons.lock_outline_rounded,
            color: unlocked
                ? Colors.white
                : Colors.black.withValues(alpha: 0.22),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _PremiumRibbon extends StatelessWidget {
  const _PremiumRibbon({
    required this.accent,
    required this.owned,
    required this.onTap,
  });

  final Color accent;
  final bool owned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[const Color(0xFF26211D), const Color(0xFF463225)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(Icons.workspace_premium_rounded, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Premium',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    owned
                        ? 'All premium themes unlocked.'
                        : 'Unlock refined themes and full analysis.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ShadButton(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              onPressed: onTap,
              child: Text(owned ? 'View Shop' : 'View Shop'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchSideStrip extends StatelessWidget {
  const _MatchSideStrip({
    required this.title,
    required this.value,
    required this.accent,
    this.dark = false,
  });

  final String title;
  final String value;
  final Color accent;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: dark
            ? Colors.white.withValues(alpha: 0.08)
            : accent.withValues(alpha: 0.08),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.08)
              : accent.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 16,
              backgroundColor: accent.withValues(alpha: dark ? 0.18 : 0.14),
              child: Icon(
                Icons.person_rounded,
                size: 16,
                color: dark ? Colors.white : accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: dark ? Colors.white : null,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? Colors.white.withValues(alpha: 0.66) : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockActionButton extends StatelessWidget {
  const _DockActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.84)),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageNotice extends StatelessWidget {
  const _StageNotice({
    required this.icon,
    required this.title,
    required this.detail,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(detail, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ShadButton.secondary(onPressed: onTap, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _MatchResultPanel extends StatelessWidget {
  const _MatchResultPanel({
    required this.accent,
    required this.youRating,
    required this.aiRating,
    required this.resultTitle,
    required this.resultDetail,
    required this.scoreLabel,
    required this.analysisSummary,
    required this.analysisUnlocked,
    required this.premiumUnlocked,
    required this.onReview,
  });

  final Color accent;
  final int youRating;
  final int aiRating;
  final String resultTitle;
  final String resultDetail;
  final String scoreLabel;
  final String? analysisSummary;
  final bool analysisUnlocked;
  final bool premiumUnlocked;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      backgroundColor: accent.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(resultTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _ResultAvatarCard(
                  title: 'You',
                  rating: '$youRating',
                  accent: accent,
                  active: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  scoreLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: 28),
                ),
              ),
              Expanded(
                child: _ResultAvatarCard(
                  title: 'Black (AI)',
                  rating: '$aiRating',
                  accent: Colors.black.withValues(alpha: 0.58),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Key moments', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          const _MiniTrendChart(),
          const SizedBox(height: 14),
          Text(
            analysisUnlocked && analysisSummary != null
                ? analysisSummary!
                : resultDetail,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ShadButton(
              onPressed: onReview,
              leading: const Icon(Icons.analytics_outlined),
              child: Text(premiumUnlocked ? 'Review Game' : 'Unlock Analysis'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultAvatarCard extends StatelessWidget {
  const _ResultAvatarCard({
    required this.title,
    required this.rating,
    required this.accent,
    this.active = false,
  });

  final String title;
  final String rating;
  final Color accent;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: active
            ? accent.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.66),
        border: Border.all(
          color: active
              ? accent.withValues(alpha: 0.24)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundColor: active
                  ? accent.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.08),
              child: Icon(
                Icons.person_rounded,
                color: active ? accent : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(rating, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MiniTrendChart extends StatelessWidget {
  const _MiniTrendChart();

  @override
  Widget build(BuildContext context) {
    const List<double> bars = <double>[0.10, 0.24, 0.28, 0.48, 0.62, 0.74];
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.70),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars.map((double bar) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 12 + (bar * 52),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xFFC39A5B), Color(0xFF8A6A43)],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PuzzleVictoryPanel extends StatelessWidget {
  const _PuzzleVictoryPanel({required this.accent, required this.onContinue});

  final Color accent;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      backgroundColor: const Color(0xFF203327),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Excellent!',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: const Color(0xFFF5E0B8)),
          ),
          const SizedBox(height: 4),
          Text(
            'Puzzle Solved',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.76),
            ),
          ),
          const SizedBox(height: 22),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                Icons.energy_savings_leaf_outlined,
                size: 110,
                color: accent.withValues(alpha: 0.22),
              ),
              Text(
                '♘',
                style: TextStyle(
                  fontSize: 110,
                  color: const Color(0xFFF5E0B8),
                  shadows: <Shadow>[
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '+10 streak bonus',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: const Color(0xFFF5E0B8)),
          ),
          const SizedBox(height: 8),
          Text(
            'Solved cleanly. Continue into the next loop.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.76),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ShadButton(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferFeatureCard extends StatelessWidget {
  const _OfferFeatureCard({
    required this.offer,
    required this.owned,
    required this.accent,
    required this.onTap,
  });

  final ProductOffer offer;
  final bool owned;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      backgroundColor: offer.id == 'pro_pack'
          ? accent.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionEyebrow(
            label: offer.priceLabel,
            accent: offer.id == 'pro_pack' ? accent : Colors.black87,
          ),
          const SizedBox(height: 12),
          Text(offer.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            offer.subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 14),
          Text(offer.highlight, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ShadButton(
              onPressed: onTap,
              child: Text(owned ? 'Owned' : 'Unlock'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.pack,
    required this.unlocked,
    required this.selected,
    required this.onSelect,
    required this.onUnlock,
  });

  final AppThemePack pack;
  final bool unlocked;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      backgroundColor: selected
          ? pack.accent.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.92),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  pack.darkSquare.withValues(alpha: 0.96),
                  Color.alphaBlend(
                    pack.accent.withValues(alpha: 0.14),
                    pack.darkSquare,
                  ),
                ],
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: List<Widget>.generate(3, (int rank) {
                        return Expanded(
                          child: Row(
                            children: List<Widget>.generate(3, (int file) {
                              final bool isLight = (rank + file).isEven;
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: isLight
                                        ? pack.lightSquare
                                        : pack.darkSquare.withValues(
                                            alpha: 0.72,
                                          ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : unlocked
                        ? Icons.circle_outlined
                        : Icons.lock_rounded,
                    color: selected
                        ? pack.accent
                        : Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(pack.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            pack.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
          ),
          const Spacer(),
          if (pack.premium)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _StagePill(label: 'Premium'),
            ),
          SizedBox(
            width: double.infinity,
            child: unlocked
                ? ShadButton.secondary(
                    onPressed: selected ? null : onSelect,
                    child: Text(selected ? 'Selected' : 'Equip'),
                  )
                : ShadButton.outline(
                    onPressed: onUnlock,
                    child: const Text('Unlock'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...children.map((Widget child) {
            final int index = children.indexOf(child);
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == children.length - 1 ? 0 : 8,
              ),
              child: child,
            );
          }),
        ],
      ),
    );
  }
}

class _SettingsValueRow extends StatelessWidget {
  const _SettingsValueRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.72),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 12),
            Text(value, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Colors.black.withValues(alpha: 0.22),
            ),
          ],
        ),
      ),
    );
  }
}
