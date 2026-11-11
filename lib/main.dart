import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // تأكد من إضافة مكتبة url_launcher
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const SeegaGame());
}

class SeegaGame extends StatelessWidget {
  const SeegaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لعبة السيجا',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/nubax.png'),
      ),
    );
  }
}

class GameHomePage extends StatefulWidget {
  const GameHomePage({super.key});

  @override
  _GameHomePageState createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  bool isArabic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'لعبة السيجا' : 'Seega Game'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isArabic = !isArabic;
              });
            },
            child: Text(
              isArabic ? 'EN' : 'AR',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Image.asset('assets/seja.png', width: 150, height: 100),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GridSizeSelectionPage(isArabic: isArabic)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 50, 209, 169),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(isArabic ? 'ابدأ اللعبة' : 'Start Game'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(isArabic ? "طريقة اللعب" : "How to Play"),
                          content: Text(
                            isArabic
                                ? "اضغط على الحجر لتحديده، ثم على المكان الذي تريد التحرك إليه."
                                : "Tap a stone to select it, then tap the target location to move.",
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text(isArabic ? "إغلاق" : "Close"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(isArabic ? 'طريقة اللعب' : 'How to Play'),
                ),
                const SizedBox(height: 60),
                GestureDetector(
                  onTap: () {
                    _launchURL();
                  },
                  child: Image.asset(
                    'assets/tiktok.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ],
            ),

            // إضافة الأيقونة "!" في أعلى يسار الصفحة
Positioned(
  left: 50,
  top: 490, // يمكنك تعديل هذه القيمة حسب المكان المطلوب
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GameInfoPage()),
      );
    },
    child: Container(
      width: 80, // عرض المستطيل
      height: 40, // ارتفاع المستطيل
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: const Color.fromARGB(255, 119, 98, 6), 
      ),
                  padding: const EdgeInsets.all(6),
                  child: const Text(
                    'عن اللعبة',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL() async {
    const url = 'https://www.tiktok.com/@nubax';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// صفحة معلومات اللعبة
class GameInfoPage extends StatelessWidget {
  const GameInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات اللعبة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'هذه هي معلومات اللعبة...',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _launchEmail();
              },
              child: const Text('اتصل بنا'),
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'nubaaxx@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'استفسار عن اللعبة',
      }),
    );
    await launch(emailLaunchUri.toString());
  }

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
  }
}

class GridSizeSelectionPage extends StatelessWidget {
  final bool isArabic;

  const GridSizeSelectionPage({super.key, required this.isArabic});

  void _chooseStones(BuildContext context, int gridSize) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              StoneSelectionPage(isArabic: isArabic, gridSize: gridSize)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'اختر حجم اللوحة' : 'Choose Board Size'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _chooseStones(context, 5),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                textStyle: const TextStyle(fontSize: 24, color: Colors.white),
              ),
              child: Text(isArabic ? "5x5 لوحة" : "Board 5x5"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _chooseStones(context, 7),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                textStyle: const TextStyle(fontSize: 24, color: Colors.white),
              ),
              child: Text(isArabic ? "7x7 لوحة" : "Board 7x7"),
            ),
          ],
        ),
      ),
    );
  }
}

class StoneSelectionPage extends StatefulWidget {
  final bool isArabic;
  final int gridSize;

  const StoneSelectionPage(
      {super.key, required this.isArabic, required this.gridSize});

  @override
  _StoneSelectionPageState createState() => _StoneSelectionPageState();
}

class _StoneSelectionPageState extends State<StoneSelectionPage> {
  String? playerOneStone;
  String? playerTwoStone;

  final List<String> stoneAssets = [
    'assets/blue_stone.png',
    'assets/brown_stone.png',
    'assets/green_stone.png',
    'assets/red_stone.png',
    'assets/turquoise_stone.png',
    'assets/yellow_stone.png',
    'assets/gray_stone.png',
  ];

