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

        return AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: themePack.darkSquare.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: <Widget>[
                  Column(
                    children: ranks.map((int rank) {
                      return Expanded(
                        child: Row(
                          children: files.map((String file) {
                            final String square = '$file$rank';
                            final bool isLight = (file.codeUnitAt(0) + rank).isEven;
                            final String? piece = board[square];
                            final bool isSelected = square == selectedSquare;
                            final bool isHint = hintSquares.contains(square);
                            final bool isHighlighted =
                                highlightedSquares.contains(square);

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => onSquareTap(square),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? themePack.accent.withValues(alpha: 0.40)
                                        : isHint
                                            ? themePack.accent.withValues(alpha: 0.24)
                                            : isLight
                                                ? themePack.lightSquare
                                                : themePack.darkSquare,
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      if (isHighlighted)
                                        Center(
                                          child: Container(
                                            width: tileSize * 0.22,
                                            height: tileSize * 0.22,
                                            decoration: BoxDecoration(
                                              color: piece == null
                                                  ? themePack.accent.withValues(alpha: 0.78)
                                                  : Colors.transparent,
                                              border: piece == null
                                                  ? null
                                                  : Border.all(
                                                      color: themePack.accent
                                                          .withValues(alpha: 0.92),
                                                      width: 3,
                                                    ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      if (piece != null)
                                        Center(
                                          child: Text(
                                            pieceGlyph(piece),
                                            style: TextStyle(
                                              fontSize: tileSize * 0.66,
                                              color: isWhitePiece(piece)
                                                  ? const Color(0xFFF7F4EF)
                                                  : const Color(0xFF1E1B18),
                                              shadows: <Shadow>[
                                                Shadow(
                                                  color: Colors.black.withValues(alpha: 0.14),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
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
                                                  color: Colors.white.withValues(alpha: 0.68),
                                                  fontWeight: FontWeight.w700,
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
                                                  color: Colors.white.withValues(alpha: 0.68),
                                                  fontWeight: FontWeight.w700,
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
                              Colors.white.withValues(alpha: 0.07),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.06),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
