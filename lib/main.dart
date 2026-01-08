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
    return Scaffold(
      appBar: AppBar(title: const Text('ML Kit Scanner Test')),
      body: SafeArea(
        child: Center(
          child: MlkitScannerButton(
            onResult: (result) {
              debugPrint('Scan Result: ${result.status} - ${result.value}');
              if (result.status == 'pass') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Scanned: ${result.value}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${result.message}')),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
