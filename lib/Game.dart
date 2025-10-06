import 'package:devmobile/AnimatedTiles.dart';
import 'dart:async';
import 'EndGamePopUp.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:devmobile/grid-properties.dart';

class TileWidgetWithImage extends StatelessWidget {
  final double x;
  final double y;
  final double containerSize;
  final double size;
  final Color color;
  final int number;
  final String? imagePath;
  final bool isBlocked;

  const TileWidgetWithImage({
    super.key,
    required this.x,
    required this.y,
    required this.containerSize,
    required this.size,
    required this.color,
    required this.number,
    this.imagePath,
    this.isBlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: isBlocked ? 0.5 : 1,
        child: Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: isBlocked ? Colors.grey : color,
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          child: Stack(
            children: [
              if (imagePath != null)
                Center(
                  child: Image.asset(
                    imagePath!,
                    width: size * 0.8,
                    height: size * 0.8,
                    fit: BoxFit.contain,
                  ),
                ),
              if (number > 0)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Text(
                    number.toString(),
                    style: TextStyle(
                      color: numTextColor[number] ?? Colors.white,
                      fontSize: size * 0.25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum SwipeDirection { up, down, left, right }

class GameState {
  final List<List<AnimatedTiles>> _previousGrid;
  final SwipeDirection swipe;

  GameState(List<List<AnimatedTiles>> previousGrid, this.swipe) : _previousGrid = previousGrid;

  List<List<AnimatedTiles>> get previousGrid =>
      _previousGrid.map((row) => row.map((tile) => tile.copy()).toList()).toList();
}

class TwentyFortyEight extends StatefulWidget {
  const TwentyFortyEight({super.key});

  @override
  TwentyFortyEightState createState() => TwentyFortyEightState();
}

class TwentyFortyEightState extends State<TwentyFortyEight> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  List<List<AnimatedTiles>> grid =
  List.generate(4, (y) => List.generate(4, (x) => AnimatedTiles(x, y, 0)));
  List<GameState> gameStates = [];
  List<AnimatedTiles> toAdd = [];
  int? blockedRow;
  int? blockedCol;
  bool pitStopToggle = true; // pour activer le pitstop une fois sur deux

  String? eventMessage;
  bool _isInputLocked = false;
  Iterable<AnimatedTiles> get gridTiles => grid.expand((e) => e);
  Iterable<AnimatedTiles> get allTiles => [gridTiles, toAdd].expand((e) => e);
  List<List<AnimatedTiles>> get gridCols =>
      List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));

  Timer? aiTimer;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          for (final e in toAdd) {
            grid[e.y][e.x].value = e.value;
          }
          for (final t in gridTiles) {
            t.resetAnimations();
          }
          toAdd.clear();
          int number = 0;
          number=Random().nextInt(10);
          if(number==4){
            redFlag(grid);
          }
          if(number==2){
            pitStop();
          }
          if(number==1){
            yellowFlag();
          }
          if (isGameOver(grid)){
            Future.delayed(const Duration(milliseconds: 300), (){
              _showDialog(context);
            });
          }
        });
      }
    });

    setupNewGame();
  }

  @override
  void dispose() {
    controller.dispose();
    aiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    final double baseSize = screenWidth < screenHeight ? screenWidth : screenHeight;


    final double contentPadding = baseSize * 0.02;
    final double borderSize = baseSize * 0.004;



    final double gridSize = MediaQuery
        .of(context)
        .size
        .width - contentPadding * 2;
    final double tileSize = (gridSize - borderSize * 2) / 4;
    List<Widget> stackItems = [];


    stackItems.addAll(gridTiles.map((t) =>
        TileWidget(
          x: tileSize * t.x,
          y: tileSize * t.y,
          containerSize: tileSize,
          size: tileSize - borderSize * 2,
          color: gridLine,
          child: const SizedBox(),
        )));

    stackItems.addAll(allTiles.map((tile) {
      bool isBlocked = (blockedRow == tile.y) || (blockedCol == tile.x);
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) =>
        tile.animatedValue.value == 0
            ? const SizedBox()
            : TileWidgetWithImage(
          x: tileSize * tile.animatedX.value,
          y: tileSize * tile.animatedY.value,
          containerSize: tileSize,
          size: tileSize - borderSize * 2,
          color: numTileColor[tile.animatedValue.value] ?? Colors.grey,
          number: tile.animatedValue.value,
          imagePath: "assets/img/ecurie_${tile.animatedValue.value}.png",
          isBlocked: isBlocked,
        ),
      );
    }));

    return Scaffold(
      backgroundColor: Background,
      body: Stack(
        children: [
          // Contenu principal
          Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/img/f1_logo.png",
                  height: baseSize*0.3,
                ),
                SizedBox(height: baseSize*0.01),
                Text(
                  "2048",
                  style: TextStyle(
                    fontFamily: "Formula1",
                    fontSize: baseSize*0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: baseSize*0.02),
                Swiper(
                  up: () => !_isInputLocked ? merge(SwipeDirection.up) : null,
                  down: () =>
                  !_isInputLocked
                      ? merge(SwipeDirection.down)
                      : null,
                  left: () =>
                  !_isInputLocked
                      ? merge(SwipeDirection.left)
                      : null,
                  right: () =>
                  !_isInputLocked
                      ? merge(SwipeDirection.right)
                      : null,
                  child: Container(
                    height: gridSize,
                    width: gridSize,
                    padding: EdgeInsets.all(borderSize),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(cornerRadius),
                      color: gridBackground,
                    ),
                    child: Stack(children: stackItems),
                  ),
                ),
                SizedBox(height: baseSize*0.03),
                if (eventMessage != null) ...[
                  SizedBox(height: baseSize*0.02),
                  AnimatedOpacity(
                    opacity: eventMessage != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        Text(
                          "🏁 Fait de course ! 🏁",
                          style: TextStyle(
                            fontFamily: "Formula1",
                            fontSize: baseSize*0.04,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: baseSize*0.04),
                        Text(
                          eventMessage!,
                          style: TextStyle(
                            fontFamily: "Formula1",
                            fontSize: baseSize*0.04,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bouton Home en haut à gauche
          Positioned(
            top: baseSize*0.02,
            left: baseSize*0.02,
            child: IconButton(
              icon: Icon(Icons.home, color: Colors.black, size:baseSize*0.06),
              onPressed: () {
                Navigator.pop(context);
              },
              tooltip: "Retour au menu",
            ),
          ),
        ],
      ),
    );
  }

    void pitStop() {

    var random = Random();
    bool blockRowFlag = random.nextBool();
    if (blockRowFlag) {

      blockedRow = random.nextInt(4);
      blockedCol = null;
      setState(() {
        _isInputLocked = true;
        eventMessage = "🏎 PitStop! Ligne ${blockedRow!+1} bloquée pour le prochain coup!";
      });

    } else {
      blockedCol = random.nextInt(4);
      blockedRow = null;
      setState(() {
        _isInputLocked = true;
        eventMessage = "🏎 PitStop! Colonne ${blockedCol!+1} bloquée pour le prochain coup!";
      });
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          eventMessage = null;
          _isInputLocked = false;
        });
      }
    });
  }

  void yellowFlag() {

    final List<AnimatedTiles> candidates = gridTiles.where((t) => t.value > 2).toList();
    if (candidates.isEmpty) return;
    setState(() {
      _isInputLocked = true;
    });
    final tile = candidates[Random().nextInt(candidates.length)];
    setState(() {
      tile.value = tile.value ~/ 2;
      tile.changeNumber(controller, tile.value);
      tile.bounce(controller);
    });
    setState(() {

      eventMessage = "DRAPEAU JAUNE : tuile (${tile.x}, ${tile.y}) est divisé par 2 ! -> ${tile.value} !";
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          eventMessage = null;
          _isInputLocked = false;
        });
      }
    });

  }

  void undoMove() {
    final GameState previousState = gameStates.removeLast();
    late bool Function() mergeFn;
    switch (previousState.swipe) {
      case SwipeDirection.up:
        mergeFn = mergeUp;
        break;
      case SwipeDirection.down:
        mergeFn = mergeDown;
        break;
      case SwipeDirection.left:
        mergeFn = mergeLeft;
        break;
      case SwipeDirection.right:
        mergeFn = mergeRight;
        break;
    }
    setState(() {
      this.grid = previousState.previousGrid;
      mergeFn();
      controller.reverse(from: .99).then((_) {
        setState(() {
          this.grid = previousState.previousGrid;
          for (final t in gridTiles) {
            t.resetAnimations();
          }
        });
      });
    });
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(30,30,48,1),
          title: const Center(
            child: Text(
              "C'est la défaite",
              style: TextStyle(
                fontFamily: "Formula1",
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          content: SizedBox(
            width: 500,
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Image.asset(
                  'assets/img/alonso.jpg',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height:20),

                const Text(
                  "Engine feels good, much slower than before",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ]

              ),
            ),

          actions: [
            MaterialButton(
              child: const Text(
                  "OK",
                  style: TextStyle(
                  color: Colors.white
                  )
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void merge(SwipeDirection direction) {
    late bool Function() mergeFn;
    switch (direction) {
      case SwipeDirection.up:
        mergeFn = mergeUp;
        break;
      case SwipeDirection.down:
        mergeFn = mergeDown;
        break;
      case SwipeDirection.left:
        mergeFn = mergeLeft;
        break;
      case SwipeDirection.right:
        mergeFn = mergeRight;
        break;
    }


    final List<List<AnimatedTiles>> gridBeforeSwipe =
    grid.map((row) => row.map((tile) => tile.copy()).toList()).toList();

    setState(() {
      if (mergeFn()) {
        gameStates.add(GameState(gridBeforeSwipe, direction));
        addNewTiles([2]);
        controller.forward(from: 0);

        // Débloque la ligne ou colonne après le mouvement
        blockedRow = null;
        blockedCol = null;
      }
    });
  }

  bool mergeLeft() => grid.map((e) => mergeTiles(e)).toList().any((e) => e);

  bool mergeRight() => grid.map((e) => mergeTiles(e.reversed.toList())).toList().any((e) => e);

  bool mergeUp() => gridCols.map((e) => mergeTiles(e)).toList().any((e) => e);

  bool mergeDown() => gridCols.map((e) => mergeTiles(e.reversed.toList())).toList().any((e) => e);

  bool mergeTiles(List<AnimatedTiles> tiles) {
    bool didChange = false;
    for (int i = 0; i < tiles.length; i++) {
      if ((blockedRow != null && tiles[i].y == blockedRow) ||
          (blockedCol != null && tiles[i].x == blockedCol)) continue;

      for (int j = i; j < tiles.length; j++) {
        if ((blockedRow != null && tiles[j].y == blockedRow) ||
            (blockedCol != null && tiles[j].x == blockedCol)) continue;

        if (tiles[j].value != 0) {
          int k = tiles.indexWhere((t) => t.value != 0 &&
              !((blockedRow != null && t.y == blockedRow) ||
                  (blockedCol != null && t.x == blockedCol)), j + 1);

          AnimatedTiles? mergeTile = (k != -1) ? tiles[k] : null;

          if (mergeTile != null && mergeTile.value != tiles[j].value) {
            mergeTile = null;
          }

          if (i != j || mergeTile != null) {
            didChange = true;
            int resultValue = tiles[j].value;
            tiles[j].moveTo(controller, tiles[i].x, tiles[i].y);
            if (mergeTile != null) {
              resultValue += mergeTile.value;
              mergeTile.moveTo(controller, tiles[i].x, tiles[i].y);
              mergeTile.bounce(controller);
              mergeTile.changeNumber(controller, resultValue);
              mergeTile.value = 0;
              tiles[j].changeNumber(controller, 0);
            }
            tiles[j].value = 0;
            tiles[i].value = resultValue;
          }
          break;
        }
      }
    }
    return didChange;
  }

  void addNewTiles(List<int> values) {
    final List<AnimatedTiles> empty = gridTiles.where((t) => t.value == 0).toList();
    empty.shuffle();
    for (int i = 0; i < values.length; i++) {
      toAdd.add(AnimatedTiles(empty[i].x, empty[i].y, values[i])..appear(controller));
    }
  }

  void redFlag(List<List<AnimatedTiles>> grid){
      setState(() {
        _isInputLocked = true;
        eventMessage = "💥 Crash entre coéquipiers! Une écurie est éliminée !";
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            eventMessage = null;
          });
        }

      var random = Random();
      int randomI = random.nextInt(4);
      int randomJ = random.nextInt(4);
      bool ok = false;
      while (!ok) {
        final tile = grid[randomI][randomJ];
        if (tile.value != 0) {
          setState(() {
            tile.value = 0;
            tile.changeNumber(controller, 0);
            tile.resetAnimations();

            eventMessage = "💥 Crash entre coéquipiers! Une écurie est éliminée !";
          });

          ok = true;
        } else {
          randomI = random.nextInt(4);
          randomJ = random.nextInt(4);
        }
      }
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              eventMessage = null;
              _isInputLocked = false;
            });
          }
        });
      });

  }

  bool isGameOver(List<List<AnimatedTiles>> grid) {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j].value == 0) {
          return false;
        }
        if (i > 0 && grid[i][j].value == grid[i - 1][j].value) {
          return false;
        }
        if (i < 3 && grid[i][j].value == grid[i + 1][j].value) {
          return false;

        }
        if (j > 0 && grid[i][j].value == grid[i][j - 1].value) {
          return false;

        }
        if (j < 3 && grid[i][j].value == grid[i][j + 1].value)
        {
          return false;
        }
      }
    }
    return true;
  }

  void setupNewGame() {
    setState(() {
      gameStates.clear();
      for (final t in gridTiles) {
        t.value = 0;
        t.resetAnimations();
      }
      toAdd.clear();
      blockedRow = null;
      blockedCol = null;
      pitStopToggle = true;
      addNewTiles([2, 2]);
      controller.forward(from: 0);
    });
  }
}
