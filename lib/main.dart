import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/home_screen.dart';
import 'state/outfit_controller.dart';

void main() => runApp(const OutfitApp());

class OutfitApp extends StatefulWidget {
  const OutfitApp({super.key});

  @override
  State<OutfitApp> createState() => _OutfitAppState();
}

class _OutfitAppState extends State<OutfitApp> {
  // Satu controller dipakai bersama oleh semua layar.
  late final OutfitController _controller = OutfitController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outfit AI',
      // ShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: HomeScreen(controller: _controller),
    );
  }
}
