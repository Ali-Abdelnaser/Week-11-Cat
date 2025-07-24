// lib/main.dart
import 'package:flutter/material.dart';
import 'package:note/screens/splash_screen.dart';

void main() {
  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
