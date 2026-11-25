import 'package:emad_job_board/screens/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const JobBoardApp());
}

class JobBoardApp extends StatelessWidget {
  const JobBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    const boardBackground = Color(0xFFEDE3D2); // Sfondo caldo tipo bacheca/sughero
    const boardAccent = Color(0xFF2B5943);     // Verde lavagna

    return MaterialApp(
      title: 'Bacheca annunci',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: boardAccent,
          surface: boardBackground,
        ),
        scaffoldBackgroundColor: boardBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2B5943),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: false,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}