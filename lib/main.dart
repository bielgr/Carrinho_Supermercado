// main.dart
import 'package:flutter/material.dart';
import 'package:carrinhodesupermercado/login_screen.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() {
  Gemini.init(apiKey: 'AIzaSyDIvtbbNCCx4iV0Dparf4qlDxpXnGFBDH8', enableDebugging: true);
  runApp(SupermarketApp());
}

class SupermarketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: const TextTheme(
          displayMedium: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
