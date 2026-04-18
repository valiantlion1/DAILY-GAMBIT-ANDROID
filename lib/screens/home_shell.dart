import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import '../core/models.dart';
import '../widgets/chess_board.dart';

part 'home_shell_surfaces.dart';
part 'home_shell_tabs.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppViewState viewState = ref.watch(appControllerProvider);
    final DailyGambitController controller = ref.read(
      appControllerProvider.notifier,
    );
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
      extendBody: true,
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
                          child: _InlineBanner(
                            message: viewState.bannerMessage!,
                            accent: theme.accent,
                            onClose: controller.clearBanner,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _TopShellBar(theme: theme, profile: viewState.profile),
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
          theme: theme,
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
  const _OnboardingScreen({required this.theme, required this.controller});

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final bool wide = constraints.maxWidth >= 780;
                      return Flex(
                        direction: wide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            flex: wide ? 6 : 0,
                            child: _GlassPanel(
                              blurSigma: 18,
                              padding: const EdgeInsets.all(28),
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
                                    label: 'ANDROID EARLY ACCESS',
                                    foreground: Colors.white,
                                    background: Colors.white.withValues(
                                      alpha: 0.16,
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
                                    'A premium-casual chess routine built to feel deliberate, adult, and actually test revenue without wrecking session flow.',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.88,
                                          ),
                                          height: 1.45,
                                        ),
                                  ),
                                  const SizedBox(height: 26),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: const <Widget>[
                                      _CompactFeaturePill(
                                        icon: Icons.wifi_off_rounded,
                                        label: 'Offline-first',
                                      ),
                                      _CompactFeaturePill(
                                        icon: Icons.smart_display_outlined,
                                        label: 'Respectful ads',
                                      ),
                                      _CompactFeaturePill(
                                        icon: Icons.auto_awesome_outlined,
                                        label: 'Premium themes',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                  const _FeatureBullet(
                                    title: 'No mid-match interruptions',
                                    detail:
                                        'Interstitials only fire between loops, never during active play.',
                                    accent: Colors.white,
                                  ),
                                  const _FeatureBullet(
                                    title: 'Local retention loop',
                                    detail:
                                        'Daily puzzle, streak, missions, and unlocks all work without a backend.',
                                    accent: Colors.white,
                                  ),
                                  const _FeatureBullet(
                                    title: 'Monetization with restraint',
                                    detail:
                                        'Rewarded hint, extra undo, and analysis preview support the loop instead of punishing it.',
                                    accent: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 18),
                          Expanded(
                            flex: wide ? 4 : 0,
                            child: _SurfaceCard(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _SectionEyebrow(
                                    label: 'Launch posture',
                                    accent: theme.accent,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'What this build is optimizing for',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Fast daily return, clean monetization surfaces, and a board-first interface that does not look like a toy.',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(height: 1.45),
                                  ),
                                  const SizedBox(height: 22),
                                  const _ChecklistLine(
                                    text:
                                        '5 AI levels with restart, flip, undo, and hint rhythm.',
                                  ),
                                  const _ChecklistLine(
                                    text:
                                        '500 bundled puzzles plus a date-driven daily challenge.',
                                  ),
                                  const _ChecklistLine(
                                    text:
                                        'Themes, achievements, streak, and starter mission loop.',
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: controller.completeOnboarding,
                                      child: const Text('Enter the Game'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
