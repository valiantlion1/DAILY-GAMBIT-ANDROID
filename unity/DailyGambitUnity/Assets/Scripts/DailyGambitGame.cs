using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace DailyGambit
{
    public sealed class DailyGambitGame : MonoBehaviour
    {
        private const int BoardSize = 8;
        private const float BoardCenter = 3.5f;
        private const float BoardSurfaceY = 0.08f;
        private const float CameraHeight = 12.0f;
        private readonly char[,] board = new char[BoardSize, BoardSize];
        private readonly Dictionary<Vector2Int, GameObject> pieceObjects = new();
        private readonly Dictionary<Vector2Int, Renderer> tileRenderers = new();
        private readonly List<GameObject> moveMarkers = new();
        private readonly List<GameObject> capturedObjects = new();
        private readonly System.Random random = new(42);

        private static DailyGambitGame instance;

        private Camera mainCamera;
        private Rect safeBoardRect;
        private GUIStyle safeStatusStyle;
        private GUIStyle safePieceStyle;
        private GUIStyle safeFooterStyle;
        private Material lightSquare;
        private Material darkSquare;
        private Material selectedSquare;
        private Material moveDot;
        private Material captureDot;
        private Material ivoryPiece;
        private Material blackPiece;
        private Material goldTrim;
        private Material woodFrame;
        private Material boardCore;
        private Material boardEdge;
        private Material feltTray;
        private Material feltDark;
        private Material shadowMat;
        private Material labelMat;

        private Vector2Int? selected;
        private List<ChessMove> selectedMoves = new();
        private bool whiteToMove = true;
        private bool animating;
        private bool initialized;
        private bool useSafeUiBoard = true;
        private bool whiteKingMoved;
        private bool blackKingMoved;
        private bool whiteKingsideRookMoved;
        private bool whiteQueensideRookMoved;
        private bool blackKingsideRookMoved;
        private bool blackQueensideRookMoved;
        private Vector2Int? enPassantSquare;
        private int halfMoveClock;
        private int fullMoveNumber = 1;
        private int capturedByWhite;
        private int capturedByBlack;
        private string status = "Your move";
        private string bootError;
        private GUIStyle statusStyle;
        private int lastScreenWidth;
        private int lastScreenHeight;

        [SerializeField] private int aiDepth = 3;
        [SerializeField] private float moveSeconds = 0.20f;
        [SerializeField] private float boardLift = 0.04f;

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        private static void EnsureRuntimeExists()
        {
            if (FindFirstObjectByType<DailyGambitGame>() != null)
            {
                return;
            }

            GameObject runtime = new("Daily Gambit Runtime");
            runtime.AddComponent<DailyGambitGame>();
        }

        private void Awake()
        {
            if (instance != null && instance != this)
            {
                Destroy(gameObject);
                return;
            }

            instance = this;
            try
            {
                Application.targetFrameRate = 120;
                Screen.sleepTimeout = SleepTimeout.NeverSleep;
                QualitySettings.vSyncCount = 0;
                QualitySettings.antiAliasing = 4;
                if (useSafeUiBoard)
                {
                    CreateSafeUiBoard();
                }
                else
                {
                    CreateSceneRig();
                    CreateMaterials();
                    CreateBoard();
                }
                ResetGame();
                initialized = true;
            }
            catch (Exception ex)
            {
                bootError = ex.Message;
                Debug.LogException(ex);
                CreateEmergencyView();
            }
        }

        private void Update()
        {
            if (!initialized)
            {
                return;
            }

            if (useSafeUiBoard)
            {
                RefreshUiLayout();
            }
            else
            {
                RefreshCameraForScreen();
            }

            if (Input.GetKeyDown(KeyCode.R))
            {
                ResetGame();
            }

            if (animating || !whiteToMove)
            {
                return;
            }

            if (!useSafeUiBoard && Input.GetMouseButtonUp(0))
            {
                TrySelectFromScreen(Input.mousePosition);
            }

            if (!useSafeUiBoard && Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Ended)
            {
                TrySelectFromScreen(Input.GetTouch(0).position);
            }
        }

        private void OnGUI()
        {
            if (useSafeUiBoard)
            {
                DrawSafeUiBoard();
                return;
            }

            statusStyle ??= CreateStatusStyle();
            float panelWidth = Mathf.Clamp(Screen.width - 36f, 220f, 420f);
            Rect panel = new(18f, 18f, panelWidth, 54f);
            Color oldColor = GUI.color;
            GUI.color = new Color(0.07f, 0.045f, 0.028f, 0.78f);
            GUI.DrawTexture(panel, Texture2D.whiteTexture);
            GUI.color = oldColor;
            string message = string.IsNullOrEmpty(bootError) ? status.ToUpperInvariant() : $"BOOT ERROR: {bootError}";
            GUI.Label(new Rect(panel.x + 18f, panel.y + 13f, panel.width - 36f, panel.height - 16f), message, statusStyle);
        }

        private static GUIStyle CreateStatusStyle()
        {
            GUIStyle style = new(GUI.skin.label)
            {
                alignment = TextAnchor.MiddleLeft,
                fontSize = 20,
                fontStyle = FontStyle.Bold
            };
            style.normal.textColor = new Color(1.0f, 0.84f, 0.48f);
            return style;
        }

        private void DrawSafeUiBoard()
        {
            RefreshUiLayout();
            EnsureSafeGuiStyles();

            Color oldColor = GUI.color;
            GUI.color = new Color(0.035f, 0.027f, 0.022f, 1f);
            GUI.DrawTexture(new Rect(0f, 0f, Screen.width, Screen.height), Texture2D.whiteTexture);

            string message = string.IsNullOrEmpty(bootError)
                ? status.ToUpperInvariant()
                : $"BOOT ERROR: {bootError}";
            Rect statusRect = new(18f, Mathf.Max(18f, safeBoardRect.y - 86f), Screen.width - 36f, 58f);
            GUI.color = new Color(0.09f, 0.055f, 0.032f, 0.95f);
            GUI.DrawTexture(statusRect, Texture2D.whiteTexture);
            GUI.color = Color.white;
            GUI.Label(statusRect, message, safeStatusStyle);

            GUI.color = new Color(0.13f, 0.075f, 0.04f, 1f);
            GUI.DrawTexture(new Rect(safeBoardRect.x - 8f, safeBoardRect.y - 8f, safeBoardRect.width + 16f, safeBoardRect.height + 16f), Texture2D.whiteTexture);

            float cell = safeBoardRect.width / BoardSize;
            safePieceStyle.fontSize = Mathf.RoundToInt(Mathf.Clamp(cell * 0.50f, 28f, 84f));
            for (int rank = BoardSize - 1; rank >= 0; rank--)
            {
                for (int file = 0; file < BoardSize; file++)
                {
                    Vector2Int square = new(file, rank);
                    Rect squareRect = new(
                        safeBoardRect.x + file * cell,
                        safeBoardRect.y + (BoardSize - 1 - rank) * cell,
                        cell,
                        cell);

                    GUI.color = SafeSquareColor(square);
                    GUI.DrawTexture(squareRect, Texture2D.whiteTexture);

                    char piece = board[file, rank];
                    if (piece != '\0')
                    {
                        Rect tokenRect = Inset(squareRect, cell * 0.14f);
                        GUI.color = IsWhite(piece)
                            ? new Color(0.95f, 0.81f, 0.53f, 1f)
                            : new Color(0.055f, 0.043f, 0.036f, 1f);
                        GUI.DrawTexture(tokenRect, Texture2D.whiteTexture);

                        safePieceStyle.normal.textColor = IsWhite(piece)
                            ? new Color(0.08f, 0.05f, 0.028f)
                            : new Color(1.0f, 0.77f, 0.36f);
                        GUI.Label(squareRect, PieceGlyph(piece), safePieceStyle);
                    }

                    GUI.color = new Color(1f, 1f, 1f, 0f);
                    if (GUI.Button(squareRect, GUIContent.none, GUIStyle.none))
                    {
                        HandleSquare(square);
                    }
                }
            }

            GUI.color = new Color(0.86f, 0.66f, 0.38f, 1f);
            string footer = whiteToMove ? "Tap a white piece, then tap a target square" : "Engine is thinking";
            GUI.Label(new Rect(18f, safeBoardRect.yMax + 18f, Screen.width - 36f, 54f), footer, safeFooterStyle);
            GUI.color = oldColor;
        }

        private void EnsureSafeGuiStyles()
        {
            safeStatusStyle ??= new GUIStyle(GUI.skin.label)
            {
                alignment = TextAnchor.MiddleCenter,
                fontStyle = FontStyle.Bold,
                fontSize = Mathf.RoundToInt(Mathf.Clamp(Screen.width * 0.044f, 26f, 44f))
            };
            safeStatusStyle.normal.textColor = new Color(1f, 0.78f, 0.38f);

            safePieceStyle ??= new GUIStyle(GUI.skin.label)
            {
                alignment = TextAnchor.MiddleCenter,
                fontStyle = FontStyle.Bold
            };

            safeFooterStyle ??= new GUIStyle(GUI.skin.label)
            {
                alignment = TextAnchor.MiddleCenter,
                fontSize = Mathf.RoundToInt(Mathf.Clamp(Screen.width * 0.030f, 20f, 32f))
            };
            safeFooterStyle.normal.textColor = new Color(0.86f, 0.66f, 0.38f);
        }

        private Color SafeSquareColor(Vector2Int square)
        {
            bool light = ((square.x + square.y) & 1) != 0;
            Color color = light ? new Color(0.74f, 0.58f, 0.35f) : new Color(0.32f, 0.18f, 0.10f);
            if (selected.HasValue && selected.Value == square)
            {
                return new Color(0.98f, 0.58f, 0.14f);
            }

            ChessMove? move = selectedMoves.Find(m => m.To == square);
            if (move.HasValue)
            {
                bool capture = move.Value.EnPassant || board[square.x, square.y] != '\0';
                return capture ? new Color(0.72f, 0.20f, 0.13f) : new Color(0.46f, 0.56f, 0.25f);
            }

            return color;
        }

        private static Rect Inset(Rect rect, float amount)
        {
            return new Rect(rect.x + amount, rect.y + amount, rect.width - amount * 2f, rect.height - amount * 2f);
        }

        private void TrySelectFromScreen(Vector3 screenPosition)
        {
            Camera cam = mainCamera != null ? mainCamera : Camera.main;
            if (cam == null)
            {
                return;
            }

            Ray ray = cam.ScreenPointToRay(screenPosition);
            if (Physics.Raycast(ray, out RaycastHit hit, 100f))
            {
                SquareMarker marker = hit.collider.GetComponent<SquareMarker>();
                if (marker != null)
                {
                    HandleSquare(new Vector2Int(marker.File, marker.Rank));
                    return;
                }
            }

            if (TryScreenToBoardSquare(ray, out Vector2Int square))
            {
                HandleSquare(square);
            }
        }

        private static bool TryScreenToBoardSquare(Ray ray, out Vector2Int square)
        {
            Plane boardPlane = new(Vector3.up, new Vector3(0f, BoardSurfaceY, 0f));
            if (boardPlane.Raycast(ray, out float distance))
            {
                Vector3 point = ray.GetPoint(distance);
                int file = Mathf.FloorToInt(point.x + 0.5f);
                int rank = Mathf.FloorToInt(point.z + 0.5f);
                square = new Vector2Int(file, rank);
                return InBoard(square);
            }

            square = default;
            return false;
        }

        private void HandleSquare(Vector2Int square)
        {
            if (animating || !whiteToMove)
            {
                return;
            }

            char piece = board[square.x, square.y];
            if (selected.HasValue)
            {
                ChessMove? move = selectedMoves.Find(m => m.To == square);
                if (move.HasValue)
                {
                    StartCoroutine(PlayMove(move.Value, true));
                    return;
                }
            }

            ClearMoveMarkers();
            selected = null;
            selectedMoves.Clear();

            if (piece == '\0' || !IsWhite(piece))
            {
                status = "Pick a white piece";
                RefreshTileSelection();
                return;
            }

            selected = square;
            selectedMoves = GenerateLegalMoves(true).FindAll(m => m.From == square);
            status = selectedMoves.Count == 0 ? "No legal move there" : "Choose a target";
            RefreshTileSelection();
            DrawMoveMarkers(selectedMoves);
        }

        private IEnumerator PlayMove(ChessMove move, bool playerMove)
        {
            animating = true;
            ClearMoveMarkers();
            selected = null;
            selectedMoves.Clear();
            RefreshTileSelection();

            MoveResult result = ApplyMoveToBoard(move);
            RecordCapture(result.CapturedPiece);
            yield return AnimateMove(move, result);
            if (move.Promotion)
            {
                ReplacePromotedPiece(move);
            }

            if (IsCheckmate(!whiteToMove))
            {
                status = playerMove ? "Checkmate secured" : "Checkmated";
                RefreshUiBoard();
                animating = false;
                yield break;
            }

            if (GenerateLegalMoves(!whiteToMove).Count == 0)
            {
                status = "Stalemate";
                RefreshUiBoard();
                animating = false;
                yield break;
            }

            if (IsDrawByRule())
            {
                status = "Draw";
                RefreshUiBoard();
                animating = false;
                yield break;
            }

            whiteToMove = !whiteToMove;
            status = whiteToMove ? "Your move" : "Engine thinking";
            RefreshUiBoard();
            animating = false;

            if (!whiteToMove)
            {
                yield return new WaitForSeconds(0.10f);
                ChessMove aiMove = ChooseAiMove();
                yield return PlayMove(aiMove, false);
            }
        }

        private IEnumerator AnimateMove(ChessMove move, MoveResult result)
        {
            if (useSafeUiBoard)
            {
                yield return new WaitForSeconds(0.08f);
                RefreshUiBoard();
                yield break;
            }

            if (!pieceObjects.TryGetValue(move.From, out GameObject mover))
            {
                yield break;
            }

            GameObject capturedObject = null;
            if (result.CapturedPiece != '\0' && pieceObjects.TryGetValue(result.CapturedSquare, out capturedObject))
            {
                pieceObjects.Remove(result.CapturedSquare);
            }

            Vector3 from = BoardToWorld(move.From);
            Vector3 to = BoardToWorld(move.To);
            float elapsed = 0f;
            while (elapsed < moveSeconds)
            {
                elapsed += Time.deltaTime;
                float t = Mathf.Clamp01(elapsed / moveSeconds);
                float eased = 1f - Mathf.Pow(1f - t, 3f);
                Vector3 position = Vector3.Lerp(from, to, eased);
                position.y += Mathf.Sin(eased * Mathf.PI) * 0.28f;
                mover.transform.position = position;
                mover.transform.rotation = Quaternion.Euler(0f, Mathf.Lerp(0f, 10f, Mathf.Sin(eased * Mathf.PI)), 0f);
                yield return null;
            }

            mover.transform.position = to;
            mover.transform.rotation = Quaternion.identity;
            pieceObjects.Remove(move.From);
            pieceObjects[move.To] = mover;

            if (move.Castle)
            {
                yield return AnimateCastleRook(move);
            }

            if (capturedObject != null)
            {
                Vector3 tray = CaptureTrayPosition(IsWhite(result.CapturedPiece));
                yield return AnimateCapture(capturedObject, tray);
            }
        }

        private IEnumerator AnimateCastleRook(ChessMove kingMove)
        {
            int rank = kingMove.From.y;
            bool kingside = kingMove.To.x > kingMove.From.x;
            Vector2Int rookFrom = new(kingside ? 7 : 0, rank);
            Vector2Int rookTo = new(kingside ? 5 : 3, rank);
            if (!pieceObjects.TryGetValue(rookFrom, out GameObject rook))
            {
                yield break;
            }

            Vector3 from = BoardToWorld(rookFrom);
            Vector3 to = BoardToWorld(rookTo);
            float elapsed = 0f;
            const float duration = 0.14f;
            while (elapsed < duration)
            {
                elapsed += Time.deltaTime;
                float t = Mathf.Clamp01(elapsed / duration);
                float eased = 1f - Mathf.Pow(1f - t, 3f);
                rook.transform.position = Vector3.Lerp(from, to, eased);
                yield return null;
            }

            rook.transform.position = to;
            pieceObjects.Remove(rookFrom);
            pieceObjects[rookTo] = rook;
        }

        private IEnumerator AnimateCapture(GameObject capturedObject, Vector3 tray)
        {
            Vector3 start = capturedObject.transform.position;
            Quaternion startRot = capturedObject.transform.rotation;
            Quaternion endRot = Quaternion.Euler(86f, random.Next(-34, 34), random.Next(-18, 18));
            float elapsed = 0f;
            const float duration = 0.22f;
            while (elapsed < duration)
            {
                elapsed += Time.deltaTime;
                float t = Mathf.Clamp01(elapsed / duration);
                float eased = 1f - Mathf.Pow(1f - t, 3f);
                Vector3 position = Vector3.Lerp(start, tray, eased);
                position.y += Mathf.Sin(eased * Mathf.PI) * 0.42f;
                capturedObject.transform.position = position;
                capturedObject.transform.rotation = Quaternion.Slerp(startRot, endRot, eased);
                yield return null;
            }
            capturedObject.transform.position = tray;
            capturedObject.transform.rotation = endRot;
            capturedObjects.Add(capturedObject);
        }

        private ChessMove ChooseAiMove()
        {
            List<ChessMove> moves = GenerateLegalMoves(false);
            ChessMove best = moves[0];
            int bestScore = int.MinValue;
            foreach (ChessMove move in OrderMoves(moves))
            {
                GameSnapshot snapshot = CaptureSnapshot();
                ApplyMoveToBoard(move);
                int score = -Search(aiDepth - 1, int.MinValue + 1, int.MaxValue - 1, true);
                RestoreSnapshot(snapshot);
                if (score > bestScore)
                {
                    bestScore = score;
                    best = move;
                }
            }
            return best;
        }

        private int Search(int depth, int alpha, int beta, bool white)
        {
            List<ChessMove> moves = GenerateLegalMoves(white);
            if (moves.Count == 0)
            {
                return IsKingInCheck(white) ? -100000 - depth : 0;
            }
            if (depth == 0)
            {
                return Evaluate(white);
            }

            int best = int.MinValue + 1;
            foreach (ChessMove move in OrderMoves(moves))
            {
                GameSnapshot snapshot = CaptureSnapshot();
                ApplyMoveToBoard(move);
                int score = -Search(depth - 1, -beta, -alpha, !white);
                RestoreSnapshot(snapshot);
                best = Mathf.Max(best, score);
                alpha = Mathf.Max(alpha, score);
                if (alpha >= beta)
                {
                    break;
                }
            }
            return best;
        }

        private int Evaluate(bool forWhite)
        {
            int score = 0;
            for (int file = 0; file < BoardSize; file++)
            {
                for (int rank = 0; rank < BoardSize; rank++)
                {
                    char piece = board[file, rank];
                    if (piece == '\0')
                    {
                        continue;
                    }
                    int value = PieceValue(piece);
                    int center = 14 - Mathf.RoundToInt((Mathf.Abs(file - 3.5f) + Mathf.Abs(rank - 3.5f)) * 3f);
                    int positional = PositionalBonus(piece, file, rank);
                    int sign = IsWhite(piece) == forWhite ? 1 : -1;
                    score += sign * (value + center + positional);
                }
            }
            return score;
        }

        private int PositionalBonus(char piece, int file, int rank)
        {
            bool white = IsWhite(piece);
            int forward = white ? rank : 7 - rank;
            int center = 14 - Mathf.RoundToInt((Mathf.Abs(file - 3.5f) + Mathf.Abs(rank - 3.5f)) * 3f);
            return char.ToLowerInvariant(piece) switch
            {
                'p' => forward * 9 + (file >= 2 && file <= 5 ? 8 : 0),
                'n' => center * 5 - (forward == 0 ? 18 : 0),
                'b' => center * 4,
                'r' => forward * 3 + (IsOpenFile(file) ? 18 : 0),
                'q' => center * 2,
                'k' => KingSafetyBonus(white, file, rank),
                _ => 0
            };
        }

        private bool IsOpenFile(int file)
        {
            for (int rank = 0; rank < BoardSize; rank++)
            {
                if (IsPawn(board[file, rank]))
                {
                    return false;
                }
            }
            return true;
        }

        private int KingSafetyBonus(bool white, int file, int rank)
        {
            int homeRank = white ? 0 : 7;
            int safety = rank == homeRank ? 20 : 0;
            int pawnRank = white ? rank + 1 : rank - 1;
            for (int dx = -1; dx <= 1; dx++)
            {
                Vector2Int shield = new(file + dx, pawnRank);
                if (InBoard(shield) && board[shield.x, shield.y] == (white ? 'P' : 'p'))
                {
                    safety += 12;
                }
            }
            return safety;
        }

        private List<ChessMove> GenerateLegalMoves(bool white)
        {
            List<ChessMove> moves = new();
            for (int file = 0; file < BoardSize; file++)
            {
                for (int rank = 0; rank < BoardSize; rank++)
                {
                    char piece = board[file, rank];
                    if (piece == '\0' || IsWhite(piece) != white)
                    {
                        continue;
                    }
                    GeneratePieceMoves(new Vector2Int(file, rank), piece, moves);
                }
            }

            moves.RemoveAll(move =>
            {
                GameSnapshot snapshot = CaptureSnapshot();
                ApplyMoveToBoard(move);
                bool illegal = IsKingInCheck(white);
                RestoreSnapshot(snapshot);
                return illegal;
            });
            return moves;
        }

        private void GeneratePieceMoves(Vector2Int from, char piece, List<ChessMove> moves)
        {
            bool white = IsWhite(piece);
            switch (char.ToLowerInvariant(piece))
            {
                case 'p':
                    GeneratePawnMoves(from, white, moves);
                    break;
                case 'n':
                    foreach (Vector2Int step in KnightSteps)
                    {
                        TryAddMove(from, from + step, white, moves);
                    }
                    break;
                case 'b':
                    GenerateSlides(from, white, moves, BishopDirs);
                    break;
                case 'r':
                    GenerateSlides(from, white, moves, RookDirs);
                    break;
                case 'q':
                    GenerateSlides(from, white, moves, QueenDirs);
                    break;
                case 'k':
                    GenerateKingMoves(from, white, moves);
                    break;
            }
        }

        private void GeneratePawnMoves(Vector2Int from, bool white, List<ChessMove> moves)
        {
            int dir = white ? 1 : -1;
            int startRank = white ? 1 : 6;
            Vector2Int one = new(from.x, from.y + dir);
            if (InBoard(one) && board[one.x, one.y] == '\0')
            {
                moves.Add(new ChessMove(from, one, one.y == (white ? 7 : 0)));
                Vector2Int two = new(from.x, from.y + dir * 2);
                if (from.y == startRank && board[two.x, two.y] == '\0')
                {
                    moves.Add(new ChessMove(from, two, false));
                }
            }

            foreach (int dx in new[] { -1, 1 })
            {
                Vector2Int target = new(from.x + dx, from.y + dir);
                if (InBoard(target) && board[target.x, target.y] != '\0' && IsWhite(board[target.x, target.y]) != white && !IsKing(board[target.x, target.y]))
                {
                    moves.Add(new ChessMove(from, target, target.y == (white ? 7 : 0)));
                }
                else if (enPassantSquare.HasValue && target == enPassantSquare.Value)
                {
                    moves.Add(new ChessMove(from, target, false, false, true));
                }
            }
        }

        private void GenerateKingMoves(Vector2Int from, bool white, List<ChessMove> moves)
        {
            foreach (Vector2Int step in KingSteps)
            {
                TryAddMove(from, from + step, white, moves);
            }

            TryAddCastle(from, white, true, moves);
            TryAddCastle(from, white, false, moves);
        }

        private void TryAddCastle(Vector2Int from, bool white, bool kingside, List<ChessMove> moves)
        {
            int rank = white ? 0 : 7;
            if (from != new Vector2Int(4, rank) || IsKingInCheck(white))
            {
                return;
            }

            if (white)
            {
                if (whiteKingMoved || (kingside ? whiteKingsideRookMoved : whiteQueensideRookMoved))
                {
                    return;
                }
            }
            else if (blackKingMoved || (kingside ? blackKingsideRookMoved : blackQueensideRookMoved))
            {
                return;
            }

            int rookFile = kingside ? 7 : 0;
            int throughFile = kingside ? 5 : 3;
            int targetFile = kingside ? 6 : 2;
            char rook = board[rookFile, rank];
            if (rook != (white ? 'R' : 'r'))
            {
                return;
            }

            int start = Mathf.Min(rookFile, from.x) + 1;
            int end = Mathf.Max(rookFile, from.x) - 1;
            for (int file = start; file <= end; file++)
            {
                if (board[file, rank] != '\0')
                {
                    return;
                }
            }

            if (IsSquareAttacked(new Vector2Int(throughFile, rank), !white) || IsSquareAttacked(new Vector2Int(targetFile, rank), !white))
            {
                return;
            }

            moves.Add(new ChessMove(from, new Vector2Int(targetFile, rank), false, true, false));
        }

        private void GenerateSlides(Vector2Int from, bool white, List<ChessMove> moves, Vector2Int[] dirs)
        {
            foreach (Vector2Int dir in dirs)
            {
                Vector2Int cursor = from + dir;
                while (InBoard(cursor))
                {
                    if (!TryAddMove(from, cursor, white, moves))
                    {
                        break;
                    }
                    if (board[cursor.x, cursor.y] != '\0')
                    {
                        break;
                    }
                    cursor += dir;
                }
            }
        }

        private bool TryAddMove(Vector2Int from, Vector2Int to, bool white, List<ChessMove> moves)
        {
            if (!InBoard(to))
            {
                return false;
            }
            char target = board[to.x, to.y];
            if (target == '\0')
            {
                moves.Add(new ChessMove(from, to, false));
                return true;
            }
            if (IsWhite(target) != white)
            {
                if (!IsKing(target))
                {
                    moves.Add(new ChessMove(from, to, false));
                }
            }
            return false;
        }

        private bool IsKingInCheck(bool white)
        {
            Vector2Int king = FindKing(white);
            return IsSquareAttacked(king, !white);
        }

        private bool IsCheckmate(bool white)
        {
            return IsKingInCheck(white) && GenerateLegalMoves(white).Count == 0;
        }

        private bool IsDrawByRule()
        {
            return halfMoveClock >= 100 || IsInsufficientMaterial();
        }

        private bool IsInsufficientMaterial()
        {
            int minorPieces = 0;
            int bishopsOnLight = 0;
            int bishopsOnDark = 0;
            for (int file = 0; file < BoardSize; file++)
            {
                for (int rank = 0; rank < BoardSize; rank++)
                {
                    char piece = board[file, rank];
                    if (piece == '\0' || IsKing(piece))
                    {
                        continue;
                    }

                    char lower = char.ToLowerInvariant(piece);
                    if (lower == 'p' || lower == 'r' || lower == 'q')
                    {
                        return false;
                    }

                    minorPieces++;
                    if (lower == 'b')
                    {
                        if (((file + rank) & 1) == 0)
                        {
                            bishopsOnDark++;
                        }
                        else
                        {
                            bishopsOnLight++;
                        }
                    }
                }
            }

            if (minorPieces <= 1)
            {
                return true;
            }

            return minorPieces == bishopsOnLight + bishopsOnDark && (bishopsOnLight == 0 || bishopsOnDark == 0);
        }

        private bool IsSquareAttacked(Vector2Int square, bool byWhite)
        {
            int pawnDir = byWhite ? 1 : -1;
            foreach (int dx in new[] { -1, 1 })
            {
                Vector2Int pawn = new(square.x - dx, square.y - pawnDir);
                if (InBoard(pawn) && board[pawn.x, pawn.y] == (byWhite ? 'P' : 'p'))
                {
                    return true;
                }
            }

            foreach (Vector2Int step in KnightSteps)
            {
                Vector2Int at = square + step;
                if (InBoard(at) && board[at.x, at.y] == (byWhite ? 'N' : 'n'))
                {
                    return true;
                }
            }

            if (RayAttacked(square, byWhite, BishopDirs, byWhite ? "BQ" : "bq"))
            {
                return true;
            }
            if (RayAttacked(square, byWhite, RookDirs, byWhite ? "RQ" : "rq"))
            {
                return true;
            }

            foreach (Vector2Int step in KingSteps)
            {
                Vector2Int at = square + step;
                if (InBoard(at) && board[at.x, at.y] == (byWhite ? 'K' : 'k'))
                {
                    return true;
                }
            }
            return false;
        }

        private bool RayAttacked(Vector2Int square, bool byWhite, Vector2Int[] dirs, string attackers)
        {
            foreach (Vector2Int dir in dirs)
            {
                Vector2Int cursor = square + dir;
                while (InBoard(cursor))
                {
                    char piece = board[cursor.x, cursor.y];
                    if (piece == '\0')
                    {
                        cursor += dir;
                        continue;
                    }
                    if (IsWhite(piece) == byWhite && attackers.Contains(piece))
                    {
                        return true;
                    }
                    break;
                }
            }
            return false;
        }

        private MoveResult ApplyMoveToBoard(ChessMove move)
        {
            char piece = board[move.From.x, move.From.y];
            bool white = IsWhite(piece);
            Vector2Int capturedSquare = move.EnPassant ? new Vector2Int(move.To.x, move.From.y) : move.To;
            char captured = board[capturedSquare.x, capturedSquare.y];

            board[move.From.x, move.From.y] = '\0';
            if (move.EnPassant)
            {
                board[capturedSquare.x, capturedSquare.y] = '\0';
            }

            board[move.To.x, move.To.y] = move.Promotion ? (white ? 'Q' : 'q') : piece;
            if (move.Castle)
            {
                int rank = move.From.y;
                bool kingside = move.To.x > move.From.x;
                int rookFrom = kingside ? 7 : 0;
                int rookTo = kingside ? 5 : 3;
                board[rookTo, rank] = board[rookFrom, rank];
                board[rookFrom, rank] = '\0';
            }

            UpdateCastlingRights(move, piece, captured, capturedSquare);
            enPassantSquare = IsPawn(piece) && Mathf.Abs(move.To.y - move.From.y) == 2
                ? new Vector2Int(move.From.x, (move.From.y + move.To.y) / 2)
                : null;
            halfMoveClock = IsPawn(piece) || captured != '\0' ? 0 : halfMoveClock + 1;
            if (!white)
            {
                fullMoveNumber++;
            }

            return new MoveResult(captured, capturedSquare);
        }

        private GameSnapshot CaptureSnapshot()
        {
            return new GameSnapshot
            {
                Board = (char[,])board.Clone(),
                WhiteKingMoved = whiteKingMoved,
                BlackKingMoved = blackKingMoved,
                WhiteKingsideRookMoved = whiteKingsideRookMoved,
                WhiteQueensideRookMoved = whiteQueensideRookMoved,
                BlackKingsideRookMoved = blackKingsideRookMoved,
                BlackQueensideRookMoved = blackQueensideRookMoved,
                EnPassantSquare = enPassantSquare,
                HalfMoveClock = halfMoveClock,
                FullMoveNumber = fullMoveNumber
            };
        }

        private void RestoreSnapshot(GameSnapshot snapshot)
        {
            for (int file = 0; file < BoardSize; file++)
            {
                for (int rank = 0; rank < BoardSize; rank++)
                {
                    board[file, rank] = snapshot.Board[file, rank];
                }
            }

            whiteKingMoved = snapshot.WhiteKingMoved;
            blackKingMoved = snapshot.BlackKingMoved;
            whiteKingsideRookMoved = snapshot.WhiteKingsideRookMoved;
            whiteQueensideRookMoved = snapshot.WhiteQueensideRookMoved;
            blackKingsideRookMoved = snapshot.BlackKingsideRookMoved;
            blackQueensideRookMoved = snapshot.BlackQueensideRookMoved;
            enPassantSquare = snapshot.EnPassantSquare;
            halfMoveClock = snapshot.HalfMoveClock;
            fullMoveNumber = snapshot.FullMoveNumber;
        }

        private void UpdateCastlingRights(ChessMove move, char piece, char captured, Vector2Int capturedSquare)
        {
            switch (piece)
            {
                case 'K':
                    whiteKingMoved = true;
                    break;
                case 'k':
                    blackKingMoved = true;
                    break;
                case 'R' when move.From == new Vector2Int(7, 0):
                    whiteKingsideRookMoved = true;
                    break;
                case 'R' when move.From == new Vector2Int(0, 0):
                    whiteQueensideRookMoved = true;
                    break;
                case 'r' when move.From == new Vector2Int(7, 7):
                    blackKingsideRookMoved = true;
                    break;
                case 'r' when move.From == new Vector2Int(0, 7):
                    blackQueensideRookMoved = true;
                    break;
            }

            if (captured == 'R' && capturedSquare == new Vector2Int(7, 0))
            {
                whiteKingsideRookMoved = true;
            }
            else if (captured == 'R' && capturedSquare == new Vector2Int(0, 0))
            {
                whiteQueensideRookMoved = true;
            }
            else if (captured == 'r' && capturedSquare == new Vector2Int(7, 7))
            {
                blackKingsideRookMoved = true;
            }
            else if (captured == 'r' && capturedSquare == new Vector2Int(0, 7))
            {
                blackQueensideRookMoved = true;
            }
        }

        private void RecordCapture(char captured)
        {
            if (captured != '\0')
            {
                if (IsWhite(captured))
                {
                    capturedByBlack++;
                }
                else
                {
                    capturedByWhite++;
                }
            }
        }

        private void ResetGame()
        {
            Array.Clear(board, 0, board.Length);
            string[] setup =
            {
                "RNBQKBNR",
                "PPPPPPPP",
                "........",
                "........",
                "........",
                "........",
                "pppppppp",
                "rnbqkbnr"
            };
            for (int rank = 0; rank < BoardSize; rank++)
            {
                for (int file = 0; file < BoardSize; file++)
                {
                    char piece = setup[rank][file];
                    board[file, rank] = piece == '.' ? '\0' : piece;
                }
            }
            whiteToMove = true;
            animating = false;
            whiteKingMoved = false;
            blackKingMoved = false;
            whiteKingsideRookMoved = false;
            whiteQueensideRookMoved = false;
            blackKingsideRookMoved = false;
            blackQueensideRookMoved = false;
            enPassantSquare = null;
            halfMoveClock = 0;
            fullMoveNumber = 1;
            capturedByWhite = 0;
            capturedByBlack = 0;
            status = "Your move";
            selected = null;
            selectedMoves.Clear();
            ClearMoveMarkers();
            ClearCapturedObjects();
            RebuildPiecesFromBoard();
            RefreshTileSelection();
        }

        private void RebuildPiecesFromBoard()
        {
            if (useSafeUiBoard)
            {
                RefreshUiBoard();
                return;
            }

            foreach (GameObject piece in pieceObjects.Values)
            {
                Destroy(piece);
            }
            pieceObjects.Clear();

            for (int file = 0; file < BoardSize; file++)
            {
                for (int rank = 0; rank < BoardSize; rank++)
                {
                    char piece = board[file, rank];
                    if (piece == '\0')
                    {
                        continue;
                    }
                    GameObject visual = CreatePiece(piece, new Vector2Int(file, rank));
                    pieceObjects[new Vector2Int(file, rank)] = visual;
                }
            }
        }

        private void ClearCapturedObjects()
        {
            if (useSafeUiBoard)
            {
                return;
            }

            foreach (GameObject captured in capturedObjects)
            {
                Destroy(captured);
            }
            capturedObjects.Clear();
        }

        private void ReplacePromotedPiece(ChessMove move)
        {
            if (useSafeUiBoard)
            {
                RefreshUiBoard();
                return;
            }

            if (pieceObjects.TryGetValue(move.To, out GameObject pawn))
            {
                Destroy(pawn);
            }
            pieceObjects[move.To] = CreatePiece(board[move.To.x, move.To.y], move.To);
        }

        private void CreateMaterials()
        {
            lightSquare = NewMat("polished ivory square", new Color(0.86f, 0.73f, 0.52f), 0.08f, 0.62f);
            darkSquare = NewMat("smoked walnut square", new Color(0.24f, 0.13f, 0.065f), 0.06f, 0.55f);
            selectedSquare = NewMat("warm selected square", new Color(1.0f, 0.55f, 0.16f), 0.04f, 0.78f, new Color(0.95f, 0.37f, 0.06f) * 0.65f);
            moveDot = NewMat("legal move amber", new Color(1.0f, 0.69f, 0.22f), 0.03f, 0.75f, new Color(1.0f, 0.42f, 0.08f) * 0.45f);
            captureDot = NewMat("capture ember", new Color(1.0f, 0.18f, 0.08f), 0.04f, 0.82f, new Color(1.0f, 0.08f, 0.04f) * 0.75f);
            ivoryPiece = NewMat("solid ivory piece", new Color(0.98f, 0.84f, 0.58f), 0.12f, 0.82f);
            blackPiece = NewMat("onyx black piece", new Color(0.028f, 0.025f, 0.023f), 0.18f, 0.86f);
            goldTrim = NewMat("brushed gold trim", new Color(1.0f, 0.62f, 0.19f), 0.22f, 0.72f, new Color(0.72f, 0.32f, 0.06f) * 0.35f);
            woodFrame = NewMat("carved walnut frame", new Color(0.31f, 0.16f, 0.075f), 0.05f, 0.52f);
            boardCore = NewMat("deep board core", new Color(0.12f, 0.065f, 0.04f), 0.04f, 0.48f);
            boardEdge = NewMat("dark beveled edge", new Color(0.055f, 0.032f, 0.022f), 0.02f, 0.50f);
            feltTray = NewMat("green felt tray", new Color(0.045f, 0.13f, 0.095f), 0.0f, 0.45f);
            feltDark = NewMat("studio floor", new Color(0.035f, 0.027f, 0.022f), 0.0f, 0.35f);
            shadowMat = NewMat("soft piece shadow", new Color(0.0f, 0.0f, 0.0f, 0.34f), 0.0f, 0.15f);
            labelMat = NewMat("engraved label", new Color(1.0f, 0.70f, 0.34f), 0.0f, 0.55f, new Color(0.7f, 0.25f, 0.04f) * 0.35f);
        }

        private Material NewMat(string name, Color color, float metallic, float smoothness, Color? emission = null)
        {
            Shader shader = PickRuntimeShader();
            if (shader == null)
            {
                throw new InvalidOperationException("No Unity runtime shader was available for Daily Gambit materials.");
            }

            Material material = new(shader);
            {
                material.name = name;
            }

            SetMaterialColor(material, color);
            if (material.HasProperty("_Metallic"))
            {
                material.SetFloat("_Metallic", metallic);
            }
            if (material.HasProperty("_Glossiness"))
            {
                material.SetFloat("_Glossiness", smoothness);
            }
            if (material.HasProperty("_Smoothness"))
            {
                material.SetFloat("_Smoothness", smoothness);
            }
            if (emission.HasValue && material.HasProperty("_EmissionColor"))
            {
                material.EnableKeyword("_EMISSION");
                material.SetColor("_EmissionColor", emission.Value);
            }
            return material;
        }

        private static Shader PickRuntimeShader()
        {
            string[] candidates =
            {
                "Standard",
                "Universal Render Pipeline/Lit",
                "Mobile/Diffuse",
                "Legacy Shaders/Diffuse",
                "Unlit/Color",
                "Sprites/Default"
            };

            foreach (string candidate in candidates)
            {
                Shader shader = Shader.Find(candidate);
                if (shader != null)
                {
                    return shader;
                }
            }

            return null;
        }

        private static void SetMaterialColor(Material material, Color color)
        {
            if (material.HasProperty("_BaseColor"))
            {
                material.SetColor("_BaseColor", color);
            }
            if (material.HasProperty("_Color"))
            {
                material.SetColor("_Color", color);
            }
            material.color = color;
        }

        private void CreateSafeUiBoard()
        {
            safeStatusStyle = null;
            safePieceStyle = null;
            safeFooterStyle = null;
            RefreshUiLayout(true);
        }

        private void RefreshUiLayout(bool force = false)
        {
            int width = Mathf.Max(1, Screen.width);
            int height = Mathf.Max(1, Screen.height);
            if (!force && width == lastScreenWidth && height == lastScreenHeight)
            {
                return;
            }

            lastScreenWidth = width;
            lastScreenHeight = height;
            float boardSize = Mathf.Min(width - 36f, height - 270f);
            boardSize = Mathf.Clamp(boardSize, 300f, Mathf.Min(width - 16f, height - 120f));
            safeBoardRect = new Rect((width - boardSize) * 0.5f, (height - boardSize) * 0.5f + 18f, boardSize, boardSize);
        }

        private void RefreshUiBoard()
        {
            RefreshUiLayout();
        }

        private void RefreshUiStatus()
        {
        }

        private void CreateSceneRig()
        {
            Camera cam = Camera.main;
            if (cam == null)
            {
                GameObject cameraObject = new("Main Camera");
                cam = cameraObject.AddComponent<Camera>();
                cameraObject.tag = "MainCamera";
            }
            mainCamera = cam;
            cam.orthographic = true;
            cam.nearClipPlane = 0.05f;
            cam.farClipPlane = 80f;
            cam.clearFlags = CameraClearFlags.SolidColor;
            cam.backgroundColor = new Color(0.035f, 0.029f, 0.024f);
            RefreshCameraForScreen(true);

            RenderSettings.ambientLight = new Color(0.72f, 0.63f, 0.48f);
            RenderSettings.fog = false;

            GameObject lightObject = new("Key Light");
            Light light = lightObject.AddComponent<Light>();
            light.type = LightType.Directional;
            light.intensity = 0.92f;
            light.shadows = LightShadows.None;
            light.color = new Color(1.0f, 0.90f, 0.74f);
            lightObject.transform.rotation = Quaternion.Euler(90f, -25f, 0f);

            GameObject fillObject = new("Board Fill Light");
            Light fill = fillObject.AddComponent<Light>();
            fill.type = LightType.Point;
            fill.range = 8.5f;
            fill.intensity = 0.42f;
            fill.color = new Color(1.0f, 0.78f, 0.52f);
            fillObject.transform.position = new Vector3(BoardCenter, 5.6f, BoardCenter);
        }

        private void RefreshCameraForScreen(bool force = false)
        {
            if (mainCamera == null)
            {
                return;
            }

            int width = Mathf.Max(1, Screen.width);
            int height = Mathf.Max(1, Screen.height);
            if (!force && width == lastScreenWidth && height == lastScreenHeight)
            {
                return;
            }

            lastScreenWidth = width;
            lastScreenHeight = height;
            float aspect = Mathf.Max(0.35f, width / (float)height);
            const float framedBoardWidth = 8.95f;
            const float framedBoardHeight = 9.15f;
            float sizeByHeight = framedBoardHeight * 0.5f;
            float sizeByWidth = framedBoardWidth / (2f * aspect);
            mainCamera.transform.position = new Vector3(BoardCenter, CameraHeight, BoardCenter);
            mainCamera.transform.rotation = Quaternion.Euler(90f, 0f, 0f);
            mainCamera.orthographic = true;
            mainCamera.orthographicSize = Mathf.Max(sizeByHeight, sizeByWidth);
        }

        private void CreateEmergencyView()
        {
            try
            {
                if (mainCamera == null)
                {
                    CreateSceneRig();
                }

                Material red = NewMat("emergency red", new Color(0.9f, 0.14f, 0.08f), 0f, 0.2f);
                Material gold = NewMat("emergency gold", new Color(1.0f, 0.65f, 0.18f), 0f, 0.35f);
                for (int file = 0; file < BoardSize; file++)
                {
                    for (int rank = 0; rank < BoardSize; rank++)
                    {
                        GameObject tile = GameObject.CreatePrimitive(PrimitiveType.Cube);
                        tile.name = "Emergency visible square";
                        tile.transform.SetParent(transform);
                        tile.transform.position = new Vector3(file, 0f, rank);
                        tile.transform.localScale = new Vector3(0.95f, 0.08f, 0.95f);
                        tile.GetComponent<Renderer>().sharedMaterial = ((file + rank) & 1) == 0 ? red : gold;
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.LogException(ex);
            }
        }

        private void CreateBoard()
        {
            CreateEnvironment();
            CreateBoardBase();
            for (int file = 0; file < BoardSize; file++)
            {
                for (int rank = 0; rank < BoardSize; rank++)
                {
                    GameObject tile = GameObject.CreatePrimitive(PrimitiveType.Cube);
                    tile.name = $"Square {SquareName(file, rank)}";
                    tile.transform.SetParent(transform);
                    tile.transform.position = BoardToWorld(new Vector2Int(file, rank)) + Vector3.down * boardLift;
                    tile.transform.localScale = new Vector3(0.98f, 0.08f, 0.98f);
                    tile.GetComponent<Renderer>().sharedMaterial = ((file + rank) & 1) == 0 ? darkSquare : lightSquare;
                    SquareMarker marker = tile.AddComponent<SquareMarker>();
                    marker.File = file;
                    marker.Rank = rank;
                    tileRenderers[new Vector2Int(file, rank)] = tile.GetComponent<Renderer>();
                }
            }

            CreateFramePiece("North Rail", new Vector3(BoardCenter, -0.02f, 8.02f), new Vector3(8.85f, 0.18f, 0.24f));
            CreateFramePiece("South Rail", new Vector3(BoardCenter, -0.02f, -1.02f), new Vector3(8.85f, 0.18f, 0.24f));
            CreateFramePiece("West Rail", new Vector3(-1.02f, -0.02f, BoardCenter), new Vector3(0.24f, 0.18f, 8.85f));
            CreateFramePiece("East Rail", new Vector3(8.02f, -0.02f, BoardCenter), new Vector3(0.24f, 0.18f, 8.85f));
            CreateBoardLabels();
        }

        private void CreateEnvironment()
        {
            GameObject floor = GameObject.CreatePrimitive(PrimitiveType.Cube);
            floor.name = "matte studio floor";
            floor.transform.SetParent(transform);
            floor.transform.position = new Vector3(BoardCenter, -0.24f, BoardCenter);
            floor.transform.localScale = new Vector3(9.8f, 0.08f, 10.0f);
            floor.GetComponent<Renderer>().sharedMaterial = feltDark;
            Destroy(floor.GetComponent<Collider>());
        }

        private void CreateBoardBase()
        {
            GameObject baseBlock = GameObject.CreatePrimitive(PrimitiveType.Cube);
            baseBlock.name = "single solid chess board base";
            baseBlock.transform.SetParent(transform);
            baseBlock.transform.position = new Vector3(BoardCenter, -0.105f, BoardCenter);
            baseBlock.transform.localScale = new Vector3(8.95f, 0.22f, 8.95f);
            baseBlock.GetComponent<Renderer>().sharedMaterial = boardCore;
            Destroy(baseBlock.GetComponent<Collider>());

            GameObject topInset = GameObject.CreatePrimitive(PrimitiveType.Cube);
            topInset.name = "sunken board field";
            topInset.transform.SetParent(transform);
            topInset.transform.position = new Vector3(BoardCenter, -0.035f, BoardCenter);
            topInset.transform.localScale = new Vector3(8.05f, 0.08f, 8.05f);
            topInset.GetComponent<Renderer>().sharedMaterial = boardEdge;
            Destroy(topInset.GetComponent<Collider>());
        }

        private void CreateFramePiece(string name, Vector3 position, Vector3 scale)
        {
            GameObject rail = GameObject.CreatePrimitive(PrimitiveType.Cube);
            rail.name = name;
            rail.transform.SetParent(transform);
            rail.transform.position = position;
            rail.transform.localScale = scale;
            rail.GetComponent<Renderer>().sharedMaterial = woodFrame;
        }

        private void CreateCaptureTray(string name, Vector3 position, Vector3 scale)
        {
            GameObject tray = GameObject.CreatePrimitive(PrimitiveType.Cube);
            tray.name = name;
            tray.transform.SetParent(transform);
            tray.transform.position = position;
            tray.transform.localScale = scale;
            tray.GetComponent<Renderer>().sharedMaterial = feltTray;
            Destroy(tray.GetComponent<Collider>());
        }

        private void CreateBoardLabels()
        {
            for (int i = 0; i < BoardSize; i++)
            {
                CreateLabel(((char)('A' + i)).ToString(), new Vector3(i, 0.09f, -0.54f), 0f);
                CreateLabel((i + 1).ToString(), new Vector3(-0.54f, 0.09f, i), 0f);
            }
        }

        private void CreateLabel(string text, Vector3 position, float yRotation)
        {
            GameObject label = new($"engraved label {text}");
            label.transform.SetParent(transform);
            label.transform.position = position;
            label.transform.rotation = Quaternion.Euler(90f, yRotation, 0f);
            TextMesh mesh = label.AddComponent<TextMesh>();
            mesh.text = text;
            mesh.anchor = TextAnchor.MiddleCenter;
            mesh.alignment = TextAlignment.Center;
            mesh.characterSize = 0.15f;
            mesh.fontSize = 36;
            Renderer renderer = label.GetComponent<Renderer>();
            renderer.sharedMaterial = labelMat;
            renderer.shadowCastingMode = ShadowCastingMode.Off;
        }

        private GameObject CreatePiece(char piece, Vector2Int square)
        {
            GameObject root = new($"Piece {piece} {SquareName(square.x, square.y)}");
            root.transform.SetParent(transform);
            root.transform.position = BoardToWorld(square);
            Material material = IsWhite(piece) ? ivoryPiece : blackPiece;
            AddPieceShadow(root);
            CreatePrimitive(root, PrimitiveType.Cylinder, new Vector3(0f, 0.030f, 0f), new Vector3(0.43f, 0.030f, 0.43f), goldTrim);
            CreatePrimitive(root, PrimitiveType.Cylinder, new Vector3(0f, 0.095f, 0f), new Vector3(0.39f, 0.055f, 0.39f), material);
            CreatePrimitive(root, PrimitiveType.Cylinder, new Vector3(0f, 0.158f, 0f), new Vector3(0.34f, 0.026f, 0.34f), goldTrim);
            CreatePieceGlyph(root, piece);
            return root;
        }

        private void CreatePieceGlyph(GameObject root, char piece)
        {
            bool white = IsWhite(piece);
            GameObject glyph = new($"Glyph {piece}");
            glyph.transform.SetParent(root.transform);
            glyph.transform.localPosition = new Vector3(0f, 0.225f, 0f);
            glyph.transform.localRotation = Quaternion.Euler(90f, 0f, 0f);
            TextMesh mesh = glyph.AddComponent<TextMesh>();
            mesh.text = PieceGlyph(piece);
            mesh.anchor = TextAnchor.MiddleCenter;
            mesh.alignment = TextAlignment.Center;
            mesh.characterSize = 0.42f;
            mesh.fontSize = 96;
            Renderer renderer = glyph.GetComponent<Renderer>();
            renderer.sharedMaterial = white ? blackPiece : ivoryPiece;
            renderer.shadowCastingMode = ShadowCastingMode.Off;

            GameObject rankDot = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            rankDot.name = "piece rank accent";
            rankDot.transform.SetParent(root.transform);
            rankDot.transform.localPosition = new Vector3(0f, 0.236f, -0.28f);
            rankDot.transform.localScale = AccentScale(piece);
            rankDot.GetComponent<Renderer>().sharedMaterial = goldTrim;
            Destroy(rankDot.GetComponent<Collider>());
        }

        private static Vector3 AccentScale(char piece)
        {
            return char.ToLowerInvariant(piece) switch
            {
                'p' => new Vector3(0.055f, 0.055f, 0.055f),
                'n' => new Vector3(0.075f, 0.075f, 0.075f),
                'b' => new Vector3(0.085f, 0.085f, 0.085f),
                'r' => new Vector3(0.095f, 0.095f, 0.095f),
                'q' => new Vector3(0.115f, 0.115f, 0.115f),
                'k' => new Vector3(0.125f, 0.125f, 0.125f),
                _ => new Vector3(0.06f, 0.06f, 0.06f)
            };
        }

        private static string PieceGlyph(char piece)
        {
            return char.ToLowerInvariant(piece) switch
            {
                'p' => "P",
                'n' => "N",
                'b' => "B",
                'r' => "R",
                'q' => "Q",
                'k' => "K",
                _ => "?"
            };
        }

        private void AddPieceShadow(GameObject root)
        {
            GameObject shadow = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
            shadow.name = "painted contact shadow";
            shadow.transform.SetParent(root.transform);
            shadow.transform.localPosition = new Vector3(0f, -0.026f, 0f);
            shadow.transform.localScale = new Vector3(0.52f, 0.006f, 0.52f);
            shadow.GetComponent<Renderer>().sharedMaterial = shadowMat;
            shadow.GetComponent<Renderer>().shadowCastingMode = ShadowCastingMode.Off;
            Collider collider = shadow.GetComponent<Collider>();
            if (collider != null)
            {
                Destroy(collider);
            }
        }

        private GameObject CreatePrimitive(GameObject parent, PrimitiveType type, Vector3 localPosition, Vector3 localScale, Material material)
        {
            GameObject child = GameObject.CreatePrimitive(type);
            child.transform.SetParent(parent.transform);
            child.transform.localPosition = localPosition;
            child.transform.localScale = localScale;
            Renderer renderer = child.GetComponent<Renderer>();
            renderer.sharedMaterial = material;
            renderer.shadowCastingMode = ShadowCastingMode.On;
            renderer.receiveShadows = true;
            Collider collider = child.GetComponent<Collider>();
            if (collider != null)
            {
                Destroy(collider);
            }
            return child;
        }

        private void RefreshTileSelection()
        {
            if (useSafeUiBoard)
            {
                RefreshUiBoard();
                return;
            }

            foreach ((Vector2Int square, Renderer renderer) in tileRenderers)
            {
                renderer.sharedMaterial = selected.HasValue && selected.Value == square
                    ? selectedSquare
                    : ((square.x + square.y) & 1) == 0 ? darkSquare : lightSquare;
            }
        }

        private void DrawMoveMarkers(List<ChessMove> moves)
        {
            if (useSafeUiBoard)
            {
                RefreshUiBoard();
                return;
            }

            foreach (ChessMove move in moves)
            {
                bool capture = move.EnPassant || board[move.To.x, move.To.y] != '\0';
                GameObject marker = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
                marker.name = capture ? "Capture marker" : "Move marker";
                marker.transform.SetParent(transform);
                marker.transform.position = BoardToWorld(move.To) + Vector3.up * 0.012f;
                marker.transform.localScale = capture ? new Vector3(0.54f, 0.012f, 0.54f) : new Vector3(0.24f, 0.012f, 0.24f);
                marker.GetComponent<Renderer>().sharedMaterial = capture ? captureDot : moveDot;
                Destroy(marker.GetComponent<Collider>());
                moveMarkers.Add(marker);
            }
        }

        private void ClearMoveMarkers()
        {
            if (useSafeUiBoard)
            {
                return;
            }

            foreach (GameObject marker in moveMarkers)
            {
                Destroy(marker);
            }
            moveMarkers.Clear();
        }

        private Vector3 BoardToWorld(Vector2Int square)
        {
            return new Vector3(square.x, BoardSurfaceY, square.y);
        }

        private Vector3 CaptureTrayPosition(bool capturedPieceWasWhite)
        {
            int count = Mathf.Max(0, (capturedPieceWasWhite ? capturedByBlack : capturedByWhite) - 1);
            float x = 0.35f + (count % 8) * 0.46f;
            float z = capturedPieceWasWhite ? -0.66f : 7.66f;
            float layer = count / 8 * 0.08f;
            return new Vector3(x, BoardSurfaceY + layer, z);
        }

        private Vector2Int FindKing(bool white)
        {
            char king = white ? 'K' : 'k';
            for (int file = 0; file < BoardSize; file++)
            {
                for (int rank = 0; rank < BoardSize; rank++)
                {
                    if (board[file, rank] == king)
                    {
                        return new Vector2Int(file, rank);
                    }
                }
            }
            return new Vector2Int(-1, -1);
        }

        private List<ChessMove> OrderMoves(List<ChessMove> moves)
        {
            moves.Sort((a, b) => MoveScore(b).CompareTo(MoveScore(a)));
            return moves;
        }

        private int MoveScore(ChessMove move)
        {
            int score = 0;
            Vector2Int capturedSquare = move.EnPassant ? new Vector2Int(move.To.x, move.From.y) : move.To;
            char captured = board[capturedSquare.x, capturedSquare.y];
            if (captured != '\0')
            {
                score += 1000 + PieceValue(captured) * 8 - PieceValue(board[move.From.x, move.From.y]);
            }
            if (move.Promotion)
            {
                score += 900;
            }
            if (move.Castle)
            {
                score += 120;
            }
            score += 14 - Mathf.RoundToInt((Mathf.Abs(move.To.x - 3.5f) + Mathf.Abs(move.To.y - 3.5f)) * 3f);
            return score;
        }

        private static bool InBoard(Vector2Int square)
        {
            return square.x >= 0 && square.x < BoardSize && square.y >= 0 && square.y < BoardSize;
        }

        private static bool IsWhite(char piece)
        {
            return char.IsUpper(piece);
        }

        private static bool IsKing(char piece)
        {
            return char.ToLowerInvariant(piece) == 'k';
        }

        private static bool IsPawn(char piece)
        {
            return char.ToLowerInvariant(piece) == 'p';
        }

        private static int PieceValue(char piece)
        {
            return char.ToLowerInvariant(piece) switch
            {
                'p' => 100,
                'n' => 320,
                'b' => 335,
                'r' => 500,
                'q' => 920,
                'k' => 0,
                _ => 0
            };
        }

        private static string SquareName(int file, int rank)
        {
            return $"{(char)('a' + file)}{rank + 1}";
        }

        private static readonly Vector2Int[] KnightSteps =
        {
            new(1, 2), new(2, 1), new(2, -1), new(1, -2),
            new(-1, -2), new(-2, -1), new(-2, 1), new(-1, 2)
        };

        private static readonly Vector2Int[] KingSteps =
        {
            new(1, 0), new(1, 1), new(0, 1), new(-1, 1),
            new(-1, 0), new(-1, -1), new(0, -1), new(1, -1)
        };

        private static readonly Vector2Int[] BishopDirs =
        {
            new(1, 1), new(-1, 1), new(1, -1), new(-1, -1)
        };

        private static readonly Vector2Int[] RookDirs =
        {
            new(1, 0), new(-1, 0), new(0, 1), new(0, -1)
        };

        private static readonly Vector2Int[] QueenDirs =
        {
            new(1, 1), new(-1, 1), new(1, -1), new(-1, -1),
            new(1, 0), new(-1, 0), new(0, 1), new(0, -1)
        };
    }

    public sealed class SquareMarker : MonoBehaviour
    {
        public int File;
        public int Rank;
    }

    public readonly struct ChessMove
    {
        public ChessMove(Vector2Int from, Vector2Int to, bool promotion, bool castle = false, bool enPassant = false)
        {
            From = from;
            To = to;
            Promotion = promotion;
            Castle = castle;
            EnPassant = enPassant;
        }

        public Vector2Int From { get; }
        public Vector2Int To { get; }
        public bool Promotion { get; }
        public bool Castle { get; }
        public bool EnPassant { get; }
    }

    public readonly struct MoveResult
    {
        public MoveResult(char capturedPiece, Vector2Int capturedSquare)
        {
            CapturedPiece = capturedPiece;
            CapturedSquare = capturedSquare;
        }

        public char CapturedPiece { get; }
        public Vector2Int CapturedSquare { get; }
    }

    public struct GameSnapshot
    {
        public char[,] Board;
        public bool WhiteKingMoved;
        public bool BlackKingMoved;
        public bool WhiteKingsideRookMoved;
        public bool WhiteQueensideRookMoved;
        public bool BlackKingsideRookMoved;
        public bool BlackQueensideRookMoved;
        public Vector2Int? EnPassantSquare;
        public int HalfMoveClock;
        public int FullMoveNumber;
    }
}
