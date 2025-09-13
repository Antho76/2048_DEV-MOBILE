import 'package:flutter/material.dart';

class Game2048Grid extends StatelessWidget {
  const Game2048Grid({super.key});
  final List<List<int>> grid = const [
    [2, 0, 0, 2],
    [0, 4, 0, 0],
    [0, 0, 8, 0],
    [16, 0, 0, 0],
  ];

  Color getTileColor(int value) {
    switch (value) {
      case 0:
        return Colors.grey[200]!;
      case 2:
        return Colors.orange[200]!;
      case 4:
        return Colors.yellow[300]!;
      case 8:
        return Colors.green[300]!;
      case 16:
        return Colors.blue[400]!;
      case 32:
        return Colors.red[200]!;
      case 64:
        return Colors.pink[200]!;
      case 128 :
        return Colors.purple[200]!;
      case 256:
        return Colors.teal[200]!;
      case 512:
        return Colors.tealAccent[200]!;
      case 1024:
        return Colors.cyan[200]!;
      case 2048:
        return Colors.deepPurpleAccent[200]!;
      default:
        return Colors.brown[200]!; // fallback pour les autres
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("F1 2048")),
      body: Center(
        child: Table(
          border: TableBorder.all(color: Colors.black12, width: 2),
          children: grid.map((row) {
            return TableRow(
              children: row.map((cell) {
                return AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: getTileColor(cell),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        cell == 0 ? '' : '$cell',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[800],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}