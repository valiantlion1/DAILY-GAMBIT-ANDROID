import 'package:flutter/material.dart';

import '../core/chess_utils.dart';
import '../core/models.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({
    super.key,
    required this.fen,
    required this.themePack,
    required this.flipped,
    required this.onSquareTap,
    this.selectedSquare,
    this.highlightedSquares = const <String>{},
    this.hintSquares = const <String>{},
    this.lastMoveSquares = const <String>{},
  });

  final String fen;
  final AppThemePack themePack;
  final bool flipped;
  final ValueChanged<String> onSquareTap;
  final String? selectedSquare;
  final Set<String> highlightedSquares;
  final Set<String> hintSquares;
  final Set<String> lastMoveSquares;

  @override
  Widget build(BuildContext context) {
    final Map<String, String?> board = boardMapFromFen(fen);
    final List<int> ranks = flipped
        ? <int>[1, 2, 3, 4, 5, 6, 7, 8]
        : <int>[8, 7, 6, 5, 4, 3, 2, 1];
    final List<String> files = flipped
        ? <String>['h', 'g', 'f', 'e', 'd', 'c', 'b', 'a']
        : <String>['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF201B16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.34)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double tileSize = constraints.maxWidth / 8;
                return Stack(
                  children: <Widget>[
                    Column(
                      children: ranks.map((int rank) {
                        return Expanded(
                          child: Row(
                            children: files.map((String file) {
                              final String square = '$file$rank';
                              final bool light =
                                  (file.codeUnitAt(0) + rank).isEven;
                              final String? piece = board[square];
                              final bool selected = selectedSquare == square;
                              final bool target = highlightedSquares.contains(
                                square,
                              );
                              final bool hint = hintSquares.contains(square);
                              final bool lastMove = lastMoveSquares.contains(
                                square,
                              );
                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => onSquareTap(square),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 110),
                                    curve: Curves.easeOut,
                                    decoration: BoxDecoration(
                                      color: _squareColor(
                                        light,
                                        selected,
                                        hint,
                                        lastMove,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        if (lastMove)
                                          Positioned.fill(
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 170,
                                              ),
                                              curve: Curves.easeOutCubic,
                                              margin: EdgeInsets.all(
                                                tileSize * 0.10,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: themePack.accent
                                                      .withValues(alpha: 0.48),
                                                  width: 1.4,
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (target)
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 110,
                                            ),
                                            width: piece == null
                                                ? tileSize * 0.22
                                                : tileSize * 0.64,
                                            height: piece == null
                                                ? tileSize * 0.22
                                                : tileSize * 0.64,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: piece == null
                                                  ? themePack.accent.withValues(
                                                      alpha: 0.78,
                                                    )
                                                  : Colors.transparent,
                                              border: piece == null
                                                  ? null
                                                  : Border.all(
                                                      color: themePack.accent,
                                                      width: 2.4,
                                                    ),
                                            ),
                                          ),
                                        if (piece != null)
                                          AnimatedScale(
                                            duration: const Duration(
                                              milliseconds: 120,
                                            ),
                                            scale: selected ? 1.08 : 1,
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 170,
                                              ),
                                              switchInCurve: Curves.easeOutBack,
                                              switchOutCurve: Curves.easeIn,
                                              transitionBuilder:
                                                  (
                                                    Widget child,
                                                    Animation<double> animation,
                                                  ) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: ScaleTransition(
                                                        scale: Tween<double>(
                                                          begin: 0.82,
                                                          end: 1,
                                                        ).animate(animation),
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                              child: Text(
                                                pieceGlyph(piece),
                                                key: ValueKey<String>(
                                                  '$square-$piece',
                                                ),
                                                style: TextStyle(
                                                  fontSize: tileSize * 0.68,
                                                  height: 1,
                                                  fontFamily: 'serif',
                                                  color: isWhitePiece(piece)
                                                      ? const Color(0xFFF9F3EA)
                                                      : const Color(0xFF17130F),
                                                  shadows: <Shadow>[
                                                    Shadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.24,
                                                          ),
                                                      blurRadius: 6,
                                                      offset: const Offset(
                                                        0,
                                                        3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (selected)
                                          Positioned.fill(
                                            child: IgnorePointer(
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: themePack.accent,
                                                    width: 2,
                                                  ),
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                      color: themePack.accent
                                                          .withValues(
                                                            alpha: 0.28,
                                                          ),
                                                      blurRadius: 12,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Colors.white.withValues(alpha: 0.08),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.12),
                              ],
                            ),
                          ),
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
    );
  }

  Color _squareColor(bool light, bool selected, bool hint, bool lastMove) {
    final Color base = light
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.08),
            themePack.lightSquare,
          )
        : Color.alphaBlend(
            Colors.black.withValues(alpha: 0.06),
            themePack.darkSquare,
          );
    if (selected) {
      return Color.alphaBlend(themePack.accent.withValues(alpha: 0.40), base);
    }
    if (hint) {
      return Color.alphaBlend(themePack.accent.withValues(alpha: 0.28), base);
    }
    if (lastMove) {
      return Color.alphaBlend(themePack.accent.withValues(alpha: 0.18), base);
    }
    return base;
  }
}