  void _selectStone(String stone, bool isPlayerOne) {
    setState(() {
      if (isPlayerOne) {
        if (playerTwoStone != stone) playerOneStone = stone;
      } else {
        if (playerOneStone != stone) playerTwoStone = stone;
      }
    });
  }

  void _startGame() {
    if (playerOneStone != null && playerTwoStone != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GamePage(
            isArabic: widget.isArabic,
            gridSize: widget.gridSize,
            playerOneStone: playerOneStone!,
            playerTwoStone: playerTwoStone!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isArabic ? 'اختر الأحجار' : 'Choose Stones'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.isArabic
                ? 'اختر حجر اللاعب 1'
                : 'Choose Player 1 Stone'),
            Wrap(
              children: stoneAssets.map((stone) {
                return GestureDetector(
                  onTap: () => _selectStone(stone, true),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: playerOneStone == stone
                            ? Colors.blue
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Image.asset(stone, width: 50, height: 50),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(widget.isArabic
                ? 'اختر حجر اللاعب 2'
                : 'Choose Player 2 Stone'),
            Wrap(
              children: stoneAssets.map((stone) {
                return GestureDetector(
                  onTap: () => _selectStone(stone, false),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: playerTwoStone == stone
                            ? Colors.red
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Image.asset(stone, width: 50, height: 50),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 4, 214, 151),
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                textStyle: const TextStyle(
                    fontSize: 20, color: Color.fromARGB(255, 243, 14, 14)),
              ),
              child: Text(widget.isArabic ? 'ابدأ اللعب' : 'Start Playing'),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final bool isArabic;
  final int gridSize;
  final String playerOneStone;
  final String playerTwoStone;

  const GamePage({
    super.key,
    required this.isArabic,
    required this.gridSize,
    required this.playerOneStone,
    required this.playerTwoStone,
  });

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late List<List<String?>> board;
  bool isPlayerOneTurn = true;
  late int playerOneStones;
  late int playerTwoStones;
  int stonesToPlace = 3;
  bool placingPhase = true;
  int? selectedRow;
  int? selectedCol;
  int capturedYellowStones = 0;
  int capturedGrayStones = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    board = List.generate(
        widget.gridSize, (_) => List.filled(widget.gridSize, null));
    playerOneStones = widget.gridSize == 5 ? 12 : 24;
    playerTwoStones = playerOneStones;
  }

  void playMoveSound() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/move.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing move sound: $e');
    }
  }

  void playEatSound() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/eat.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing eat sound: $e');
    }
  }

  void _setFirstPlayer() {
    if (_hasAvailableMoves(true)) {
      isPlayerOneTurn = true;
    } else if (_hasAvailableMoves(false)) {
      isPlayerOneTurn = false;
    }
  }

  void _onTileTap(int i, int j) async {
    setState(() {
      if (placingPhase &&
          board[i][j] == null &&
          !(i == widget.gridSize ~/ 2 && j == widget.gridSize ~/ 2)) {
        if (isPlayerOneTurn && playerOneStones > 0) {
          board[i][j] = 'O';
          playerOneStones--;
        } else if (!isPlayerOneTurn && playerTwoStones > 0) {
          board[i][j] = 'X';
          playerTwoStones--;
        }

        stonesToPlace--;
        if (stonesToPlace == 0) {
          stonesToPlace = 3;
          isPlayerOneTurn = !isPlayerOneTurn;
        }

        if (playerOneStones == 0 && playerTwoStones == 0) {
          placingPhase = false;
          _setFirstPlayer();
        }
      } else if (!placingPhase) {
        if (selectedRow == null && selectedCol == null) {
          if (board[i][j] != null &&
              ((isPlayerOneTurn && board[i][j] == 'O') ||
                  (!isPlayerOneTurn && board[i][j] == 'X'))) {
            selectedRow = i;
            selectedCol = j;
          }
        } else {
          if (_isValidMove(selectedRow!, selectedCol!, i, j)) {
            String movingStone = board[selectedRow!][selectedCol!]!;
            board[i][j] = movingStone;
            board[selectedRow!][selectedCol!] = null;

            playMoveSound();

            bool captured = _capture(i, j, movingStone);
            if (captured) {
              playEatSound();
            }

            selectedRow = null;
            selectedCol = null;

            isPlayerOneTurn = !isPlayerOneTurn;

            if (!_hasAvailableMoves(isPlayerOneTurn)) {
              isPlayerOneTurn = !isPlayerOneTurn;
            }
          } else {
            selectedRow = null;
            selectedCol = null;
          }
        }
      }

      if (!placingPhase && _checkVictory()) {
        _showVictoryDialog(isPlayerOneTurn ? 'X' : 'O');
      }
    });
  }

  bool _isValidMove(int fromRow, int fromCol, int toRow, int toCol) {
    if (board[toRow][toCol] != null) return false;
    if ((fromRow - toRow).abs() + (fromCol - toCol).abs() == 1) return true;
    return false;
  }

  bool _capture(int row, int col, String movingStone) {
    String opponentStone = movingStone == 'X' ? 'O' : 'X';
    bool capturedAny = false;

    capturedAny |=
        _checkAndCapture(row, col, movingStone, opponentStone, 0, 1); // Right
    capturedAny |=
        _checkAndCapture(row, col, movingStone, opponentStone, 0, -1); // Left
    capturedAny |=
        _checkAndCapture(row, col, movingStone, opponentStone, 1, 0); // Down
    capturedAny |=
        _checkAndCapture(row, col, movingStone, opponentStone, -1, 0); // Up

    return capturedAny;
  }

  bool _checkAndCapture(int row, int col, String movingStone,
      String opponentStone, int rowDir, int colDir) {
    int newRow1 = row + rowDir;
    int newCol1 = col + colDir;
    int newRow2 = newRow1 + rowDir;
    int newCol2 = newCol1 + colDir;

    if (_isInBounds(newRow1, newCol1) &&
        board[newRow1][newCol1] == opponentStone &&
        _isInBounds(newRow2, newCol2) &&
        board[newRow2][newCol2] == movingStone) {
      setState(() {
        board[newRow1][newCol1] = null;
        if (opponentStone == 'O') {
          capturedYellowStones++;
        } else {
          capturedGrayStones++;
        }
      });
      return true;
    }
    return false;
  }

  bool _isInBounds(int row, int col) {
    return row >= 0 &&
        row < widget.gridSize &&
        col >= 0 &&
        col < widget.gridSize;
  }

  bool _checkVictory() {
    int playerOneCount = 0;
    int playerTwoCount = 0;
    for (var row in board) {
      for (var cell in row) {
        if (cell == 'O') playerOneCount++;
        if (cell == 'X') playerTwoCount++;
      }
    }
    return playerOneCount == 0 || playerTwoCount == 0;
  }

  void _showVictoryDialog(String winner) {
    String winnerName = isPlayerOneTurn ? 'اللاعب 1' : 'اللاعب 2';
    String winnerStone =
        isPlayerOneTurn ? widget.playerOneStone : widget.playerTwoStone;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.isArabic ? "انتصار!" : "Victory!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.isArabic ? "$winnerName فاز!" : "$winnerName wins!"),
              const SizedBox(height: 10),
              Image.asset(
                winnerStone,
                width: 40,
                height: 40,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(widget.isArabic
                  ? "العودة إلى الصفحة الرئيسية"
                  : "Return to Home"),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  bool _hasAvailableMoves(bool isPlayerOne) {
    String playerStone = isPlayerOne ? 'O' : 'X';
    for (int i = 0; i < widget.gridSize; i++) {
      for (int j = 0; j < widget.gridSize; j++) {
        if (board[i][j] == playerStone) {
          List<List<int>> directions = [
            [0, 1],
            [1, 0],
            [0, -1],
            [-1, 0]
          ];
          for (var direction in directions) {
            int newRow = i + direction[0];
            int newCol = j + direction[1];
            if (_isInBounds(newRow, newCol) && board[newRow][newCol] == null) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(widget.isArabic ? 'تأكيد' : 'Confirm'),
            content: Text(widget.isArabic
                ? 'هل أنت متأكد أنك تريد الخروج من اللعبة؟'
                : 'Are you sure you want to exit the game?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(widget.isArabic ? 'لا' : 'No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(widget.isArabic ? 'نعم' : 'Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isArabic ? 'لوحة اللعبة' : 'Game Board'),
        ),
        body: Column(
          children: [
            _buildPlayerInfo(
              widget.isArabic ? 'اللاعب 2' : 'Player 2',
              widget.playerTwoStone,
              isReversed: true,
              capturedStones: capturedGrayStones,
              totalStones: playerTwoStones,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: 3.14,
                    child: Row(
                      children: [
                        Text(
                          widget.isArabic
                              ? 'الدور: ${isPlayerOneTurn ? 'اللاعب 1' : 'اللاعب 2'}'
                              : 'Turn: ${isPlayerOneTurn ? 'Player 1' : 'Player 2'}',
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          isPlayerOneTurn
                              ? widget.playerOneStone
                              : widget.playerTwoStone,
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
Expanded(
  child: GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: widget.gridSize,
    ),
    itemBuilder: (context, index) {
      int row = index ~/ widget.gridSize;
      int col = index % widget.gridSize;
      bool isSelected = selectedRow == row && selectedCol == col;
      bool isValidMove = selectedRow != null &&
          selectedCol != null &&
          _isValidMove(selectedRow!, selectedCol!, row, col);

      return GestureDetector(
        onTap: () => _onTileTap(row, col),
        child: Container(
          margin: const EdgeInsets.all(3.0),
          color: isSelected
              ? const Color.fromARGB(255, 250, 229, 45).withOpacity(0.7) // تظليل الحجر المحدد
              : isValidMove
                  ? const Color.fromARGB(255, 226, 230, 13).withOpacity(0.5) // تظليل المكان المستهدف
                  : Colors.brown[200], // اللون الافتراضي لباقي المربعات
          child: board[row][col] != null
              ? Image.asset(
                  board[row][col] == 'O'
                      ? widget.playerOneStone
                      : widget.playerTwoStone,
                )
              : null,
        ),
      );
    },
    itemCount: widget.gridSize * widget.gridSize,
  ),
),

            _buildPlayerInfo(
              widget.isArabic ? 'اللاعب 1' : 'Player 1',
              widget.playerOneStone,
              capturedStones: capturedYellowStones,
              totalStones: playerOneStones,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.isArabic
                            ? 'الدور: ${isPlayerOneTurn ? 'اللاعب 1' : 'اللاعب 2'}'
                            : 'Turn: ${isPlayerOneTurn ? 'Player 1' : 'Player 2'}',
                      ),
                      const SizedBox(width: 10),
                      Image.asset(
                        isPlayerOneTurn
                            ? widget.playerOneStone
                            : widget.playerTwoStone,
                        width: 40,
                        height: 40,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(String playerName, String playerStone,
      {bool isReversed = false,
      required int capturedStones,
      required int totalStones}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isReversed) ...[
            Transform.rotate(
              angle: 3.14,
              child: Column(
                children: [
                  Image.asset(playerStone, width: 40, height: 40),
                  Text('$playerName'),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Transform.rotate(
              angle: 3.14,
              child: Text(
                widget.isArabic
                    ? 'الأحجار الملتقطة: $capturedStones | مجموع الأحجار: $totalStones'
                    : 'Captured: $capturedStones | Total: $totalStones',
              ),
            ),
          ] else ...[
            Column(
              children: [
                Text('$playerName'),
                Image.asset(playerStone, width: 40, height: 40),
              ],
            ),
            const SizedBox(width: 10),
            Text(
              widget.isArabic
                  ? 'الأحجار الملتقطة: $capturedStones | مجموع الأحجار: $totalStones'
                  : 'Captured: $capturedStones | Total: $totalStones',
            ),
          ],
        ],
      ),
    );
  }
}
