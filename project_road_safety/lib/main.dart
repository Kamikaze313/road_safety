import 'package:flutter/material.dart';
import 'package:project_road_safety/loginstyle.dart';
import 'navigate_screen.dart';
import 'map_screen.dart';
import 'hello.dart';
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
        primarySwatch: Colors.blue,
      ),
      home: const NavigatePage(),
    );
  }
}
