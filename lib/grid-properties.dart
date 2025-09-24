import 'package:flutter/material.dart';

const double cornerRadius = 8.0;
const double moveInterval = .5;

const Color lightBrown = Color.fromARGB(255, 205, 193, 180);
const Color darkBrown = Color.fromARGB(255, 187, 173, 160);
const Color orange = Color.fromARGB(255, 245, 149, 99);
const Color tan = Color.fromARGB(255, 238, 228, 218);
const Color numColor = Color.fromARGB(255, 119, 110, 101);
const Color greyText = Color.fromARGB(255, 119, 110, 101);
const Color Background = Color.fromRGBO(30,30,48,1);

// Grille / Plateau
const Color gridBackground = Color.fromRGBO(50, 50, 70, 1); // fond de la grille
const Color gridLine = Color.fromRGBO(70, 70, 100, 1);      // séparateurs subtils

// Boutons principaux (Nouveau jeu, Restart, etc.)
const Color buttonPrimary = Color.fromRGBO(0, 173, 181, 1); // cyan moderne
const Color buttonPrimaryText = Colors.white;

// Boutons secondaires (Options, Retour discret, etc.)
const Color buttonSecondary = Color.fromRGBO(200, 200, 220, 1);
const Color buttonSecondaryText = Color.fromRGBO(30, 30, 48, 1);

// Textes
const Color textPrimary = Colors.white;
const Color textSecondary = Color.fromRGBO(200, 200, 220, 0.7);

// Ombres
const Color shadowColor = Colors.black54;
const Map<int, Color> numTileColor = {
  2: tan,
  4: tan,
  8: Color.fromARGB(255, 242, 177, 121),
  16: Color.fromARGB(255, 245, 149, 99),
  32: Color.fromARGB(255, 246, 124, 95),
  64: const Color.fromARGB(255, 246, 95, 64),
  128: const Color.fromARGB(255, 235, 208, 117),
  256: const Color.fromARGB(255, 237, 203, 103),
  512: const Color.fromARGB(255, 236, 201, 85),
  1024: const Color.fromARGB(255, 229, 194, 90),
  2048: const Color.fromARGB(255, 232, 192, 70),
};

const Map<int, Color> numTextColor = {
  2: greyText,
  4: greyText,
  8: Colors.white,
  16: Colors.white,
  32: Colors.white,
  64: Colors.white,
  128: Colors.white,
  256: Colors.white,
  512: Colors.white,
  1024: Colors.white,
  2048: Colors.white,
};