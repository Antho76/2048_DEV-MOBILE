import 'package:devmobile/Game.dart';
import 'package:flutter/material.dart';

void HomeDart() {
  runApp(const MyApp());
}

class MenuButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const MenuButton({super.key, required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    final double baseSize = screenWidth < screenHeight ? screenWidth : screenHeight;
    return SizedBox(
      width: baseSize*0.8,
      height: baseSize*0.2,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(baseSize*0.08),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    final double baseSize = screenWidth < screenHeight ? screenWidth : screenHeight;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: baseSize*0.08),
            Column(
              children: [
                Image.asset(
                  "assets/img/f1_logo.png",
                  height: baseSize*0.2,
                ),
                SizedBox(height: baseSize*0.01),
                Text(
                  "2048",
                  style: TextStyle(
                    fontFamily: "Formula1",
                    fontSize: baseSize*0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: baseSize*0.2),

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
                  MaterialPageRoute(builder: (context) => const TwentyFortyEight()),
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
