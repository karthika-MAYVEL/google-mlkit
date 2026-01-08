import 'package:flutter/material.dart';
import 'components/mlkit_scanner/mlkit_scanner.dart';

void main() => runApp(const TestApp());

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ScannerTestPage(),
    );
  }
}

class ScannerTestPage extends StatelessWidget {
  const ScannerTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: MlKitScanner(), // <-- change to your real widget name
        ),
      ),
    );
  }
}
