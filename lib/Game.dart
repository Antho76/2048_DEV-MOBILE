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
  final Color color; // fond de la case
  final int number; // valeur numérique
  final String? imagePath; // image optionnelle

  const TileWidgetWithImage({
    super.key,
    required this.x,
    required this.y,
    required this.containerSize,
    required this.size,
    required this.color,
    required this.number,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: color,
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
    );
  }
}

enum SwipeDirection {
  up,
  down,
  left,
  right,
}
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
          if(Random().nextInt(2)==1){
            redFlag(grid);
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
    const double contentPadding = 16;
    const double borderSize = 4;
    final double gridSize = MediaQuery.of(context).size.width - contentPadding * 2;
    final double tileSize = (gridSize - borderSize * 2) / 4;
    List<Widget> stackItems = [];


    stackItems.addAll(gridTiles.map((t) => TileWidget(
      x: tileSize * t.x,
      y: tileSize * t.y,
      containerSize: tileSize,
      size: tileSize - borderSize * 2,
      color: gridLine,
      child: const SizedBox(),
    )));


    stackItems.addAll(allTiles.map((tile) => AnimatedBuilder(
      animation: controller,
      builder: (context, child) => tile.animatedValue.value == 0
          ? const SizedBox()
          : TileWidgetWithImage(
        x: tileSize * tile.animatedX.value,
        y: tileSize * tile.animatedY.value,
        containerSize: tileSize,
        size: tileSize - borderSize * 2,
        color: numTileColor[tile.animatedValue.value] ?? Colors.grey,
        number: tile.animatedValue.value,
        imagePath: "assets/img/ecurie_${tile.animatedValue.value}.png",
      ),
    )));


    return Scaffold(
      backgroundColor: Background, // Fond principal
      body: Padding(
        padding: const EdgeInsets.all(contentPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
              Image.asset(
                "assets/img/f1_logo.png",
                height: 80,
              ),
              const SizedBox(height: 4),
              const Text(
                "2048",
                style: TextStyle(
                  fontFamily: "Formula1",
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            const SizedBox(height: 16), // espace entre l'image et la grille

            // Grille
            Swiper(
              up: () => merge(SwipeDirection.up),
              down: () => merge(SwipeDirection.down),
              left: () => merge(SwipeDirection.left),
              right: () => merge(SwipeDirection.right),
              child: Container(
                height: gridSize,
                width: gridSize,
                padding: const EdgeInsets.all(borderSize),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  color: gridBackground, // couleur de la grille
                ),
                child: Stack(children: stackItems),
              ),
            ),
            const SizedBox(height: 24), // espace entre grille et boutons

            // Boutons
            BigButton(
              label: "Undo",
              color: numColor, // bouton Undo
              onPressed: gameStates.isEmpty ? null : undoMove,
            ),
            const SizedBox(height: 12),
            BigButton(
              label: "Restart",
              color: orange, // bouton Restart
              onPressed: setupNewGame,
            ),
          ],
        ),
      ),
    );
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
              )
          ),
          ),
          content: SizedBox(
            width:500,
            height:200,
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
      for (int j = i; j < tiles.length; j++) {
        if (tiles[j].value != 0) {
          int k = tiles.indexWhere((t) => t.value != 0, j + 1);
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

    //events part
    var random = Random();
    int randomEvent = random.nextInt(2);
    /*if(randomEvent==1){
      Future.microtask(() {
        setState(() {
          redFlag(grid);
        });
      });
      }*/

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
      var random = Random();
      int randomI = random.nextInt(4);
      int randomJ = random.nextInt(4);
      bool ok = false;
      while (!ok) {
        if (grid[randomI][randomJ].value != 0) {
          grid[randomI][randomJ].value = 0;
          ok=true;
        }
        else {
          randomI = random.nextInt(4);
          randomJ = random.nextInt(4);
        }
      }
  }

  bool isGameOver(List<List<AnimatedTiles>> grid) {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j].value == 0) {
          print(1);
          return false; // Il reste une case vide
        }
        if (i > 0 && grid[i][j].value == grid[i - 1][j].value) {
          print(2);
          return false; // Fusion possible en haut
        }
        if (i < 3 && grid[i][j].value == grid[i + 1][j].value) {
          print(3);
          return false; // Fusion possible en bas

        }
        if (j > 0 && grid[i][j].value == grid[i][j - 1].value) {
          print(4);
          return false; // Fusion possible à gauche

        }
        if (j < 3 && grid[i][j].value == grid[i][j + 1].value)
        {
          print(5);
          return false;
        } // Fusion possible à droite
      }
    }
    for(int i=0;i<4;i++){
      for(int j=0;j<4;j++){
        print(grid[i][j].value);
      }
    }
    return true; // Aucune case vide et aucune fusion possible
  }

  void setupNewGame() {
    setState(() {
      gameStates.clear();
      for (final t in gridTiles) {
        t.value = 0;
        t.resetAnimations();
      }
      toAdd.clear();
      addNewTiles([2, 2]);
      controller.forward(from: 0);
    });
  }
}
