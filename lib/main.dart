import 'package:flutter/material.dart';
import 'scenes/home/home_screen.dart';

void main() {
  runApp(const TGFInventory());
}

class TGFInventory extends StatelessWidget {
  const TGFInventory({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}