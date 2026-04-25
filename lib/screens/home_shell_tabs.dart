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
    final AppBootstrap bootstrap = ref.read(bootstrapProvider);
    final LiveGameState liveGame = bootstrap.gameSessionService.inspect(
      viewState.game,
    );
    final bool activeMatch =
        viewState.game.sanHistory.isNotEmpty && !liveGame.gameOver;
    final List<StarterMission> missions = buildStarterMissions(
      viewState.profile,
    );
    final List<AchievementDefinition> achievements = achievementDefinitions
        .where(
          (AchievementDefinition item) =>
              viewState.profile.unlockedAchievementIds.contains(item.id),
        )
        .toList();

    return _PhonePage(
      bottomPadding: 112,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ReferenceTopBar(
            title: 'Daily Gambit',
            leading: _IconTap(
              icon: Icons.menu_rounded,
              onTap: () => controller.switchTab(4),
            ),
            trailing: _IconTap(
              icon: Icons.notifications_none_rounded,
              onTap: controller.clearBanner,
            ),
          ),
          const SizedBox(height: 10),
          _FadeIn(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Daily Streak',
                    value: '${viewState.profile.streakDays}',
                    suffix: 'days',
                    accent: const Color(0xFFE1782D),
                    child: _WeekDots(
                      active: viewState.profile.streakDays,
                      accent: theme.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Rating',
                    value: '${_estimatedRating(viewState.profile)}',
                    suffix: 'Rapid',
                    accent: theme.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _FadeIn(
            delay: const Duration(milliseconds: 40),
            child: _GoldButton(
              label: activeMatch ? 'Resume' : 'Play',
              subtitle: activeMatch
                  ? '${viewState.game.sanHistory.length} half-moves in'
                  : 'Fresh AI Match',
              onTap: () => unawaited(controller.playNow()),
            ),
          ),
          const SizedBox(height: 12),
          _FadeIn(
            delay: const Duration(milliseconds: 70),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _HomeShortcut(
                    icon: Icons.extension_rounded,
                    title: 'Puzzles',
                    subtitle: 'Solve Daily',
                    onTap: () => unawaited(controller.switchToDailyPuzzle()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HomeShortcut(
                    icon: Icons.emoji_events_rounded,
                    title: 'Missions',
                    subtitle:
                        '${missions.where((StarterMission item) => !item.completed).length} Active',
                    onTap: () => controller.switchTab(0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FadeIn(
            delay: const Duration(milliseconds: 100),
            child: _SoftPanel(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Achievements',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        'View all',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List<Widget>.generate(4, (int index) {
                      final bool unlocked = index < achievements.length;
                      final String title = unlocked
                          ? achievements[index].title
                          : index == 0
                          ? 'First Steps'
                          : 'Locked';
                      return Expanded(
                        child: _MedalTile(
                          title: title,
                          unlocked: unlocked,
                          accent: theme.accent,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _FadeIn(
            delay: const Duration(milliseconds: 130),
            child: _PremiumStrip(
              owned: viewState.profile.premiumUnlocked,
              onTap: () => controller.switchTab(3),
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

    if (game.gameOver) {
      return _ResultScreen(
        theme: widget.theme,
        game: game,
        profile: viewState.profile,
        onBack: () => controller.switchTab(0),
        onReview: controller.unlockAnalysisPreview,
        onRestart: controller.restartGame,
      );
    }

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
    final String? toastMessage = _playfieldToast(viewState.bannerMessage);

    return _PhonePage(
      backgroundColor: _RefColor.match,
      bottomPadding: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ReferenceTopBar(
            title: 'AI Match',
            subtitle: _difficultyLabel(viewState.game.difficulty),
            dark: true,
            leading: _IconTap(
              icon: Icons.arrow_back_rounded,
              dark: true,
              onTap: () => controller.switchTab(0),
            ),
            trailing: _IconTap(
              icon: Icons.settings_rounded,
              dark: true,
              onTap: () => controller.switchTab(4),
            ),
          ),
          const SizedBox(height: 8),
          _DifficultyPips(
            current: viewState.game.difficulty,
            accent: widget.theme.accent,
            onSelected: (int level) =>
                unawaited(controller.setDifficulty(level)),
          ),
          const SizedBox(height: 8),
          _MatchPlayerStrip(
            pieceCode: 0x265F,
            title: 'Black (AI)',
            rating: '1200',
            tag: 'Lv ${viewState.game.difficulty}',
            dark: true,
          ),
          const SizedBox(height: 10),
          _FadeIn(
            child: ChessBoard(
              fen: game.fen,
              themePack: widget.theme,
              flipped: viewState.profile.boardFlipped,
              graphicsQuality: viewState.profile.graphicsQuality,
              selectedSquare: selectedSquare,
              highlightedSquares: highlighted,
              hintSquares: hintSquares,
              lastMove: viewState.game.lastMove,
              capturedByWhite: game.capturedByWhite,
              capturedByBlack: game.capturedByBlack,
              lastCapturedPiece: game.lastCapturedPiece,
              onSquareTap: (String square) =>
                  _handleTap(square, game, viewState, controller),
            ),
          ),
          const SizedBox(height: 8),
          if (toastMessage != null) ...<Widget>[
            _PlayfieldToast(
              message: toastMessage,
              accent: widget.theme.accent,
              dark: true,
            ),
            const SizedBox(height: 8),
          ] else
            const SizedBox(height: 2),
          _MatchPlayerStrip(
            pieceCode: 0x2654,
            title: 'You',
            rating: '${_estimatedRating(viewState.profile)}',
            tag: game.playerTurn ? 'Your move' : 'Thinking',
            accent: widget.theme.accent,
            dark: true,
          ),
          const SizedBox(height: 12),
          if (viewState.aiThinking)
            _ThinkingStrip(accent: widget.theme.accent)
          else
            _MatchDock(
              onUndo: controller.undoGame,
              onHint: controller.unlockGameHint,
              onRestart: controller.restartGame,
            ),
          const SizedBox(height: 12),
          _SmallLabel(
            game.statusDetail,
            color: Colors.white.withValues(alpha: 0.54),
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
      unawaited(controller.playGameMove(from, square));
      if (viewState.profile.soundEnabled) {
        SystemSound.play(SystemSoundType.click);
      }
      return;
    }

    if (selectedSquare != null && !game.targetsBySource.containsKey(square)) {
      setState(() => selectedSquare = null);
      controller.showBanner('That square is not available from here.');
      if (viewState.profile.hapticsEnabled) {
        HapticFeedback.lightImpact();
      }
      return;
    }

    if (selectedSquare == square) {
      setState(() => selectedSquare = null);
      return;
    }

    setState(() {
      selectedSquare = game.targetsBySource.containsKey(square) ? square : null;
    });
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

    if (puzzle.completed) {
      return _PuzzleSolvedScreen(
        accent: widget.theme.accent,
        onBack: () => controller.switchTab(0),
        onContinue: () => unawaited(controller.continuePuzzle()),
      );
    }

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
    final String? toastMessage = _playfieldToast(viewState.bannerMessage);

    return _PhonePage(
      backgroundColor: const Color(0xFFF9F3EA),
      bottomPadding: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ReferenceTopBar(
            title: 'Daily Puzzle',
            leading: _IconTap(
              icon: Icons.arrow_back_rounded,
              onTap: () => controller.switchTab(0),
            ),
            trailing: _IconTap(
              icon: Icons.bar_chart_rounded,
              onTap: controller.clearBanner,
            ),
          ),
          const SizedBox(height: 10),
          _SoftPanel(
            padding: const EdgeInsets.all(8),
            color: _RefColor.matchPanel,
            borderColor: _RefColor.matchPanel,
            child: Row(
              children: <Widget>[
                _DarkChip('Puzzle ${puzzle.puzzle.id.split('_').last}'),
                const Spacer(),
                Icon(Icons.circle, size: 8, color: widget.theme.accent),
                const SizedBox(width: 6),
                Text(
                  _difficultyLabel(puzzle.puzzle.difficulty),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _FadeIn(
            child: ChessBoard(
              fen: puzzle.fen,
              themePack: widget.theme,
              flipped: viewState.profile.boardFlipped,
              graphicsQuality: viewState.profile.graphicsQuality,
              selectedSquare: selectedSquare,
              highlightedSquares: highlighted,
              hintSquares: hintSquares,
              lastMove: viewState.puzzle.playedMoves.isEmpty
                  ? null
                  : viewState.puzzle.playedMoves.last,
              onSquareTap: (String square) =>
                  _handleTap(square, puzzle, viewState, controller),
            ),
          ),
          const SizedBox(height: 10),
          if (toastMessage != null) ...<Widget>[
            _PlayfieldToast(message: toastMessage, accent: widget.theme.accent),
            const SizedBox(height: 10),
          ] else
            const SizedBox(height: 6),
          Text(
            puzzle.puzzle.prompt,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _RefColor.ink,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: controller.unlockPuzzleHint,
            icon: const Icon(Icons.lightbulb_outline_rounded),
            label: const Text('Hint'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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

    final Set<String> currentTargets = selectedSquare == null
        ? <String>{}
        : puzzle.targetsBySource[selectedSquare!] ?? <String>{};

    if (selectedSquare != null && currentTargets.contains(square)) {
      final String from = selectedSquare!;
      setState(() => selectedSquare = null);
      unawaited(controller.playPuzzleMove(from, square));
      if (viewState.profile.soundEnabled) {
        SystemSound.play(SystemSoundType.click);
      }
      return;
    }

    if (selectedSquare != null && !puzzle.targetsBySource.containsKey(square)) {
      setState(() => selectedSquare = null);
      controller.showBanner('That tactic move is not legal.');
      if (viewState.profile.hapticsEnabled) {
        HapticFeedback.lightImpact();
      }
      return;
    }

    if (selectedSquare == square) {
      setState(() => selectedSquare = null);
      return;
    }

    setState(() {
      selectedSquare = puzzle.targetsBySource.containsKey(square)
          ? square
          : null;
    });
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

    return _PhonePage(
      bottomPadding: 112,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ReferenceTopBar(
            title: 'Shop',
            leading: _IconTap(
              icon: Icons.arrow_back_rounded,
              onTap: () => controller.switchTab(0),
            ),
            trailing: _CoinBadge(value: '250'),
          ),
          const SizedBox(height: 8),
          _ShopTabs(),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: themePacks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.70,
            ),
            itemBuilder: (BuildContext context, int index) {
              final AppThemePack pack = themePacks[index];
              final bool unlocked = viewState.profile.unlockedThemeIds.contains(
                pack.id,
              );
              final bool selected =
                  viewState.profile.selectedThemeId == pack.id;
              return _ThemeShopCard(
                pack: pack,
                unlocked: unlocked,
                selected: selected,
                onTap: unlocked
                    ? () => unawaited(controller.selectTheme(pack.id))
                    : () => unawaited(controller.purchase('theme_pack')),
              );
            },
          ),
          const SizedBox(height: 14),
          _GoldButton(
            label: viewState.profile.premiumUnlocked
                ? 'Premium Active'
                : 'Unlock Premium',
            subtitle: 'Remove ads and open every board',
            icon: Icons.workspace_premium_rounded,
            onTap: () => unawaited(controller.purchase('pro_pack')),
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

    return _PhonePage(
      bottomPadding: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ReferenceTopBar(
            title: 'Settings',
            leading: _IconTap(
              icon: Icons.arrow_back_rounded,
              onTap: () => controller.switchTab(0),
            ),
          ),
          const SizedBox(height: 8),
          _SettingsSection(
            title: 'Account',
            children: <Widget>[
              const _SettingsRow(
                icon: Icons.person_outline_rounded,
                title: 'Profile',
                value: 'Local Player',
              ),
              const _SettingsRow(
                icon: Icons.link_rounded,
                title: 'Linked Account',
                value: 'Offline',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            title: 'Preferences',
            children: <Widget>[
              _SettingsRow(
                icon: Icons.dashboard_customize_outlined,
                title: 'Board Theme',
                value: theme.name,
              ),
              const _SettingsRow(
                icon: Icons.extension_outlined,
                title: 'Piece Set',
                value: 'Staunton',
              ),
              _SwitchRow(
                icon: Icons.volume_up_outlined,
                title: 'Sound',
                value: viewState.profile.soundEnabled,
                onChanged: controller.toggleSound,
              ),
              _SwitchRow(
                icon: Icons.vibration_rounded,
                title: 'Vibration',
                value: viewState.profile.hapticsEnabled,
                onChanged: controller.toggleHaptics,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            title: 'Gameplay',
            children: <Widget>[
              _SettingsRow(
                icon: Icons.shield_outlined,
                title: 'Play as',
                value: viewState.profile.boardFlipped ? 'Black' : 'White',
              ),
              _SwitchRow(
                icon: Icons.flip_rounded,
                title: 'Flip Board',
                value: viewState.profile.boardFlipped,
                onChanged: (_) => unawaited(controller.toggleBoardFlip()),
              ),
              _GraphicsQualityRow(
                value: viewState.profile.graphicsQuality,
                onChanged: (GraphicsQuality quality) =>
                    unawaited(controller.setGraphicsQuality(quality)),
              ),
              const _SettingsRow(
                icon: Icons.remove_red_eye_outlined,
                title: 'Show Hints',
                value: 'Rewarded',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            title: 'About',
            children: const <Widget>[
              _SettingsRow(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                value: 'Draft',
              ),
              _SettingsRow(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                value: 'Draft',
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: controller.restorePurchases,
            icon: const Icon(Icons.restore_rounded),
            label: const Text('Restore Purchases'),
          ),
        ],
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

String _difficultyLabel(int difficulty) {
  if (difficulty <= 2) {
    return 'Easy';
  }
  if (difficulty == 3) {
    return 'Medium';
  }
  return 'Hard';
}

String? _playfieldToast(String? message) {
  if (message == null || message == 'Engine thinking...') {
    return null;
  }
  if (message.contains('No interstitial') ||
      message.contains('Interstitial ready') ||
      message.contains('Premium user') ||
      message.contains('Daily interstitial')) {
    return null;
  }
  if (message.contains('Hint ready')) {
    return 'Hint highlighted on the board.';
  }
  if (message.contains('Best move highlighted')) {
    return 'Best move highlighted.';
  }
  if (message.contains('Rewarded break') || message.contains('Benefit')) {
    return 'Reward unlocked.';
  }
  if (message.contains('not legal from the current board') ||
      message.contains('not available')) {
    return 'No move there.';
  }
  if (message.contains('tactic move')) {
    return 'No tactic there.';
  }
  if (message.contains('Keep looking')) {
    return 'Try a cleaner forcing move.';
  }
  if (message.contains('Puzzle solved')) {
    return 'Solved. Streak updated.';
  }
  return message;
}

class _PlayfieldToast extends StatelessWidget {
  const _PlayfieldToast({
    required this.message,
    required this.accent,
    this.dark = false,
  });

  final String message;
  final Color accent;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      child: DecoratedBox(
        key: ValueKey<String>(message),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: dark
              ? Colors.white.withValues(alpha: 0.08)
              : _RefColor.ink.withValues(alpha: 0.06),
          border: Border.all(
            color: dark
                ? Colors.white.withValues(alpha: 0.10)
                : accent.withValues(alpha: 0.20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.bolt_rounded,
                size: 15,
                color: dark ? accent : _RefColor.goldDark,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark
                        ? Colors.white.withValues(alpha: 0.78)
                        : _RefColor.ink.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyPips extends StatelessWidget {
  const _DifficultyPips({
    required this.current,
    required this.accent,
    required this.onSelected,
  });

  final int current;
  final Color accent;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      color: _RefColor.matchPanel,
      borderColor: Colors.white.withValues(alpha: 0.07),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: <Widget>[
          Text(
            'Level',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.64),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: List<Widget>.generate(5, (int index) {
                final int level = index + 1;
                final bool selected = level == current;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: selected
                          ? accent
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: selected ? null : () => onSelected(level),
                        child: SizedBox(
                          height: 28,
                          child: Center(
                            child: Text(
                              '$level',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.70),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _difficultyLabel(current),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.suffix,
    required this.accent,
    this.child,
  });

  final IconData icon;
  final String title;
  final String value;
  final String suffix;
  final Color accent;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Icon(icon, size: 22, color: accent),
              const SizedBox(width: 6),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  color: _RefColor.ink,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  suffix,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (child != null) ...<Widget>[const SizedBox(height: 12), child!],
        ],
      ),
    );
  }
}

class _WeekDots extends StatelessWidget {
  const _WeekDots({required this.active, required this.accent});

  final int active;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    const List<String> labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final int count = active.clamp(0, labels.length);
    return Row(
      children: List<Widget>.generate(labels.length, (int index) {
        return Expanded(
          child: Column(
            children: <Widget>[
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < count ? accent : Colors.transparent,
                  border: Border.all(
                    color: index < count
                        ? accent
                        : _RefColor.ink.withValues(alpha: 0.28),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(labels[index], style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );
      }),
    );
  }
}

class _HomeShortcut extends StatelessWidget {
  const _HomeShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Icon(icon, color: _RefColor.ink, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class _MedalTile extends StatelessWidget {
  const _MedalTile({
    required this.title,
    required this.unlocked,
    required this.accent,
  });

  final String title;
  final bool unlocked;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: unlocked
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[_RefColor.gold, _RefColor.goldDark],
                  )
                : null,
            color: unlocked ? null : Colors.white.withValues(alpha: 0.38),
            border: Border.all(
              color: unlocked
                  ? _RefColor.goldDark.withValues(alpha: 0.38)
                  : _RefColor.line,
            ),
          ),
          child: Icon(
            unlocked ? Icons.workspace_premium_rounded : Icons.lock_rounded,
            size: 20,
            color: unlocked ? Colors.white : _RefColor.line,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _PremiumStrip extends StatelessWidget {
  const _PremiumStrip({required this.owned, required this.onTap});

  final bool owned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _RefColor.match,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.workspace_premium_rounded,
                color: _RefColor.gold,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      owned ? 'Premium Active' : 'Premium',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      owned
                          ? 'All premium themes unlocked'
                          : 'Unlock premium themes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.70),
                      ),
                    ),
                  ],
                ),
              ),
              _GoldButton(label: 'View Shop', compact: true, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchPlayerStrip extends StatelessWidget {
  const _MatchPlayerStrip({
    required this.pieceCode,
    required this.title,
    required this.rating,
    required this.tag,
    this.accent = _RefColor.gold,
    this.dark = false,
  });

  final int pieceCode;
  final String title;
  final String rating;
  final String tag;
  final Color accent;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      color: dark ? _RefColor.matchPanel : Colors.white.withValues(alpha: 0.55),
      borderColor: dark ? Colors.white.withValues(alpha: 0.06) : _RefColor.line,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: dark
                  ? Colors.black.withValues(alpha: 0.22)
                  : accent.withValues(alpha: 0.12),
            ),
            child: _PieceGlyph(
              codePoint: pieceCode,
              size: 26,
              color: pieceCode == 0x2654 ? Colors.white : Colors.black,
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
                    color: dark ? Colors.white : _RefColor.ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  rating,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark
                        ? Colors.white.withValues(alpha: 0.60)
                        : _RefColor.muted,
                  ),
                ),
              ],
            ),
          ),
          _DarkChip(tag),
        ],
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  const _DarkChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.82),
          ),
        ),
      ),
    );
  }
}

class _MatchDock extends StatelessWidget {
  const _MatchDock({
    required this.onUndo,
    required this.onHint,
    required this.onRestart,
  });

  final VoidCallback onUndo;
  final VoidCallback onHint;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      color: const Color(0xFF231F1A),
      borderColor: Colors.white.withValues(alpha: 0.08),
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 66,
        child: Row(
          children: <Widget>[
            _DockButton(icon: Icons.undo_rounded, label: 'Undo', onTap: onUndo),
            _DockDivider(),
            _DockButton(
              icon: Icons.lightbulb_outline_rounded,
              label: 'Hint',
              onTap: onHint,
            ),
            _DockDivider(),
            _DockButton(
              icon: Icons.restart_alt_rounded,
              label: 'Restart',
              onTap: onRestart,
            ),
          ],
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 19, color: Colors.white.withValues(alpha: 0.82)),
            const SizedBox(height: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: 46,
      child: ColoredBox(color: Colors.white.withValues(alpha: 0.08)),
    );
  }
}

class _ThinkingStrip extends StatelessWidget {
  const _ThinkingStrip({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      color: _RefColor.matchPanel,
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: accent),
          ),
          const SizedBox(width: 10),
          Text(
            'Engine thinking',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  const _ResultScreen({
    required this.theme,
    required this.game,
    required this.profile,
    required this.onBack,
    required this.onReview,
    required this.onRestart,
  });

  final AppThemePack theme;
  final LiveGameState game;
  final AppProfile profile;
  final VoidCallback onBack;
  final VoidCallback onReview;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final bool won = (game.resultTitle ?? '').toLowerCase().contains('secured');
    return _PhonePage(
      bottomPadding: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ReferenceTopBar(
            title: won ? 'You Won' : game.resultTitle ?? 'Game Over',
            subtitle: won ? 'by Checkmate' : 'Match complete',
            leading: _IconTap(icon: Icons.arrow_back_rounded, onTap: onBack),
            trailing: _IconTap(icon: Icons.share_rounded, onTap: onReview),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _ResultPlayerCard(
                  title: 'You',
                  rating: '${_estimatedRating(profile)}',
                  active: won,
                  pieceCode: 0x2654,
                ),
              ),
              SizedBox(
                width: 70,
                child: Center(
                  child: Text(
                    won ? '1-0' : '0-1',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              const Expanded(
                child: _ResultPlayerCard(
                  title: 'Black (AI)',
                  rating: '1200',
                  active: false,
                  pieceCode: 0x265F,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SoftPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Game Accuracy',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _ScoreBox(
                        label: 'You',
                        value: won ? '92.4' : '68.1',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ScoreBox(
                        label: 'AI',
                        value: won ? '68.1' : '92.4',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SoftPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Key Moments',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _TrendLine(accent: theme.accent),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SoftPanel(
            child: Text(
              game.resultDetail ?? 'Review the match and start a cleaner run.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: _GoldButton(
                  label: 'Review Game',
                  compact: true,
                  onTap: onReview,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onRestart,
                  child: const Text('Play Again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultPlayerCard extends StatelessWidget {
  const _ResultPlayerCard({
    required this.title,
    required this.rating,
    required this.active,
    required this.pieceCode,
  });

  final String title;
  final String rating;
  final bool active;
  final int pieceCode;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      color: active ? const Color(0xFF6B7E45) : const Color(0xFFE2DED8),
      borderColor: active ? const Color(0xFF6B7E45) : _RefColor.line,
      child: Column(
        children: <Widget>[
          _PieceGlyph(
            codePoint: pieceCode,
            size: 48,
            color: active ? Colors.white : _RefColor.ink,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: active ? Colors.white : _RefColor.ink,
            ),
          ),
          Text(
            rating,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: active
                  ? Colors.white.withValues(alpha: 0.78)
                  : _RefColor.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  const _ScoreBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withValues(alpha: 0.54),
        border: Border.all(color: _RefColor.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _TrendLine extends StatelessWidget {
  const _TrendLine({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: CustomPaint(painter: _TrendPainter(accent)),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = _RefColor.line
      ..strokeWidth = 1;
    for (int i = 1; i < 4; i++) {
      final double y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final List<Offset> points = <Offset>[
      Offset(0, size.height * 0.70),
      Offset(size.width * 0.18, size.height * 0.64),
      Offset(size.width * 0.34, size.height * 0.58),
      Offset(size.width * 0.52, size.height * 0.46),
      Offset(size.width * 0.70, size.height * 0.30),
      Offset(size.width, size.height * 0.20),
    ];
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final Offset point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = accent
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    for (final Offset point in points) {
      canvas.drawCircle(point, 3, Paint()..color = accent);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

class _PuzzleSolvedScreen extends StatelessWidget {
  const _PuzzleSolvedScreen({
    required this.accent,
    required this.onBack,
    required this.onContinue,
  });

  final Color accent;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      backgroundColor: _RefColor.reward,
      bottomPadding: 20,
      scroll: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ReferenceTopBar(
            title: 'Excellent!',
            subtitle: 'Puzzle Solved',
            dark: true,
            leading: _IconTap(
              icon: Icons.arrow_back_rounded,
              dark: true,
              onTap: onBack,
            ),
          ),
          const SizedBox(height: 36),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Icon(
                    Icons.energy_savings_leaf_outlined,
                    size: 190,
                    color: accent.withValues(alpha: 0.20),
                  ),
                  _PieceGlyph(
                    codePoint: 0x2658,
                    size: 128,
                    color: const Color(0xFFF8E3B8),
                  ),
                ],
              ),
            ),
          ),
          Text(
            '+10',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFFF8E3B8),
              fontSize: 34,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Streak Bonus',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 22),
          _SoftPanel(
            color: Colors.transparent,
            borderColor: accent.withValues(alpha: 0.56),
            shadow: false,
            child: Text(
              'Solved in this daily run',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 18),
          _GoldButton(label: 'Continue', onTap: onContinue),
        ],
      ),
    );
  }
}

class _CoinBadge extends StatelessWidget {
  const _CoinBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: _RefColor.ink,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.workspace_premium_rounded,
              size: 15,
              color: _RefColor.gold,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const List<String> tabs = <String>['Themes', 'Pieces', 'Boards', 'Avatars'];
    return _SoftPanel(
      padding: const EdgeInsets.all(5),
      shadow: false,
      child: Row(
        children: tabs.map((String tab) {
          final bool selected = tab == 'Themes';
          return Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: selected ? _RefColor.gold.withValues(alpha: 0.16) : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? _RefColor.goldDark : _RefColor.muted,
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

class _ThemeShopCard extends StatelessWidget {
  const _ThemeShopCard({
    required this.pack,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  final AppThemePack pack;
  final bool unlocked;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _RefColor.match,
            border: Border.all(
              color: selected
                  ? pack.accent
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: _ThemeBoardArt(pack: pack)),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 34,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        pack.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        unlocked ? 'Owned' : 'Premium',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: pack.accent),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 12,
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : unlocked
                        ? Icons.radio_button_unchecked_rounded
                        : Icons.lock_rounded,
                    size: 20,
                    color: selected
                        ? pack.accent
                        : Colors.white.withValues(alpha: 0.86),
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

class _ThemeBoardArt extends StatelessWidget {
  const _ThemeBoardArt({required this.pack});

  final AppThemePack pack;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.18,
      child: Transform.scale(
        scale: 1.28,
        child: Column(
          children: List<Widget>.generate(6, (int rank) {
            return Expanded(
              child: Row(
                children: List<Widget>.generate(6, (int file) {
                  final bool light = (rank + file).isEven;
                  return Expanded(
                    child: ColoredBox(
                      color: light ? pack.lightSquare : pack.darkSquare,
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
            child: Text(title, style: Theme.of(context).textTheme.bodySmall),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: _RefColor.ink),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: _RefColor.muted,
          ),
        ],
      ),
    );
  }
}

class _GraphicsQualityRow extends StatelessWidget {
  const _GraphicsQualityRow({required this.value, required this.onChanged});

  final GraphicsQuality value;
  final ValueChanged<GraphicsQuality> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.speed_rounded, size: 16, color: _RefColor.ink),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Graphics',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                value.targetLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: GraphicsQuality.values.map((GraphicsQuality quality) {
              final bool selected = quality == value;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: selected
                        ? _RefColor.ink
                        : _RefColor.ink.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: selected ? null : () => onChanged(quality),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          quality.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: selected ? Colors.white : _RefColor.ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: _RefColor.ink),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
