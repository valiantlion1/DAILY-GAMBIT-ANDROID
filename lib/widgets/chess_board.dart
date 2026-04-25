import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/chess_utils.dart';
import '../core/models.dart';

class _BoardRenderSpec {
  const _BoardRenderSpec({
    required this.quality,
    required this.motionScale,
    required this.minMoveMillis,
    required this.maxMoveMillis,
    required this.moveLift,
    required this.pieceScale,
    required this.pieceDepthLayers,
    required this.depthStep,
    required this.shadowBlur,
    required this.richPieceShaders,
    required this.enablePieceHighlights,
    required this.enableSquarePulses,
    required this.enableImpactEffects,
    required this.squareTextureLines,
    required this.frameGrainCount,
    required this.trayScratchCount,
    required this.impactSparkCount,
    required this.targetPulseMillis,
    required this.captureDropMillis,
    required this.captureTumbleTurns,
    required this.captureDropDistance,
    required this.captureBounce,
    required this.captureSidePush,
  });

  factory _BoardRenderSpec.from(GraphicsQuality quality) {
    switch (quality) {
      case GraphicsQuality.performance:
        return const _BoardRenderSpec(
          quality: GraphicsQuality.performance,
          motionScale: 0.82,
          minMoveMillis: 210,
          maxMoveMillis: 320,
          moveLift: 0.10,
          pieceScale: 0.73,
          pieceDepthLayers: 2,
          depthStep: 0.50,
          shadowBlur: 5,
          richPieceShaders: false,
          enablePieceHighlights: false,
          enableSquarePulses: false,
          enableImpactEffects: false,
          squareTextureLines: 1,
          frameGrainCount: 5,
          trayScratchCount: 2,
          impactSparkCount: 0,
          targetPulseMillis: 90,
          captureDropMillis: 190,
          captureTumbleTurns: 0.10,
          captureDropDistance: 0.42,
          captureBounce: 0.04,
          captureSidePush: 0.18,
        );
      case GraphicsQuality.balanced:
        return const _BoardRenderSpec(
          quality: GraphicsQuality.balanced,
          motionScale: 0.92,
          minMoveMillis: 230,
          maxMoveMillis: 360,
          moveLift: 0.13,
          pieceScale: 0.75,
          pieceDepthLayers: 3,
          depthStep: 0.58,
          shadowBlur: 7,
          richPieceShaders: true,
          enablePieceHighlights: false,
          enableSquarePulses: true,
          enableImpactEffects: true,
          squareTextureLines: 2,
          frameGrainCount: 9,
          trayScratchCount: 4,
          impactSparkCount: 3,
          targetPulseMillis: 120,
          captureDropMillis: 230,
          captureTumbleTurns: 0.16,
          captureDropDistance: 0.52,
          captureBounce: 0.05,
          captureSidePush: 0.22,
        );
      case GraphicsQuality.high:
        return const _BoardRenderSpec(
          quality: GraphicsQuality.high,
          motionScale: 1,
          minMoveMillis: 260,
          maxMoveMillis: 430,
          moveLift: 0.18,
          pieceScale: 0.78,
          pieceDepthLayers: 5,
          depthStep: 0.72,
          shadowBlur: 9,
          richPieceShaders: true,
          enablePieceHighlights: true,
          enableSquarePulses: true,
          enableImpactEffects: true,
          squareTextureLines: 3,
          frameGrainCount: 13,
          trayScratchCount: 7,
          impactSparkCount: 6,
          targetPulseMillis: 160,
          captureDropMillis: 270,
          captureTumbleTurns: 0.22,
          captureDropDistance: 0.60,
          captureBounce: 0.06,
          captureSidePush: 0.26,
        );
      case GraphicsQuality.ultra:
        return const _BoardRenderSpec(
          quality: GraphicsQuality.ultra,
          motionScale: 1.08,
          minMoveMillis: 285,
          maxMoveMillis: 500,
          moveLift: 0.22,
          pieceScale: 0.80,
          pieceDepthLayers: 7,
          depthStep: 0.82,
          shadowBlur: 12,
          richPieceShaders: true,
          enablePieceHighlights: true,
          enableSquarePulses: true,
          enableImpactEffects: true,
          squareTextureLines: 5,
          frameGrainCount: 18,
          trayScratchCount: 10,
          impactSparkCount: 10,
          targetPulseMillis: 190,
          captureDropMillis: 320,
          captureTumbleTurns: 0.28,
          captureDropDistance: 0.72,
          captureBounce: 0.07,
          captureSidePush: 0.32,
        );
    }
  }

