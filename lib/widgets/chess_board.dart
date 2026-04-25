import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/chess_utils.dart';
import '../core/models.dart';

class ChessBoard extends StatefulWidget {
  const ChessBoard({
    super.key,
    required this.fen,
    required this.themePack,
    required this.flipped,
    required this.onSquareTap,
    this.selectedSquare,
    this.highlightedSquares = const <String>{},
    this.hintSquares = const <String>{},
    this.lastMove,
    this.lastMoveSquares = const <String>{},
  });

  final String fen;
  final AppThemePack themePack;
  final bool flipped;
  final ValueChanged<String> onSquareTap;
  final String? selectedSquare;
  final Set<String> highlightedSquares;
  final Set<String> hintSquares;
  final String? lastMove;
  final Set<String> lastMoveSquares;

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> with TickerProviderStateMixin {
  late final AnimationController _moveController;
  late final AnimationController _impactController;
  late final AnimationController _tapController;
  String? _animatedMove;
  String? _animatedPiece;
  String? _impactSquare;
  String? _tapSquare;

  @override
  void initState() {
    super.initState();
    _moveController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 280),
        )..addStatusListener((AnimationStatus status) {
          if (!mounted || status != AnimationStatus.completed) {
            return;
          }
          final String? completedMove = _animatedMove;
          setState(() {
            _impactSquare = _isMove(completedMove)
                ? completedMove!.substring(2, 4)
                : null;
            _animatedMove = null;
            _animatedPiece = null;
          });
          if (_impactSquare != null) {
            _impactController.forward(from: 0);
          }
        });
    _impactController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 360),
          )
          ..addListener(_rebuildForBoardEffect)
          ..addStatusListener((AnimationStatus status) {
            if (!mounted || status != AnimationStatus.completed) {
              return;
            }
            setState(() => _impactSquare = null);
          });
    _tapController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 190),
          )
          ..addListener(_rebuildForBoardEffect)
          ..addStatusListener((AnimationStatus status) {
            if (!mounted || status != AnimationStatus.completed) {
              return;
            }
            setState(() => _tapSquare = null);
          });
  }

  @override
  void didUpdateWidget(covariant ChessBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastMove != oldWidget.lastMove && _isMove(widget.lastMove)) {
      _startMoveAnimation();
    }
  }

  @override
  void dispose() {
    _moveController.dispose();
    _impactController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String?> board = boardMapFromFen(widget.fen);
    final List<int> ranks = widget.flipped
        ? <int>[1, 2, 3, 4, 5, 6, 7, 8]
        : <int>[8, 7, 6, 5, 4, 3, 2, 1];
    final List<String> files = widget.flipped
        ? <String>['h', 'g', 'f', 'e', 'd', 'c', 'b', 'a']
        : <String>['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    final Set<String> lastMoveSquares = _isMove(widget.lastMove)
        ? _squaresForMove(widget.lastMove!)
        : widget.lastMoveSquares;

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double boardSize = constraints.maxWidth;
          final double frame = (boardSize * 0.058).clamp(16.0, 24.0);
          final double innerSize = boardSize - (frame * 2);
          final double tileSize = innerSize / 8;
          final _BoardLayout layout = _BoardLayout(
            files: files,
            ranks: ranks,
            tileSize: tileSize,
          );

          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFF46301F),
                  Color(0xFF1D1510),
                  Color(0xFF604025),
                ],
              ),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.42),
                width: 1.4,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.34),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: widget.themePack.accent.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _WoodFramePainter(widget.themePack.accent),
                    ),
                  ),
                  ..._coordinateLabels(context, frame, tileSize, files, ranks),
                  Positioned(
                    left: frame,
                    top: frame,
                    width: innerSize,
                    height: innerSize,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.42),
                            width: 1.6,
                          ),
                        ),
                        child: Stack(
                          children: <Widget>[
                            ..._squareWidgets(board, layout, lastMoveSquares),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: <Color>[
                                        Colors.white.withValues(alpha: 0.12),
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IgnorePointer(
                              child: Stack(
                                children: <Widget>[
                                  ..._pieceWidgets(board, layout),
                                  if (_animatedMove != null &&
                                      _animatedPiece != null)
                                    _movingPiece(layout),
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
            ),
          );
        },
      ),
    );
  }

  List<Widget> _squareWidgets(
    Map<String, String?> board,
    _BoardLayout layout,
    Set<String> lastMoveSquares,
  ) {
    final List<Widget> widgets = <Widget>[];
    for (final int rank in layout.ranks) {
      for (final String file in layout.files) {
        final String square = '$file$rank';
        final String? piece = board[square];
        final bool light = (file.codeUnitAt(0) + rank).isEven;
        final bool selected = widget.selectedSquare == square;
        final bool target = widget.highlightedSquares.contains(square);
        final bool hint = widget.hintSquares.contains(square);
        final bool lastMove = lastMoveSquares.contains(square);
        final Offset offset = layout.offsetFor(square);

        widgets.add(
          Positioned(
            left: offset.dx,
            top: offset.dy,
            width: layout.tileSize,
            height: layout.tileSize,
            child: _BoardSquare(
              light: light,
              selected: selected,
              target: target,
              captureTarget: target && piece != null,
              hint: hint,
              lastMove: lastMove,
              impactValue: _impactSquare == square
                  ? _impactController.value
                  : 0,
              tapValue: _tapSquare == square ? _tapController.value : 0,
              accent: widget.themePack.accent,
              lightColor: widget.themePack.lightSquare,
              darkColor: widget.themePack.darkSquare,
              onTap: () => _handleSquareTap(square),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  List<Widget> _pieceWidgets(Map<String, String?> board, _BoardLayout layout) {
    final String? animatedDestination = _isMove(_animatedMove)
        ? _animatedMove!.substring(2, 4)
        : null;

    return board.entries
        .where((MapEntry<String, String?> entry) => entry.value != null)
        .where((MapEntry<String, String?> entry) {
          return entry.key != animatedDestination ||
              entry.value != _animatedPiece;
        })
        .map((MapEntry<String, String?> entry) {
          final Offset offset = layout.offsetFor(entry.key);
          return Positioned(
            left: offset.dx,
            top: offset.dy,
            width: layout.tileSize,
            height: layout.tileSize,
            child: _PieceGlyphView(
              piece: entry.value!,
              tileSize: layout.tileSize,
              selected: widget.selectedSquare == entry.key,
            ),
          );
        })
        .toList();
  }

  Widget _movingPiece(_BoardLayout layout) {
    final String move = _animatedMove!;
    final Offset from = layout.offsetFor(move.substring(0, 2));
    final Offset to = layout.offsetFor(move.substring(2, 4));

    return AnimatedBuilder(
      animation: _moveController,
      builder: (BuildContext context, Widget? child) {
        final double t = Curves.easeOutCubic.transform(_moveController.value);
        final Offset offset = Offset.lerp(from, to, t)!;
        final double lift = math.sin(t * math.pi) * (layout.tileSize * 0.18);
        return Positioned(
          left: offset.dx,
          top: offset.dy - lift,
          width: layout.tileSize,
          height: layout.tileSize,
          child: child!,
        );
      },
      child: _PieceGlyphView(
        piece: _animatedPiece!,
        tileSize: layout.tileSize,
        selected: false,
        moving: true,
      ),
    );
  }

  List<Widget> _coordinateLabels(
    BuildContext context,
    double frame,
    double tileSize,
    List<String> files,
    List<int> ranks,
  ) {
    final TextStyle style = Theme.of(context).textTheme.labelSmall!.copyWith(
      color: const Color(0xFFF1D7A8).withValues(alpha: 0.74),
      fontWeight: FontWeight.w700,
      fontSize: 9,
      letterSpacing: 0.4,
    );
    final List<Widget> labels = <Widget>[];

    for (int i = 0; i < files.length; i++) {
      labels.add(
        Positioned(
          left: frame + (tileSize * i),
          bottom: 3,
          width: tileSize,
          child: Text(
            files[i].toUpperCase(),
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
      );
    }

    for (int i = 0; i < ranks.length; i++) {
      labels.add(
        Positioned(
          left: 5,
          top: frame + (tileSize * i) + (tileSize / 2) - 7,
          width: frame - 7,
          child: Text('$ranks[i]', textAlign: TextAlign.center, style: style),
        ),
      );
    }

    return labels;
  }

  void _startMoveAnimation() {
    final String move = widget.lastMove!;
    final Map<String, String?> board = boardMapFromFen(widget.fen);
    final String? piece = board[move.substring(2, 4)];
    if (piece == null) {
      return;
    }

    final int milliseconds = _moveDurationMillis(move);
    _moveController.duration = Duration(milliseconds: milliseconds);
    _impactController.stop();
    setState(() {
      _impactSquare = null;
      _animatedMove = move;
      _animatedPiece = piece;
    });
    _moveController.forward(from: 0);
  }

  void _handleSquareTap(String square) {
    setState(() => _tapSquare = square);
    _tapController.forward(from: 0);
    widget.onSquareTap(square);
  }

  void _rebuildForBoardEffect() {
    if (mounted) {
      setState(() {});
    }
  }

  int _moveDurationMillis(String move) {
    final Offset from = _squareVector(move.substring(0, 2));
    final Offset to = _squareVector(move.substring(2, 4));
    final double distance = (to - from).distance;
    return math.max(260, math.min(430, 215 + (distance * 42).round()));
  }

  Offset _squareVector(String square) {
    final int file = square.codeUnitAt(0) - 97;
    final int rank = int.parse(square.substring(1, 2));
    return Offset(file.toDouble(), rank.toDouble());
  }

  bool _isMove(String? move) => move != null && move.length >= 4;

  Set<String> _squaresForMove(String move) {
    return <String>{move.substring(0, 2), move.substring(2, 4)};
  }
}

class _BoardSquare extends StatelessWidget {
  const _BoardSquare({
    required this.light,
    required this.selected,
    required this.target,
    required this.captureTarget,
    required this.hint,
    required this.lastMove,
    required this.impactValue,
    required this.tapValue,
    required this.accent,
    required this.lightColor,
    required this.darkColor,
    required this.onTap,
  });

  final bool light;
  final bool selected;
  final bool target;
  final bool captureTarget;
  final bool hint;
  final bool lastMove;
  final double impactValue;
  final double tapValue;
  final Color accent;
  final Color lightColor;
  final Color darkColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color base = light
        ? Color.alphaBlend(Colors.white.withValues(alpha: 0.10), lightColor)
        : Color.alphaBlend(Colors.black.withValues(alpha: 0.08), darkColor);
    final Color color = _squareColor(base);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.alphaBlend(Colors.white.withValues(alpha: 0.14), color),
              color,
              Color.alphaBlend(Colors.black.withValues(alpha: 0.10), color),
            ],
          ),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            left: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            right: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
            bottom: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: light ? 0.03 : 0.10),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _SquareTexturePainter(
                    light: light,
                    accent: accent,
                    active: selected || hint || lastMove,
                    tapValue: tapValue,
                    impactValue: impactValue,
                  ),
                ),
              ),
            ),
            if (lastMove)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.42),
                        width: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
            if (target)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.72, end: 1),
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutBack,
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 130),
                  width: captureTarget ? 40 : 15,
                  height: captureTarget ? 40 : 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: captureTarget
                        ? Colors.transparent
                        : accent.withValues(alpha: 0.80),
                    border: captureTarget
                        ? Border.all(color: accent, width: 2.4)
                        : null,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: accent.withValues(alpha: 0.34),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            if (selected)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: accent, width: 2.2),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: accent.withValues(alpha: 0.36),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ),
              ),
            if (impactValue > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ImpactRingPainter(
                      progress: impactValue,
                      accent: accent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _squareColor(Color base) {
    if (selected) {
      return Color.alphaBlend(accent.withValues(alpha: 0.38), base);
    }
    if (hint) {
      return Color.alphaBlend(accent.withValues(alpha: 0.30), base);
    }
    if (lastMove) {
      return Color.alphaBlend(accent.withValues(alpha: 0.17), base);
    }
    return base;
  }
}

class _PieceGlyphView extends StatelessWidget {
  const _PieceGlyphView({
    required this.piece,
    required this.tileSize,
    required this.selected,
    this.moving = false,
  });

  final String piece;
  final double tileSize;
  final bool selected;
  final bool moving;

  @override
  Widget build(BuildContext context) {
    final bool white = isWhitePiece(piece);
    final String glyph = _solidPieceGlyph(piece);
    final double size = tileSize * 0.78;
    final Color stroke = white
        ? const Color(0xFF6F512C).withValues(alpha: 0.70)
        : const Color(0xFFE8C47F).withValues(alpha: 0.30);
    final Color depth = white
        ? const Color(0xFFB8843F)
        : const Color(0xFF050403);
    final List<Color> material = white
        ? const <Color>[Color(0xFFFFFFFF), Color(0xFFFFE9B8), Color(0xFFE3A84F)]
        : const <Color>[
            Color(0xFF615247),
            Color(0xFF17110D),
            Color(0xFF030202),
          ];

    return AnimatedScale(
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutBack,
      scale: moving
          ? 1.13
          : selected
          ? 1.08
          : 1,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(moving ? -0.10 : -0.035),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform.translate(
              offset: Offset(0, tileSize * 0.10),
              child: Container(
                width: tileSize * (moving ? 0.54 : 0.48),
                height: tileSize * 0.17,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: white ? 0.22 : 0.34),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: moving ? 0.36 : 0.24,
                      ),
                      blurRadius: moving ? 14 : 9,
                    ),
                  ],
                ),
              ),
            ),
            for (int i = 5; i >= 1; i--)
              Transform.translate(
                offset: Offset(0, i * 0.72),
                child: Text(
                  glyph,
                  style: TextStyle(
                    fontSize: size,
                    height: 1,
                    fontFamily: 'serif',
                    color: depth.withValues(alpha: white ? 0.42 : 0.64),
                  ),
                ),
              ),
            Text(
              glyph,
              style: TextStyle(
                fontSize: size,
                height: 1,
                fontFamily: 'serif',
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = white ? 2.2 : 1.7
                  ..color = stroke,
              ),
            ),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: material,
                  stops: const <double>[0, 0.48, 1],
                ).createShader(bounds);
              },
              child: Text(
                glyph,
                style: TextStyle(
                  fontSize: size,
                  height: 1,
                  fontFamily: 'serif',
                  color: Colors.white,
                  shadows: <Shadow>[
                    Shadow(
                      color: Colors.black.withValues(
                        alpha: white ? 0.26 : 0.44,
                      ),
                      blurRadius: moving ? 12 : 8,
                      offset: Offset(0, moving ? 6 : 4),
                    ),
                  ],
                ),
              ),
            ),
            if (white)
              Transform.translate(
                offset: Offset(-tileSize * 0.045, -tileSize * 0.055),
                child: Text(
                  glyph,
                  style: TextStyle(
                    fontSize: size * 0.985,
                    height: 1,
                    fontFamily: 'serif',
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _solidPieceGlyph(String piece) {
    switch (piece.toLowerCase()) {
      case 'k':
        return String.fromCharCode(0x265A);
      case 'q':
        return String.fromCharCode(0x265B);
      case 'r':
        return String.fromCharCode(0x265C);
      case 'b':
        return String.fromCharCode(0x265D);
      case 'n':
        return String.fromCharCode(0x265E);
      case 'p':
        return String.fromCharCode(0x265F);
    }
    return pieceGlyph(piece);
  }
}

class _BoardLayout {
  const _BoardLayout({
    required this.files,
    required this.ranks,
    required this.tileSize,
  });

  final List<String> files;
  final List<int> ranks;
  final double tileSize;

  Offset offsetFor(String square) {
    final String file = square.substring(0, 1);
    final int rank = int.parse(square.substring(1, 2));
    final int col = files.indexOf(file);
    final int row = ranks.indexOf(rank);
    return Offset(col * tileSize, row * tileSize);
  }
}

class _WoodFramePainter extends CustomPainter {
  const _WoodFramePainter(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = const Color(0xFFF1D7A8).withValues(alpha: 0.10);
    final Paint warm = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accent.withValues(alpha: 0.10);

    for (int i = 0; i < 13; i++) {
      final double y = size.height * (0.08 + i * 0.07);
      final Path path = Path()
        ..moveTo(-12, y)
        ..cubicTo(
          size.width * 0.24,
          y + math.sin(i) * 14,
          size.width * 0.68,
          y - math.cos(i) * 16,
          size.width + 12,
          y + math.sin(i * 0.7) * 10,
        );
      canvas.drawPath(path, i.isEven ? grain : warm);
    }

    final Paint innerShadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = Colors.black.withValues(alpha: 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(20),
      ).deflate(4),
      innerShadow,
    );
  }

  @override
  bool shouldRepaint(covariant _WoodFramePainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

class _SquareTexturePainter extends CustomPainter {
  const _SquareTexturePainter({
    required this.light,
    required this.accent,
    required this.active,
    required this.tapValue,
    required this.impactValue,
  });

  final bool light;
  final Color accent;
  final bool active;
  final double tapValue;
  final double impactValue;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint vein = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = (light ? Colors.white : Colors.black).withValues(
        alpha: active ? 0.12 : 0.07,
      );

    for (int i = 0; i < 3; i++) {
      final double y = size.height * (0.24 + i * 0.23);
      canvas.drawLine(
        Offset(size.width * 0.10, y),
        Offset(size.width * 0.90, y + math.sin(i + size.width) * 2),
        vein,
      );
    }

    if (tapValue > 0) {
      final double fade = 1 - tapValue;
      final Paint tap = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: <Color>[
            accent.withValues(alpha: 0.18 * fade),
            accent.withValues(alpha: 0.02 * fade),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, tap);
    }

    if (impactValue > 0) {
      final double fade = 1 - impactValue;
      final Paint glow = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: <Color>[
            accent.withValues(alpha: 0.16 * fade),
            accent.withValues(alpha: 0.04 * fade),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, glow);
    }
  }

  @override
  bool shouldRepaint(covariant _SquareTexturePainter oldDelegate) {
    return oldDelegate.light != light ||
        oldDelegate.accent != accent ||
        oldDelegate.active != active ||
        oldDelegate.tapValue != tapValue ||
        oldDelegate.impactValue != impactValue;
  }
}

class _ImpactRingPainter extends CustomPainter {
  const _ImpactRingPainter({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double fade = 1 - progress;
    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * fade
      ..color = accent.withValues(alpha: 0.42 * fade);
    final Paint spark = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.20 * fade);

    canvas.drawCircle(center, size.width * (0.18 + progress * 0.42), ring);
    for (int i = 0; i < 6; i++) {
      final double angle = (math.pi * 2 / 6) * i;
      final double radius = size.width * (0.22 + progress * 0.30);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        1.2 + (1 - progress),
        spark,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ImpactRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}
