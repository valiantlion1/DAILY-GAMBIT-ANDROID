import 'dart:async';
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
    final bool showNav =
        viewState.selectedTabIndex == 0 ||
        viewState.selectedTabIndex == 3 ||
        viewState.selectedTabIndex == 4;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _AmbientBackdrop(theme: theme),
          SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: viewState.bannerMessage == null
                      ? const SizedBox.shrink()
                      : Padding(
                          key: ValueKey<String>(viewState.bannerMessage!),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 430),
                              child: _InlineBanner(
                                message: viewState.bannerMessage!,
                                accent: theme.accent,
                                onClose: controller.clearBanner,
                              ),
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
      bottomNavigationBar: showNav
          ? _BottomNav(
              theme: theme,
              selectedIndex: viewState.selectedTabIndex,
              onSelected: controller.switchTab,
            )
          : null,
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
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  child: Column(
                    children: <Widget>[
                      const Spacer(flex: 1),
                      _FadeIn(
                        child: Column(
                          children: <Widget>[
                            _PieceGlyph(
                              codePoint: 0x265B,
                              size: 26,
                              color: theme.accent,
                              shadow: false,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Daily\nGambit',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontSize: 42,
                                    height: 0.94,
                                    color: _RefColor.ink,
                                  ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Sharpen your mind.\nOne game, one day.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: _RefColor.muted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        flex: 6,
                        child: _FadeIn(
                          delay: const Duration(milliseconds: 70),
                          child: _OnboardingPieceScene(theme: theme),
                        ),
                      ),
                      const SizedBox(height: 26),
                      _FadeIn(
                        delay: const Duration(milliseconds: 120),
                        child: _GoldButton(
                          label: 'Begin Your Journey',
                          onTap: controller.completeOnboarding,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Already have an account? Sign in',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _RefColor.ink.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
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
  const _OnboardingPieceScene({required this.theme});

  final AppThemePack theme;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Positioned(
              left: -40,
              right: -40,
              bottom: 0,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(-0.76),
                child: SizedBox(
                  height: 180,
                  child: _PerspectiveBoard(theme: theme),
                ),
              ),
            ),
            Positioned(
              right: 42,
              bottom: 94,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 2.6, sigmaY: 2.6),
                child: _PieceGlyph(
                  codePoint: 0x265F,
                  size: 82,
                  color: const Color(0xFF191715).withValues(alpha: 0.50),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              child: _PieceGlyph(
                codePoint: 0x2654,
                size: 188,
                color: const Color(0xFFF8F1E6),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PerspectiveBoard extends StatelessWidget {
  const _PerspectiveBoard({required this.theme});

  final AppThemePack theme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: List<Widget>.generate(6, (int rank) {
          return Expanded(
            child: Row(
              children: List<Widget>.generate(6, (int file) {
                final bool light = (rank + file).isEven;
                return Expanded(
                  child: ColoredBox(
                    color: light
                        ? theme.lightSquare.withValues(alpha: 0.78)
                        : theme.darkSquare.withValues(alpha: 0.40),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