  final GraphicsQuality quality;
  final double motionScale;
  final int minMoveMillis;
  final int maxMoveMillis;
  final double moveLift;
  final double pieceScale;
  final int pieceDepthLayers;
  final double depthStep;
  final double shadowBlur;
  final bool richPieceShaders;
  final bool enablePieceHighlights;
  final bool enableSquarePulses;
  final bool enableImpactEffects;
  final int squareTextureLines;
  final int frameGrainCount;
  final int trayScratchCount;
  final int impactSparkCount;
  final int targetPulseMillis;
  final int captureDropMillis;
  final double captureTumbleTurns;
  final double captureDropDistance;
  final double captureBounce;
  final double captureSidePush;
}

class ChessBoard extends StatefulWidget {
  const ChessBoard({
    super.key,
    required this.fen,
    required this.themePack,
    required this.flipped,
    required this.onSquareTap,
    this.graphicsQuality = GraphicsQuality.high,
    this.selectedSquare,
    this.highlightedSquares = const <String>{},
    this.hintSquares = const <String>{},
    this.lastMove,
    this.lastMoveSquares = const <String>{},
    this.capturedByWhite = const <String>[],
    this.capturedByBlack = const <String>[],
    this.lastCapturedPiece,
  });

  final String fen;
  final AppThemePack themePack;
  final bool flipped;
  final ValueChanged<String> onSquareTap;
  final GraphicsQuality graphicsQuality;
  final String? selectedSquare;
  final Set<String> highlightedSquares;
  final Set<String> hintSquares;
  final String? lastMove;
  final Set<String> lastMoveSquares;
  final List<String> capturedByWhite;
  final List<String> capturedByBlack;
  final String? lastCapturedPiece;

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
          duration: const Duration(milliseconds: 240),
        )..addStatusListener((AnimationStatus status) {
          if (!mounted || status != AnimationStatus.completed) {
            return;
          }
          setState(() => _impactSquare = null);
        });
    _tapController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 130),
        )..addStatusListener((AnimationStatus status) {
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
    final _BoardRenderSpec spec = _BoardRenderSpec.from(widget.graphicsQuality);
    final List<int> ranks = widget.flipped
        ? <int>[1, 2, 3, 4, 5, 6, 7, 8]
        : <int>[8, 7, 6, 5, 4, 3, 2, 1];
    final List<String> files = widget.flipped
        ? <String>['h', 'g', 'f', 'e', 'd', 'c', 'b', 'a']
        : <String>['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    final Set<String> lastMoveSquares = _isMove(widget.lastMove)
        ? _squaresForMove(widget.lastMove!)
        : widget.lastMoveSquares;

    return RepaintBoundary(
      child: AspectRatio(
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
                        painter: _WoodFramePainter(
                          widget.themePack.accent,
                          grainCount: spec.frameGrainCount,
                        ),
                      ),
                    ),
                    ..._capturedPileWidgets(context, frame, innerSize, spec),
                    ..._coordinateLabels(
                      context,
                      frame,
                      tileSize,
                      files,
                      ranks,
                    ),
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
                              ..._squareWidgets(
                                board,
                                layout,
                                lastMoveSquares,
                                spec,
                              ),
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
                                    ..._pieceWidgets(board, layout, spec),
                                    if (_animatedMove != null &&
                                        _animatedPiece != null)
                                      _movingPiece(layout, spec),
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
      ),
    );
  }

  List<Widget> _capturedPileWidgets(
    BuildContext context,
    double frame,
    double innerSize,
    _BoardRenderSpec spec,
  ) {
    final double trayHeight = math.max(18, frame - 6);
    return <Widget>[
      Positioned(
        left: frame + 6,
        top: 3,
        width: innerSize - 12,
        height: trayHeight,
        child: _CapturedPile(
          pieces: widget.capturedByBlack,
          accent: widget.themePack.accent,
          spec: spec,
          bottomSide: false,
          latestPiece:
              widget.capturedByBlack.isNotEmpty &&
                  widget.capturedByBlack.last == widget.lastCapturedPiece
              ? widget.lastCapturedPiece
              : null,
        ),
      ),
      Positioned(
        left: frame + 6,
        bottom: 3,
        width: innerSize - 12,
        height: trayHeight,
        child: _CapturedPile(
          pieces: widget.capturedByWhite,
          accent: widget.themePack.accent,
          spec: spec,
          bottomSide: true,
          latestPiece:
              widget.capturedByWhite.isNotEmpty &&
                  widget.capturedByWhite.last == widget.lastCapturedPiece
              ? widget.lastCapturedPiece
              : null,
        ),
      ),
    ];
  }

  List<Widget> _squareWidgets(
    Map<String, String?> board,
    _BoardLayout layout,
    Set<String> lastMoveSquares,
    _BoardRenderSpec spec,
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
              impactAnimation: _impactSquare == square
                  ? _impactController
                  : null,
              tapAnimation: _tapSquare == square ? _tapController : null,
              spec: spec,
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

  List<Widget> _pieceWidgets(
    Map<String, String?> board,
    _BoardLayout layout,
    _BoardRenderSpec spec,
  ) {
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
              spec: spec,
            ),
          );
        })
        .toList();
  }

  Widget _movingPiece(_BoardLayout layout, _BoardRenderSpec spec) {
    final String move = _animatedMove!;
    final Offset from = layout.offsetFor(move.substring(0, 2));
    final Offset to = layout.offsetFor(move.substring(2, 4));

    return AnimatedBuilder(
      animation: _moveController,
      builder: (BuildContext context, Widget? child) {
        final double t = Curves.easeOutCubic.transform(_moveController.value);
        final Offset offset = Offset.lerp(from, to, t)!;
        final double lift =
            math.sin(t * math.pi) * (layout.tileSize * spec.moveLift);
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
        spec: spec,
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

  int _moveDurationMillis(String move) {
    final _BoardRenderSpec spec = _BoardRenderSpec.from(widget.graphicsQuality);
    final Offset from = _squareVector(move.substring(0, 2));
    final Offset to = _squareVector(move.substring(2, 4));
    final double distance = (to - from).distance;
    final int base = 215 + (distance * 42).round();
    return (base * spec.motionScale).round().clamp(
      spec.minMoveMillis,
      spec.maxMoveMillis,
    );
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
    required this.impactAnimation,
    required this.tapAnimation,
    required this.spec,
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
  final Animation<double>? impactAnimation;
  final Animation<double>? tapAnimation;
  final _BoardRenderSpec spec;
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
                child: _SquareTextureLayer(
                  light: light,
                  accent: accent,
                  active: selected || hint || lastMove,
                  tapAnimation: spec.enableSquarePulses ? tapAnimation : null,
                  impactAnimation: spec.enableImpactEffects
                      ? impactAnimation
                      : null,
                  textureLines: spec.squareTextureLines,
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
                duration: Duration(milliseconds: spec.targetPulseMillis),
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
            if (impactAnimation != null && spec.enableImpactEffects)
              Positioned.fill(
                child: IgnorePointer(
                  child: _ImpactEffectLayer(
                    animation: impactAnimation!,
                    accent: accent,
                    sparkCount: spec.impactSparkCount,
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

class _SquareTextureLayer extends StatelessWidget {
  const _SquareTextureLayer({
    required this.light,
    required this.accent,
    required this.active,
    required this.textureLines,
    this.tapAnimation,
    this.impactAnimation,
  });

  final bool light;
  final Color accent;
  final bool active;
  final int textureLines;
  final Animation<double>? tapAnimation;
  final Animation<double>? impactAnimation;

  @override
  Widget build(BuildContext context) {
    final List<Animation<double>> animations = <Animation<double>>[
      if (tapAnimation != null) tapAnimation!,
      if (impactAnimation != null) impactAnimation!,
    ];

    Widget paintLayer() {
      return CustomPaint(
        painter: _SquareTexturePainter(
          light: light,
          accent: accent,
          active: active,
          tapValue: tapAnimation?.value ?? 0,
          impactValue: impactAnimation?.value ?? 0,
          textureLines: textureLines,
        ),
      );
    }

    if (animations.isEmpty) {
      return paintLayer();
    }

    return AnimatedBuilder(
      animation: Listenable.merge(animations),
      builder: (BuildContext context, Widget? child) => paintLayer(),
    );
  }
}

class _ImpactEffectLayer extends StatelessWidget {
  const _ImpactEffectLayer({
    required this.animation,
    required this.accent,
    required this.sparkCount,
  });

  final Animation<double> animation;
  final Color accent;
  final int sparkCount;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        if (animation.value <= 0) {
          return const SizedBox.shrink();
        }
        return CustomPaint(
          painter: _ImpactRingPainter(
            progress: animation.value,
            accent: accent,
            sparkCount: sparkCount,
          ),
        );
      },
    );
  }
}

class _CapturedPile extends StatelessWidget {
  const _CapturedPile({
    required this.pieces,
    required this.accent,
    required this.spec,
    required this.bottomSide,
    this.latestPiece,
  });

  final List<String> pieces;
  final Color accent;
  final _BoardRenderSpec spec;
  final bool bottomSide;
  final String? latestPiece;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double pieceSize = math.max(18, math.min(29, height * 1.18));
        final double step = pieces.length <= 1
            ? 0
            : math.min(
                pieceSize * 0.56,
                (width - pieceSize - 8) / math.max(1, pieces.length - 1),
              );

        return CustomPaint(
          painter: _CapturedTrayPainter(
            accent: accent,
            bottomSide: bottomSide,
            scratchCount: spec.trayScratchCount,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              for (int index = 0; index < pieces.length; index++)
                _capturedPiece(
                  piece: pieces[index],
                  index: index,
                  width: width,
                  height: height,
                  pieceSize: pieceSize,
                  step: step,
                  latest:
                      index == pieces.length - 1 &&
                      latestPiece == pieces[index],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _capturedPiece({
    required String piece,
    required int index,
    required double width,
    required double height,
    required double pieceSize,
    required double step,
    required bool latest,
  }) {
    final double direction = bottomSide ? 1 : -1;
    final double baseX = bottomSide
        ? 5 + (index * step)
        : width - pieceSize - 5 - (index * step);
    final double jitterX = math.sin((index + piece.codeUnitAt(0)) * 1.7) * 4.8;
    final double jitterY = math.cos((index + piece.codeUnitAt(0)) * 1.21) * 3.2;
    final double x = (baseX + jitterX).clamp(0, width - pieceSize);
    final double y = ((height - pieceSize) / 2 + jitterY).clamp(
      -pieceSize * 0.10,
      height - pieceSize * 0.62,
    );
    final double rotation =
        (math.sin((index + 2) * 1.31) * 0.58) + (bottomSide ? 0.10 : -0.10);

    return Positioned(
      left: x,
      top: y,
      width: pieceSize,
      height: pieceSize,
      child: _CapturedPieceToken(
        key: ValueKey<String>(
          '${bottomSide ? 'white' : 'black'}-$index-$piece',
        ),
        piece: piece,
        size: pieceSize,
        rotation: rotation,
        bottomSide: bottomSide,
        latest: latest,
        sidePush: direction,
        spec: spec,
      ),
    );
  }
}

class _CapturedPieceToken extends StatelessWidget {
  const _CapturedPieceToken({
    super.key,
    required this.piece,
    required this.size,
    required this.rotation,
    required this.bottomSide,
    required this.latest,
    required this.sidePush,
    required this.spec,
  });

  final String piece;
  final double size;
  final double rotation;
  final bool bottomSide;
  final bool latest;
  final double sidePush;
  final _BoardRenderSpec spec;

  @override
  Widget build(BuildContext context) {
    final Widget token = RepaintBoundary(
      child: _PieceGlyphView(
        piece: piece,
        tileSize: size * 1.18,
        selected: false,
        fallen: true,
        spec: spec,
      ),
    );

    if (!latest) {
      return Transform.rotate(
        angle: rotation,
        child: Opacity(opacity: 0.84, child: token),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: spec.captureDropMillis),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        final double fall = 1 - value;
        final double settle = Curves.easeOutCubic.transform(value);
        final double tumble =
            rotation + ((1 - settle) * sidePush * spec.captureTumbleTurns);
        final double dropY =
            fall *
                (bottomSide
                    ? -size * spec.captureDropDistance
                    : size * spec.captureDropDistance) -
            math.sin(value * math.pi) * size * spec.captureBounce;
        final double shoveX = fall * sidePush * size * spec.captureSidePush;
        final double squash = 0.92 + (settle * 0.08);

        return Transform.translate(
          offset: Offset(shoveX, dropY),
          child: Transform.scale(
            scale: squash,
            child: Transform.rotate(
              angle: tumble,
              child: Opacity(opacity: 0.70 + (settle * 0.28), child: child),
            ),
          ),
        );
      },
      child: token,
    );
  }
}

class _PieceGlyphView extends StatelessWidget {
  const _PieceGlyphView({
    required this.piece,
    required this.tileSize,
    required this.selected,
    required this.spec,
    this.moving = false,
    this.fallen = false,
  });

  final String piece;
  final double tileSize;
  final bool selected;
  final _BoardRenderSpec spec;
  final bool moving;
  final bool fallen;

  @override
  Widget build(BuildContext context) {
    final bool white = isWhitePiece(piece);
    final String glyph = _solidPieceGlyph(piece);
    final double size = tileSize * (fallen ? 0.70 : spec.pieceScale);
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
      scale: fallen
          ? 0.86
          : moving
          ? 1.13
          : selected
          ? 1.08
          : 1,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(
            fallen
                ? 0.18
                : moving
                ? -0.10
                : -0.035,
          ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform.translate(
              offset: Offset(0, tileSize * 0.10),
              child: Container(
                width:
                    tileSize *
                    (fallen
                        ? 0.58
                        : moving
                        ? 0.54
                        : 0.48),
                height: tileSize * (fallen ? 0.20 : 0.17),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: white ? 0.22 : 0.34),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: fallen
                            ? 0.32
                            : moving
                            ? 0.36
                            : 0.24,
                      ),
                      blurRadius: fallen
                          ? 7
                          : moving
                          ? 14
                          : 9,
                    ),
                  ],
                ),
              ),
            ),
            for (int i = spec.pieceDepthLayers; i >= 1; i--)
              Transform.translate(
                offset: Offset(0, i * spec.depthStep),
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
            if (spec.richPieceShaders)
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
                  style: _pieceTextStyle(
                    size: size,
                    color: Colors.white,
                    white: white,
                    moving: moving,
                    fallen: fallen,
                  ),
                ),
              )
            else
              Text(
                glyph,
                style: _pieceTextStyle(
                  size: size,
                  color: white
                      ? const Color(0xFFFFF3D1)
                      : const Color(0xFF17110D),
                  white: white,
                  moving: moving,
                  fallen: fallen,
                ),
              ),
            if (white && spec.enablePieceHighlights)
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

  TextStyle _pieceTextStyle({
    required double size,
    required Color color,
    required bool white,
    required bool moving,
    required bool fallen,
  }) {
    return TextStyle(
      fontSize: size,
      height: 1,
      fontFamily: 'serif',
      color: color,
      shadows: <Shadow>[
        Shadow(
          color: Colors.black.withValues(alpha: white ? 0.26 : 0.44),
          blurRadius: fallen
              ? spec.shadowBlur * 0.55
              : moving
              ? spec.shadowBlur * 1.25
              : spec.shadowBlur,
          offset: Offset(
            0,
            fallen
                ? 3
                : moving
                ? 6
                : 4,
          ),
        ),
      ],
    );
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
  const _WoodFramePainter(this.accent, {required this.grainCount});

  final Color accent;
  final int grainCount;

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

    for (int i = 0; i < grainCount; i++) {
      final double y = size.height * (0.08 + i * (0.84 / grainCount));
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
    return oldDelegate.accent != accent || oldDelegate.grainCount != grainCount;
  }
}

class _CapturedTrayPainter extends CustomPainter {
  const _CapturedTrayPainter({
    required this.accent,
    required this.bottomSide,
    required this.scratchCount,
  });

  final Color accent;
  final bool bottomSide;
  final int scratchCount;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect tray = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height * 0.45),
    );
    final Paint bed = Paint()
      ..shader = LinearGradient(
        begin: bottomSide ? Alignment.topLeft : Alignment.bottomRight,
        end: bottomSide ? Alignment.bottomRight : Alignment.topLeft,
        colors: <Color>[
          Colors.black.withValues(alpha: 0.18),
          const Color(0xFFF1D7A8).withValues(alpha: 0.06),
          Colors.black.withValues(alpha: 0.14),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(tray, bed);

    final Paint rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = accent.withValues(alpha: 0.18);
    canvas.drawRRect(tray.deflate(0.5), rim);

    final Paint scratch = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.12);
    for (int i = 0; i < scratchCount; i++) {
      final double x = size.width * (0.08 + i * (0.84 / scratchCount));
      final double y = size.height * (0.38 + math.sin(i * 1.4) * 0.16);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + size.width * 0.04, y + math.cos(i) * 2),
        scratch,
      );
    }

    final Paint dust = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withValues(alpha: 0.12);
    for (int i = 0; i < 10; i++) {
      final double x = size.width * (0.04 + i * 0.095);
      final double y = size.height * (0.56 + math.sin(i * 2.1) * 0.20);
      canvas.drawCircle(Offset(x, y), 0.8 + (i % 3) * 0.25, dust);
    }
  }

  @override
  bool shouldRepaint(covariant _CapturedTrayPainter oldDelegate) {
    return oldDelegate.accent != accent ||
        oldDelegate.bottomSide != bottomSide ||
        oldDelegate.scratchCount != scratchCount;
  }
}

class _SquareTexturePainter extends CustomPainter {
  const _SquareTexturePainter({
    required this.light,
    required this.accent,
    required this.active,
    required this.tapValue,
    required this.impactValue,
    required this.textureLines,
  });

  final bool light;
  final Color accent;
  final bool active;
  final double tapValue;
  final double impactValue;
  final int textureLines;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint vein = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = (light ? Colors.white : Colors.black).withValues(
        alpha: active ? 0.12 : 0.07,
      );

    for (int i = 0; i < textureLines; i++) {
      final double y = size.height * (0.18 + i * (0.64 / textureLines));
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
        oldDelegate.impactValue != impactValue ||
        oldDelegate.textureLines != textureLines;
  }
}

class _ImpactRingPainter extends CustomPainter {
  const _ImpactRingPainter({
    required this.progress,
    required this.accent,
    required this.sparkCount,
  });

  final double progress;
  final Color accent;
  final int sparkCount;

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
    for (int i = 0; i < sparkCount; i++) {
      final double angle = (math.pi * 2 / sparkCount) * i;
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
    return oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.sparkCount != sparkCount;
  }
}
