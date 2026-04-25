import 'package:bishop/bishop.dart';
import 'package:intl/intl.dart';

Map<String, String?> boardMapFromFen(String fen) {
  final String boardSection = fen.split(' ').first;
  final List<String> ranks = boardSection.split('/');
  final Map<String, String?> board = <String, String?>{};
  for (int rankIndex = 0; rankIndex < ranks.length; rankIndex++) {
    final String rank = ranks[rankIndex];
    int fileIndex = 0;
    for (final String symbol in rank.split('')) {
      final int? emptySquares = int.tryParse(symbol);
      if (emptySquares != null) {
        for (int i = 0; i < emptySquares; i++) {
          board[_squareName(fileIndex, 8 - rankIndex)] = null;
          fileIndex++;
        }
      } else {
        board[_squareName(fileIndex, 8 - rankIndex)] = symbol;
        fileIndex++;
      }
    }
  }
  return board;
}

Map<String, Set<String>> targetsBySourceFromGame(Game game) {
  final Map<String, Set<String>> targets = <String, Set<String>>{};
  for (final Move move in game.generateLegalMoves()) {
    final String from = squareNameFromIndex(move.from);
    final String to = squareNameFromIndex(move.to);
    final Set<String> existing = targets[from] ?? <String>{};
    existing.add(to);
    targets[from] = existing;
  }
  return targets;
}

String squareNameFromIndex(int index) {
  final int file = index & 7;
  final int rank = 8 - (index >> 4);
  return _squareName(file, rank);
}

int indexFromSquareName(String square) {
  final int file = square.codeUnitAt(0) - 97;
  final int rank = int.parse(square[1]);
  return (8 - rank) * 16 + file;
}

String moveToCoordinateString(Move move) {
  return '${squareNameFromIndex(move.from)}${squareNameFromIndex(move.to)}';
}

String formattedDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

int dayOfYear(DateTime date) => int.parse(DateFormat('D').format(date));

String pieceGlyph(String piece) {
  switch (piece) {
    case 'K':
      return String.fromCharCode(0x2654);
    case 'Q':
      return String.fromCharCode(0x2655);
    case 'R':
      return String.fromCharCode(0x2656);
    case 'B':
      return String.fromCharCode(0x2657);
    case 'N':
      return String.fromCharCode(0x2658);
    case 'P':
      return String.fromCharCode(0x2659);
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
  return '';
}

bool isWhitePiece(String piece) => piece.toUpperCase() == piece;

String readableMove(String move) {
  if (move.length < 4) {
    return move;
  }
  return '${move.substring(0, 2)} -> ${move.substring(2, 4)}';
}

String _squareName(int file, int rank) {
  return '${String.fromCharCode(97 + file)}$rank';
}
