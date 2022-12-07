import 'package:flutter/material.dart';
import 'package:monkeypox_detector/splash_screen.dart';

void main() {
  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Monkeypox Detection',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: splashScreen(),
  );
  runApp(app);
}