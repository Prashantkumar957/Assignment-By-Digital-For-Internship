import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<String>> board;
  late String currentPlayer;
  late bool gameOver;
  late String winner;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initGame();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadSounds();
  }

  Future<void> _loadSounds() async {
    await _audioPlayer.setSource(AssetSource('sounds/click.wav'));
    await _audioPlayer.setSource(AssetSource('sounds/win.wav'));
    await _audioPlayer.setSource(AssetSource('sounds/draw.wav'));
  }

  void _initGame() {
    board = List.generate(3, (_) => List.filled(3, ''));
    currentPlayer = 'X';
    gameOver = false;
    winner = '';
  }

  void _makeMove(int row, int col) {
    if (board[row][col] != '' || gameOver) return;

    _playSound('click');

    setState(() {
      board[row][col] = currentPlayer;
      if (_checkWin(row, col)) {
        gameOver = true;
        winner = currentPlayer;
        _confettiController.play();
        _playSound('win');
      } else if (_checkDraw()) {
        gameOver = true;
        _playSound('draw');
      } else {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  bool _checkWin(int row, int col) {
    // Check row
    if (board[row][0] == currentPlayer &&
        board[row][1] == currentPlayer &&
        board[row][2] == currentPlayer) {
      return true;
    }

    // Check column
    if (board[0][col] == currentPlayer &&
        board[1][col] == currentPlayer &&
        board[2][col] == currentPlayer) {
      return true;
    }

    // Check diagonals
    if (row == col &&
        board[0][0] == currentPlayer &&
        board[1][1] == currentPlayer &&
        board[2][2] == currentPlayer) {
      return true;
    }

    if (row + col == 2 &&
        board[0][2] == currentPlayer &&
        board[1][1] == currentPlayer &&
        board[2][0] == currentPlayer) {
      return true;
    }

    return false;
  }

  bool _checkDraw() {
    for (var row in board) {
      if (row.contains('')) return false;
    }
    return true;
  }

  void _resetGame() {
    setState(() {
      _initGame();
    });
  }

  Future<void> _playSound(String sound) async {
    await _audioPlayer.play(AssetSource('sounds/$sound.wav'));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe AI'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  gameOver
                      ? winner != ''
                      ? 'Player $winner wins!'
                      : "It's a draw!"
                      : "Player $currentPlayer's turn",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: List.generate(
                      3,
                          (row) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                              (col) => GestureDetector(
                            onTap: () => _makeMove(row, col),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.deepPurple),
                                color: _getTileColor(row, col),
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    board[row][col],
                                    key: ValueKey('${board[row][col]}$row$col'),
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: board[row][col] == 'X'
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (gameOver)
                  ElevatedButton(
                    onPressed: _resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Play Again',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color? _getTileColor(int row, int col) {
    if (!gameOver || winner == '') return null;

    // Check row
    if (board[row][0] == winner &&
        board[row][1] == winner &&
        board[row][2] == winner) {
      return Colors.deepPurple.withOpacity(0.2);
    }

    // Check column
    if (board[0][col] == winner &&
        board[1][col] == winner &&
        board[2][col] == winner) {
      return Colors.deepPurple.withOpacity(0.2);
    }

    // Check diagonal 1
    if (row == col &&
        board[0][0] == winner &&
        board[1][1] == winner &&
        board[2][2] == winner) {
      return Colors.deepPurple.withOpacity(0.2);
    }

    // Check diagonal 2
    if (row + col == 2 &&
        board[0][2] == winner &&
        board[1][1] == winner &&
        board[2][0] == winner) {
      return Colors.deepPurple.withOpacity(0.2);
    }

    return null;
  }
}