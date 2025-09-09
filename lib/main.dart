import 'package:flutter/material.dart';
import 'package:note_clone/original/pages/add_note_page.dart';
import 'package:note_clone/original/pages/home_page.dart';
import 'package:note_clone/core/signin_signup/signup_page.dart';
import 'package:note_clone/original/pages/to_do_list_page.dart';
import 'core/signin_signup/signin_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: const Color.fromARGB(255, 200, 200, 200),
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

      themeMode: _themeMode,

      initialRoute: 'signin',

      routes: {
        'signin': (context) => const SignInPage(),
        'signup': (context) => const SignUpPage(),
        'homepage': (context) => const HomePage(),
        'todolist': (context) => const ToDoListPage(),
        'addnote': (context) => const AddNotePage(),
      },
    );
  }
}
