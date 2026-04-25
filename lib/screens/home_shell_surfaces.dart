part of 'home_shell.dart';

class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop({required this.theme});

  final AppThemePack theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.18, -0.92),
          radius: 1.28,
          colors: <Color>[
            Colors.white,
            theme.background,
            Color.alphaBlend(
              theme.accent.withValues(alpha: 0.08),
              theme.surface,
            ),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -90,
            right: -30,
            child: _GlowOrb(
              color: theme.accent.withValues(alpha: 0.18),
              size: 260,
            ),
          ),
          Positioned(
            top: 84,
            left: -14,
            child: _BackdropPieceSilhouette(
              glyph: '♔',
              color: theme.darkSquare.withValues(alpha: 0.08),
              size: 300,
              blurSigma: 2,
              angle: -0.08,
            ),
          ),
          Positioned(
            top: 190,
            right: 28,
            child: _BackdropPieceSilhouette(
              glyph: '♟',
              color: theme.darkSquare.withValues(alpha: 0.10),
              size: 180,
              blurSigma: 4,
              angle: 0.06,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BackdropBoardField(theme: theme),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

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
          gradient: RadialGradient(colors: <Color>[color, Colors.transparent]),
        ),
      ),
    );
  }
}

class _BackdropPieceSilhouette extends StatelessWidget {
  const _BackdropPieceSilhouette({
    required this.glyph,
    required this.color,
    required this.size,
    this.blurSigma = 0,
    this.angle = 0,
  });

  final String glyph;
  final Color color;
  final double size;
  final double blurSigma;
  final double angle;

  @override
  Widget build(BuildContext context) {
    Widget child = Transform.rotate(
      angle: angle,
      child: Text(
        glyph,
        style: TextStyle(
          fontSize: size,
          height: 1,
          color: color,
          fontFamily: 'serif',
        ),
      ),
    );
    if (blurSigma > 0) {
      child = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: child,
      );
    }
    return IgnorePointer(child: child);
  }
}

class _BackdropBoardField extends StatelessWidget {
  const _BackdropBoardField({required this.theme});

  final AppThemePack theme;

  @override
  Widget build(BuildContext context) {
    const int tiles = 8;
    return IgnorePointer(
      child: Opacity(
        opacity: 0.22,
        child: SizedBox(
          height: 220,
          child: Stack(
            children: <Widget>[
              Column(
                children: List<Widget>.generate(tiles, (int rank) {
                  return Expanded(
                    child: Row(
                      children: List<Widget>.generate(tiles, (int file) {
                        final bool isLight = (rank + file).isEven;
                        return Expanded(
                          child: ColoredBox(
                            color: isLight
                                ? theme.lightSquare.withValues(alpha: 0.72)
                                : theme.darkSquare.withValues(alpha: 0.56),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        theme.background,
                        Colors.transparent,
                        theme.background.withValues(alpha: 0.20),
                      ],
                      stops: const <double>[0.0, 0.42, 1.0],
                    ),
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

class _TopShellBar extends StatelessWidget {
  const _TopShellBar({required this.theme, required this.profile});

  final AppThemePack theme;
  final AppProfile profile;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      blurSigma: 16,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  theme.accent.withValues(alpha: 0.92),
                  theme.accent.withValues(alpha: 0.72),
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: theme.accent.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Daily Gambit',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  'One calm match. One clean return.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: <Widget>[
              _BadgePill(
                label: 'Streak ${profile.streakDays}',
                foreground: theme.darkSquare,
                background: theme.accent.withValues(alpha: 0.12),
              ),
              _BadgePill(
                label: profile.premiumUnlocked ? 'Pro unlocked' : 'Free tier',
                foreground: profile.premiumUnlocked
                    ? Colors.white
                    : theme.darkSquare,
                background: profile.premiumUnlocked
                    ? theme.darkSquare
                    : Colors.white.withValues(alpha: 0.75),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FloatingNavShell extends StatelessWidget {
  const _FloatingNavShell({required this.theme, required this.child});

  final AppThemePack theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.darkSquare.withValues(alpha: 0.08)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.darkSquare.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: ColoredBox(
            color: Colors.white.withValues(alpha: 0.88),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.blurSigma = 14,
    this.gradient,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blurSigma;
  final Gradient? gradient;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(28);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient:
                gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.90),
                    Colors.white.withValues(alpha: 0.74),
                  ],
                ),
            border: Border.all(
              color:
                  borderColor ??
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.26),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ShadCard(
      padding: padding,
      backgroundColor:
          backgroundColor ??
          Color.alphaBlend(
            Colors.white.withValues(alpha: 0.92),
            theme.colorScheme.surface,
          ),
      radius: BorderRadius.circular(28),
      border: ShadBorder.all(
        color: theme.colorScheme.outline.withValues(alpha: 0.22),
      ),
      shadows: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.045),
          blurRadius: 22,
          offset: const Offset(0, 12),
        ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Colors.white.withValues(alpha: 0.06),
              theme.colorScheme.surface.withValues(alpha: 0.16),
            ],
          ),
        ),
        child: child,
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
          constraints: const BoxConstraints(maxWidth: 1120),
          child: child,
        ),
      ),
    );
  }
}

class _RevealOnMount extends StatefulWidget {
  const _RevealOnMount({required this.child, this.delay = Duration.zero});

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
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : const Offset(0, 0.05),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 320),
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
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionEyebrow(label: title, accent: accent),
        const SizedBox(height: 10),
        Text(subtitle, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: accent, letterSpacing: 1.3),
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ShadBadge.raw(
      variant: ShadBadgeVariant.outline,
      backgroundColor: background,
      foregroundColor: foreground,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: foreground),
      ),
    );
  }
}

class _CompactFeaturePill extends StatelessWidget {
  const _CompactFeaturePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
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
    return _GlassPanel(
      blurSigma: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: accent.withValues(alpha: 0.22),
      child: Row(
        children: <Widget>[
          Icon(Icons.info_outline_rounded, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
          IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded)),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.caption,
    required this.accent,
    this.icon,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final String caption;
  final Color accent;
  final IconData? icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return _SurfaceCard(
      backgroundColor: emphasized
          ? accent.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.92),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: emphasized ? 38 : 30,
              color: const Color(0xFF1A1B1D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline_rounded, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
