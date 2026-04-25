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
  });

  final String fen;
  final AppThemePack themePack;
  final bool flipped;
  final ValueChanged<String> onSquareTap;
  final String? selectedSquare;
  final Set<String> highlightedSquares;
  final Set<String> hintSquares;

  @override
  Widget build(BuildContext context) {
    final Map<String, String?> board = boardMapFromFen(fen);
    final List<int> ranks = flipped
        ? <int>[1, 2, 3, 4, 5, 6, 7, 8]
        : <int>[8, 7, 6, 5, 4, 3, 2, 1];
    final List<String> files = flipped
        ? <String>['h', 'g', 'f', 'e', 'd', 'c', 'b', 'a']
        : <String>['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double boardSize = constraints.maxWidth;
        final double tileSize = boardSize / 8;

        return RepaintBoundary(
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    themePack.darkSquare.withValues(alpha: 0.96),
                    Color.alphaBlend(
                      themePack.darkSquare.withValues(alpha: 0.36),
                      const Color(0xFF1A1715),
                    ),
                    Color.alphaBlend(
                      themePack.lightSquare.withValues(alpha: 0.28),
                      themePack.darkSquare,
                    ),
                  ],
                ),
                border: Border.all(
                  color: themePack.lightSquare.withValues(alpha: 0.30),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: themePack.darkSquare.withValues(alpha: 0.24),
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: <Widget>[
                      Column(
                        children: ranks.map((int rank) {
                          return Expanded(
                            child: Row(
                              children: files.map((String file) {
                                final String square = '$file$rank';
                                final bool isLight =
                                    (file.codeUnitAt(0) + rank).isEven;
                                final String? piece = board[square];
                                final bool isSelected =
                                    square == selectedSquare;
                                final bool isHint = hintSquares.contains(
                                  square,
                                );
                                final bool isHighlighted = highlightedSquares
                                    .contains(square);

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => onSquareTap(square),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 140,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: <Color>[
                                            _squareColor(
                                              isLight: isLight,
                                              isSelected: isSelected,
                                              isHint: isHint,
                                            ),
                                            _squareColor(
                                              isLight: isLight,
                                              isSelected: isSelected,
                                              isHint: isHint,
                                            ).withValues(alpha: 0.92),
                                          ],
                                        ),
                                      ),
                                      child: Stack(
                                        children: <Widget>[
                                          if (isHighlighted)
                                            Center(
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 120,
                                                ),
                                                width:
                                                    tileSize *
                                                    (piece == null
                                                        ? 0.22
                                                        : 0.60),
                                                height:
                                                    tileSize *
                                                    (piece == null
                                                        ? 0.22
                                                        : 0.60),
                                                decoration: BoxDecoration(
                                                  color: piece == null
                                                      ? themePack.accent
                                                            .withValues(
                                                              alpha: 0.80,
                                                            )
                                                      : Colors.transparent,
                                                  border: piece == null
                                                      ? null
                                                      : Border.all(
                                                          color: themePack
                                                              .accent
                                                              .withValues(
                                                                alpha: 0.96,
                                                              ),
                                                          width: 2.8,
                                                        ),
                                                  shape: BoxShape.circle,
                                                  boxShadow: piece == null
                                                      ? <BoxShadow>[
                                                          BoxShadow(
                                                            color: themePack
                                                                .accent
                                                                .withValues(
                                                                  alpha: 0.28,
                                                                ),
                                                            blurRadius: 16,
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          if (piece != null)
                                            Center(
                                              child: AnimatedScale(
                                                duration: const Duration(
                                                  milliseconds: 120,
                                                ),
                                                scale: isSelected ? 1.08 : 1,
                                                child: Text(
                                                  pieceGlyph(piece),
                                                  style: TextStyle(
                                                    fontSize: tileSize * 0.62,
                                                    color: isWhitePiece(piece)
                                                        ? const Color(
                                                            0xFFFBF8F3,
                                                          )
                                                        : const Color(
                                                            0xFF1B1916,
                                                          ),
                                                    shadows: <Shadow>[
                                                      Shadow(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.16,
                                                            ),
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if ((rank == (flipped ? 8 : 1)) &&
                                              file != files.last)
                                            Positioned(
                                              bottom: 4,
                                              right: 6,
                                              child: Text(
                                                file,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: isLight
                                                          ? const Color(
                                                              0xFF43372D,
                                                            ).withValues(
                                                              alpha: 0.56,
                                                            )
                                                          : Colors.white
                                                                .withValues(
                                                                  alpha: 0.70,
                                                                ),
                                                    ),
                                              ),
                                            ),
                                          if (file == files.first)
                                            Positioned(
                                              top: 4,
                                              left: 6,
                                              child: Text(
                                                '$rank',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: isLight
                                                          ? const Color(
                                                              0xFF43372D,
                                                            ).withValues(
                                                              alpha: 0.56,
                                                            )
                                                          : Colors.white
                                                                .withValues(
                                                                  alpha: 0.70,
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
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  Colors.white.withValues(alpha: 0.10),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _squareColor({
    required bool isLight,
    required bool isSelected,
    required bool isHint,
  }) {
    if (isSelected) {
      return themePack.accent.withValues(alpha: 0.42);
    }
    if (isHint) {
      return themePack.accent.withValues(alpha: 0.24);
    }
    return isLight
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.06),
            themePack.lightSquare,
          )
        : Color.alphaBlend(
            Colors.black.withValues(alpha: 0.08),
            themePack.darkSquare,
          );
  }
}
