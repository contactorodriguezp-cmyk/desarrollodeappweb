import 'package:flutter/material.dart';

import 'screens/ingreso_screen.dart';
import 'theme.dart';

void main() => runApp(const RelevoApp());

class RelevoApp extends StatelessWidget {
  const RelevoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relevo',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const IngresoScreen(),
    );
  }
}
