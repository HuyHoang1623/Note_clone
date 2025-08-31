import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Color.fromARGB(255, 200, 200, 200),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: Color(0xFFF0F0F0),
        ),
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B0B),
        cardColor: const Color.fromARGB(255, 64, 64, 64),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: Color(0xFF1E1E1E),
        ),
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
      ),

      themeMode: ThemeMode.dark,

      home: const HomePage(),
    );
  }
}
