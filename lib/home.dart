import 'package:flutter/material.dart';
import 'grille.dart';

void HomeDart() {
  runApp(const MyApp());
}

class MenuButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const MenuButton({super.key, required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: child,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'F1 2048',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            Column(
              children: [
                Image.asset(
                  "assets/img/f1_logo.png",
                  height: 80,
                ),
                const SizedBox(height: 4),
                const Text(
                  "2048",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),

            // Play
            MenuButton(
              child: const Text(
                "Play",
                style: TextStyle(
                  fontFamily: "Formula1",
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Game2048Grid()),
                );
              },
            ),
            const SizedBox(height: 20),

            // Leaderboard
            MenuButton(
              child: const Text(
                "Leaderboard",
                style: TextStyle(
                  fontFamily: "Formula1",
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onPressed: () {},
            ),
            const SizedBox(height: 20),

            // Quit
            MenuButton(
              child: const Text(
                "Quit",
                style: TextStyle(
                  fontFamily: "Formula1",
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
