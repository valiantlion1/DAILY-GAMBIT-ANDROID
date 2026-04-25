import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
                      final Widget heroCard = _GlassPanel(
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
                              background: Colors.white.withValues(alpha: 0.16),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'Daily Gambit',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'A premium-casual chess routine built to feel deliberate, adult, and actually test revenue without wrecking session flow.',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    height: 1.45,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: const <Widget>[
                                _CompactFeaturePill(
                                  icon: Icons.wifi_off_rounded,
                                  label: 'Offline-first',
                                ),
                                _CompactFeaturePill(
                                  icon: Icons.workspace_premium_outlined,
                                  label: 'Gold surfaces',
                                ),
                                _CompactFeaturePill(
                                  icon: Icons.extension_outlined,
                                  label: 'Daily puzzle',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: wide ? 300 : 240,
                              child: const _OnboardingPieceScene(),
                            ),
                          ],
                        ),
                      );
                      final Widget postureCard = _SurfaceCard(
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
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Fast daily return, clean monetization surfaces, and a board-first interface that feels collected.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(height: 1.45),
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
                              child: ShadButton(
                                onPressed: controller.completeOnboarding,
                                child: const Text('Enter the Game'),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(flex: 6, child: heroCard),
                            const SizedBox(width: 18),
                            Expanded(flex: 4, child: postureCard),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          heroCard,
                          const SizedBox(height: 18),
                          postureCard,
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

class _OnboardingPieceScene extends StatelessWidget {
  const _OnboardingPieceScene();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double heroHeight = constraints.maxHeight.clamp(220.0, 340.0);
        return SizedBox(
          height: heroHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.18),
                      ],
                    ),
                  ),
                  child: const SizedBox(height: 150),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 26,
                child: Opacity(
                  opacity: 0.44,
                  child: SizedBox(
                    height: 120,
                    child: Column(
                      children: List<Widget>.generate(4, (int rank) {
                        return Expanded(
                          child: Row(
                            children: List<Widget>.generate(6, (int file) {
                              final bool isLight = (rank + file).isEven;
                              return Expanded(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: isLight
                                        ? Colors.white.withValues(alpha: 0.20)
                                        : Colors.black.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
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
              ),
              Positioned(
                left: 4,
                bottom: 8,
                child: Text(
                  '♔',
                  style: TextStyle(
                    fontSize: heroHeight * 0.72,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.92),
                    shadows: <Shadow>[
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 24,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Text(
                    '♟',
                    style: TextStyle(
                      fontSize: heroHeight * 0.34,
                      height: 1,
                      color: Colors.black.withValues(alpha: 0.38),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
