using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DailyGambit
{
    public sealed class DailyGambitGame : MonoBehaviour
    {
        private const int BoardSize = 8;
        private readonly char[,] board = new char[BoardSize, BoardSize];
        private readonly Dictionary<Vector2Int, GameObject> pieceObjects = new();
        private readonly Dictionary<Vector2Int, Renderer> tileRenderers = new();
        private readonly List<GameObject> moveMarkers = new();
        private readonly List<GameObject> capturedObjects = new();
        private readonly System.Random random = new(42);

        private Material lightSquare;
        private Material darkSquare;
        private Material selectedSquare;
        private Material moveDot;
        private Material captureDot;
        private Material ivoryPiece;
        private Material blackPiece;
        private Material goldTrim;
        private Material woodFrame;

        private Vector2Int? selected;
        private List<ChessMove> selectedMoves = new();
        private bool whiteToMove = true;
        private bool animating;
        private int capturedByWhite;
        private int capturedByBlack;
        private string status = "Your move";
        private GUIStyle statusStyle;

        [SerializeField] private int aiDepth = 3;
        [SerializeField] private float moveSeconds = 0.20f;
        [SerializeField] private float boardLift = 0.04f;

        private void Awake()
        {
            Application.targetFrameRate = 120;
            QualitySettings.vSyncCount = 0;
            QualitySettings.antiAliasing = 4;
            CreateMaterials();
            CreateSceneRig();
            CreateBoard();
            ResetGame();
        }

        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.R))
            {
                ResetGame();
            }

            if (animating || !whiteToMove)
            {
                return;
            }

            if (Input.GetMouseButtonUp(0))
            {
                TrySelectFromScreen(Input.mousePosition);
            }

            if (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Ended)
            {
                TrySelectFromScreen(Input.GetTouch(0).position);
            }
        }

        private void OnGUI()
        {
            statusStyle ??= CreateStatusStyle();
            float panelWidth = Mathf.Clamp(Screen.width - 36f, 220f, 420f);
            Rect panel = new(18f, 18f, panelWidth, 54f);
            Color oldColor = GUI.color;
            GUI.color = new Color(0.07f, 0.045f, 0.028f, 0.78f);
            GUI.DrawTexture(panel, Texture2D.whiteTexture);
            GUI.color = oldColor;
            GUI.Label(new Rect(panel.x + 18f, panel.y + 13f, panel.width - 36f, panel.height - 16f), status.ToUpperInvariant(), statusStyle);
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

        private void TrySelectFromScreen(Vector3 screenPosition)
        {
            Ray ray = Camera.main.ScreenPointToRay(screenPosition);
            if (!Physics.Raycast(ray, out RaycastHit hit, 100f))
            {
                return;
            }

            SquareMarker marker = hit.collider.GetComponent<SquareMarker>();
            if (marker == null)
            {
                return;
            }

            Vector2Int square = new(marker.File, marker.Rank);
            HandleSquare(square);
        }

        private void HandleSquare(Vector2Int square)
        {
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

            char captured = ApplyMoveToBoard(move);
            RecordCapture(captured);
            yield return AnimateMove(move, captured);
            if (move.Promotion)
            {
                ReplacePromotedPiece(move);
            }

            if (IsCheckmate(!whiteToMove))
            {
                status = playerMove ? "Checkmate secured" : "Checkmated";
                animating = false;
                yield break;
            }

            if (GenerateLegalMoves(!whiteToMove).Count == 0)
            {
                status = "Stalemate";
                animating = false;
                yield break;
            }

            whiteToMove = !whiteToMove;
            status = whiteToMove ? "Your move" : "Engine thinking";
            animating = false;

            if (!whiteToMove)
            {
                yield return new WaitForSeconds(0.10f);
                ChessMove aiMove = ChooseAiMove();
                yield return PlayMove(aiMove, false);
            }
        }

        private IEnumerator AnimateMove(ChessMove move, char captured)
        {
            if (!pieceObjects.TryGetValue(move.From, out GameObject mover))
            {
                yield break;
            }

            GameObject capturedObject = null;
            if (captured != '\0' && pieceObjects.TryGetValue(move.To, out capturedObject))
            {
                pieceObjects.Remove(move.To);
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

            if (capturedObject != null)
            {
                Vector3 tray = CaptureTrayPosition(IsWhite(captured));
                yield return AnimateCapture(capturedObject, tray);
            }
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
                char captured = ApplyMoveToBoard(move);
                int score = -Search(aiDepth - 1, int.MinValue + 1, int.MaxValue - 1, true);
                UndoMove(move, captured);
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
                char captured = ApplyMoveToBoard(move);
                int score = -Search(depth - 1, -beta, -alpha, !white);
                UndoMove(move, captured);
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
                    int sign = IsWhite(piece) == forWhite ? 1 : -1;
                    score += sign * (value + center);
                }
            }
            return score;
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
                char captured = ApplyMoveToBoard(move);
                bool illegal = IsKingInCheck(white);
                UndoMove(move, captured);
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
                    foreach (Vector2Int step in KingSteps)
                    {
                        TryAddMove(from, from + step, white, moves);
                    }
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
            }
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

        private char ApplyMoveToBoard(ChessMove move)
        {
            char piece = board[move.From.x, move.From.y];
            char captured = board[move.To.x, move.To.y];
            board[move.From.x, move.From.y] = '\0';
            board[move.To.x, move.To.y] = move.Promotion ? (IsWhite(piece) ? 'Q' : 'q') : piece;
            return captured;
        }

        private void UndoMove(ChessMove move, char captured)
        {
            char piece = board[move.To.x, move.To.y];
            board[move.To.x, move.To.y] = captured;
            board[move.From.x, move.From.y] = move.Promotion ? (IsWhite(piece) ? 'P' : 'p') : piece;
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
            foreach (GameObject captured in capturedObjects)
            {
                Destroy(captured);
            }
            capturedObjects.Clear();
        }

        private void ReplacePromotedPiece(ChessMove move)
        {
            if (pieceObjects.TryGetValue(move.To, out GameObject pawn))
            {
                Destroy(pawn);
            }
            pieceObjects[move.To] = CreatePiece(board[move.To.x, move.To.y], move.To);
        }

        private void CreateMaterials()
        {
            lightSquare = NewMat("Ivory square", new Color(0.82f, 0.71f, 0.54f), 0.38f, 0.24f);
            darkSquare = NewMat("Walnut square", new Color(0.34f, 0.21f, 0.12f), 0.28f, 0.18f);
            selectedSquare = NewMat("Selected square", new Color(1.0f, 0.68f, 0.25f), 0.25f, 0.35f);
            moveDot = NewMat("Move dot", new Color(0.95f, 0.67f, 0.25f), 0.18f, 0.40f);
            captureDot = NewMat("Capture dot", new Color(1.0f, 0.26f, 0.14f), 0.22f, 0.50f);
            ivoryPiece = NewMat("Ivory piece", new Color(1.0f, 0.86f, 0.55f), 0.62f, 0.34f);
            blackPiece = NewMat("Obsidian piece", new Color(0.05f, 0.04f, 0.035f), 0.70f, 0.48f);
            goldTrim = NewMat("Gold trim", new Color(1.0f, 0.64f, 0.22f), 0.45f, 0.38f);
            woodFrame = NewMat("Wood frame", new Color(0.39f, 0.22f, 0.11f), 0.34f, 0.20f);
        }

        private Material NewMat(string name, Color color, float metallic, float smoothness)
        {
            Material material = new(Shader.Find("Standard"))
            {
                name = name,
                color = color
            };
            material.SetFloat("_Metallic", metallic);
            material.SetFloat("_Glossiness", smoothness);
            return material;
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
            cam.transform.position = new Vector3(3.5f, 8.4f, -7.0f);
            cam.transform.rotation = Quaternion.Euler(58f, 0f, 0f);
            cam.orthographic = true;
            cam.orthographicSize = 5.25f;
            cam.clearFlags = CameraClearFlags.SolidColor;
            cam.backgroundColor = new Color(0.055f, 0.042f, 0.032f);

            RenderSettings.ambientLight = new Color(0.44f, 0.36f, 0.26f);
            RenderSettings.fog = true;
            RenderSettings.fogColor = new Color(0.055f, 0.042f, 0.032f);
            RenderSettings.fogDensity = 0.018f;

            GameObject lightObject = new("Key Light");
            Light light = lightObject.AddComponent<Light>();
            light.type = LightType.Directional;
            light.intensity = 1.12f;
            light.shadows = LightShadows.Soft;
            lightObject.transform.rotation = Quaternion.Euler(48f, -38f, 18f);
        }

        private void CreateBoard()
        {
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

            CreateFramePiece("North Rail", new Vector3(3.5f, -0.02f, 8.08f), new Vector3(9.2f, 0.24f, 0.34f));
            CreateFramePiece("South Rail", new Vector3(3.5f, -0.02f, -1.08f), new Vector3(9.2f, 0.24f, 0.34f));
            CreateFramePiece("West Rail", new Vector3(-1.08f, -0.02f, 3.5f), new Vector3(0.34f, 0.24f, 9.2f));
            CreateFramePiece("East Rail", new Vector3(8.08f, -0.02f, 3.5f), new Vector3(0.34f, 0.24f, 9.2f));
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

        private GameObject CreatePiece(char piece, Vector2Int square)
        {
            GameObject root = new($"Piece {piece} {SquareName(square.x, square.y)}");
            root.transform.SetParent(transform);
            root.transform.position = BoardToWorld(square);
            Material material = IsWhite(piece) ? ivoryPiece : blackPiece;
            CreatePrimitive(root, PrimitiveType.Cylinder, new Vector3(0f, 0.08f, 0f), new Vector3(0.44f, 0.08f, 0.44f), material);
            CreatePrimitive(root, PrimitiveType.Cylinder, new Vector3(0f, 0.22f, 0f), new Vector3(0.30f, 0.18f, 0.30f), material);

            switch (char.ToLowerInvariant(piece))
            {
                case 'p':
                    CreatePrimitive(root, PrimitiveType.Sphere, new Vector3(0f, 0.48f, 0f), new Vector3(0.33f, 0.33f, 0.33f), material);
                    break;
                case 'n':
                    GameObject knight = CreatePrimitive(root, PrimitiveType.Capsule, new Vector3(0.02f, 0.48f, 0.02f), new Vector3(0.28f, 0.38f, 0.24f), material);
                    knight.transform.localRotation = Quaternion.Euler(18f, 0f, -20f);
                    CreatePrimitive(root, PrimitiveType.Cube, new Vector3(0.11f, 0.66f, -0.04f), new Vector3(0.20f, 0.16f, 0.18f), material);
                    break;
                case 'b':
                    CreatePrimitive(root, PrimitiveType.Sphere, new Vector3(0f, 0.50f, 0f), new Vector3(0.34f, 0.42f, 0.34f), material);
                    CreatePrimitive(root, PrimitiveType.Cube, new Vector3(0f, 0.72f, 0f), new Vector3(0.07f, 0.24f, 0.07f), goldTrim);
                    break;
                case 'r':
                    CreatePrimitive(root, PrimitiveType.Cylinder, new Vector3(0f, 0.52f, 0f), new Vector3(0.34f, 0.30f, 0.34f), material);
                    CreatePrimitive(root, PrimitiveType.Cube, new Vector3(0f, 0.74f, 0f), new Vector3(0.48f, 0.12f, 0.48f), material);
                    break;
                case 'q':
                    CreatePrimitive(root, PrimitiveType.Sphere, new Vector3(0f, 0.52f, 0f), new Vector3(0.38f, 0.38f, 0.38f), material);
                    for (int i = 0; i < 5; i++)
                    {
                        float angle = i * Mathf.PI * 2f / 5f;
                        CreatePrimitive(root, PrimitiveType.Sphere, new Vector3(Mathf.Cos(angle) * 0.20f, 0.79f, Mathf.Sin(angle) * 0.20f), new Vector3(0.11f, 0.11f, 0.11f), goldTrim);
                    }
                    break;
                case 'k':
                    CreatePrimitive(root, PrimitiveType.Sphere, new Vector3(0f, 0.50f, 0f), new Vector3(0.36f, 0.36f, 0.36f), material);
                    CreatePrimitive(root, PrimitiveType.Cube, new Vector3(0f, 0.80f, 0f), new Vector3(0.08f, 0.34f, 0.08f), goldTrim);
                    CreatePrimitive(root, PrimitiveType.Cube, new Vector3(0f, 0.88f, 0f), new Vector3(0.28f, 0.07f, 0.07f), goldTrim);
                    break;
            }
            return root;
        }

        private GameObject CreatePrimitive(GameObject parent, PrimitiveType type, Vector3 localPosition, Vector3 localScale, Material material)
        {
            GameObject child = GameObject.CreatePrimitive(type);
            child.transform.SetParent(parent.transform);
            child.transform.localPosition = localPosition;
            child.transform.localScale = localScale;
            child.GetComponent<Renderer>().sharedMaterial = material;
            Collider collider = child.GetComponent<Collider>();
            if (collider != null)
            {
                Destroy(collider);
            }
            return child;
        }

        private void RefreshTileSelection()
        {
            foreach ((Vector2Int square, Renderer renderer) in tileRenderers)
            {
                renderer.sharedMaterial = selected.HasValue && selected.Value == square
                    ? selectedSquare
                    : ((square.x + square.y) & 1) == 0 ? darkSquare : lightSquare;
            }
        }

        private void DrawMoveMarkers(List<ChessMove> moves)
        {
            foreach (ChessMove move in moves)
            {
                bool capture = board[move.To.x, move.To.y] != '\0';
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
            foreach (GameObject marker in moveMarkers)
            {
                Destroy(marker);
            }
            moveMarkers.Clear();
        }

        private Vector3 BoardToWorld(Vector2Int square)
        {
            return new Vector3(square.x, 0.08f, square.y);
        }

        private Vector3 CaptureTrayPosition(bool capturedPieceWasWhite)
        {
            int count = Mathf.Max(0, (capturedPieceWasWhite ? capturedByBlack : capturedByWhite) - 1);
            float x = capturedPieceWasWhite ? -0.78f : 7.78f;
            float z = 0.15f + (count % 8) * 0.48f;
            float layer = count / 8 * 0.12f;
            return new Vector3(x, 0.12f + layer, z);
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
            char captured = board[move.To.x, move.To.y];
            if (captured != '\0')
            {
                score += 1000 + PieceValue(captured) * 8 - PieceValue(board[move.From.x, move.From.y]);
            }
            if (move.Promotion)
            {
                score += 900;
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
        public ChessMove(Vector2Int from, Vector2Int to, bool promotion)
        {
            From = from;
            To = to;
            Promotion = promotion;
        }

        public Vector2Int From { get; }
        public Vector2Int To { get; }
        public bool Promotion { get; }
    }
}
