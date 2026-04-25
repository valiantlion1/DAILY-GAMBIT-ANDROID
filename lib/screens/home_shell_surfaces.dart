part of 'home_shell.dart';

class _RefColor {
  static const Color paper = Color(0xFFF5EFE3);
  static const Color ink = Color(0xFF241E18);
  static const Color muted = Color(0xFF7B7168);
  static const Color line = Color(0x1F241E18);
  static const Color gold = Color(0xFFC1924F);
  static const Color goldDark = Color(0xFF946833);
  static const Color match = Color(0xFF181612);
  static const Color matchPanel = Color(0xFF27221C);
  static const Color reward = Color(0xFF14281C);
}

class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop({required this.theme});

  final AppThemePack theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFFBF7EF),
            Color(0xFFF2E8D9),
            Color(0xFFE4D7C5),
          ],
        ),
      ),
      child: CustomPaint(painter: _MarblePainter(theme.accent)),
    );
  }
}

class _MarblePainter extends CustomPainter {
  const _MarblePainter(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint vein = Paint()
      ..color = const Color(0xFFB7A993).withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final Paint warm = Paint()
      ..color = accent.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    for (int i = 0; i < 7; i++) {
      final double y = size.height * (0.08 + (i * 0.14));
      final Path path = Path()
        ..moveTo(-24, y)
        ..cubicTo(
          size.width * 0.22,
          y - 42,
          size.width * 0.58,
          y + 38,
          size.width + 24,
          y - 18,
        );
      canvas.drawPath(path, i.isEven ? vein : warm);
    }
  }

  @override
  bool shouldRepaint(covariant _MarblePainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

class _PhonePage extends StatelessWidget {
  const _PhonePage({
    required this.child,
    this.backgroundColor = _RefColor.paper,
    this.bottomPadding = 96,
    this.scroll = true,
  });

  final Widget child;
  final Color backgroundColor;
  final double bottomPadding;
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    final Widget content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, bottomPadding),
          child: child,
        ),
      ),
    );

    return ColoredBox(
      color: backgroundColor,
      child: scroll ? SingleChildScrollView(child: content) : content,
    );
  }
}

class _ReferenceTopBar extends StatelessWidget {
  const _ReferenceTopBar({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.dark = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color color = dark ? Colors.white : _RefColor.ink;
    return SizedBox(
      height: 50,
      child: Row(
        children: <Widget>[
          SizedBox(width: 42, child: leading ?? const SizedBox.shrink()),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: color, fontSize: 18),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 42, child: trailing ?? const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({required this.icon, required this.onTap, this.dark = false});

  final IconData icon;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dark ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 19,
            color: dark ? Colors.white : _RefColor.ink,
          ),
        ),
      ),
    );
  }
}

class _SoftPanel extends StatelessWidget {
  const _SoftPanel({
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.color,
    this.borderColor,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color ?? Colors.white.withValues(alpha: 0.48),
        border: Border.all(color: borderColor ?? _RefColor.line),
        boxShadow: shadow
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.055),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({
    required this.label,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.compact = false,
  });

  final String label;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[_RefColor.gold, _RefColor.goldDark],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: _RefColor.goldDark.withValues(alpha: 0.20),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            height: compact ? 46 : 66,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, color: Colors.white, size: 19),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: icon == null
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white, fontSize: 15),
                        ),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.78),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (icon == null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.theme,
    required this.selectedIndex,
    required this.onSelected,
  });

  final AppThemePack theme;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final List<_NavItem> items = <_NavItem>[
      const _NavItem(Icons.home_rounded, 'Home', 0),
      const _NavItem(Icons.extension_rounded, 'Puzzles', 2),
      const _NavItem(Icons.emoji_events_rounded, 'Play', 1),
      const _NavItem(Icons.shopping_cart_rounded, 'Shop', 3),
      const _NavItem(Icons.person_rounded, 'Profile', 4),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF9F4EA),
            border: Border.all(color: _RefColor.line),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            height: 64,
            child: Row(
              children: items.map((_NavItem item) {
                final bool selected = selectedIndex == item.index;
                return Expanded(
                  child: InkWell(
                    onTap: () => onSelected(item.index),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 160),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: selected ? theme.accent : _RefColor.muted,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            item.icon,
                            size: 20,
                            color: selected ? theme.accent : _RefColor.muted,
                          ),
                          const SizedBox(height: 4),
                          Text(item.label, maxLines: 1),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label, this.index);

  final IconData icon;
  final String label;
  final int index;
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
    return _SoftPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFFFFFAF0),
      borderColor: accent.withValues(alpha: 0.22),
      child: Row(
        children: <Widget>[
          Icon(Icons.info_outline_rounded, size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          _IconTap(icon: Icons.close_rounded, onTap: onClose),
        ],
      ),
    );
  }
}

class _PieceGlyph extends StatelessWidget {
  const _PieceGlyph({
    required this.codePoint,
    required this.size,
    required this.color,
    this.shadow = true,
  });

  final int codePoint;
  final double size;
  final Color color;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Text(
      String.fromCharCode(codePoint),
      style: TextStyle(
        fontSize: size,
        height: 1,
        color: color,
        fontFamily: 'serif',
        shadows: shadow
            ? <Shadow>[
                Shadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
    );
  }
}

class _FadeIn extends StatefulWidget {
  const _FadeIn({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _show = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      opacity: _show ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        offset: _show ? Offset.zero : const Offset(0, 0.015),
        child: widget.child,
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  const _SmallLabel(this.text, {this.color = _RefColor.muted});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
    );
  }
}
