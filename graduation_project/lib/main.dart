import 'package:flutter/material.dart';
import 'package:graduation_project/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Home(),
    );
  }
}

class PharaohColors {
  static const Color gold = Color(0xFFD4AF37);
  static const Color brown = Color(0xFF8B4513);
  static const Color darkBrown = Color(0xFF654321);
  static const Color black = Color(0xFF1A1A1A);
}
