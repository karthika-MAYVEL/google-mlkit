import 'package:flutter/material.dart';
import 'package:google_mlkit/components/mlkit_scanner/mlkit_scanner.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('--- APP STARTING ---');
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Kit Scanner',
      debugShowCheckedModeBanner: true, // Show banner to confirm it's running
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ScannerTestPage(),
    );
  }
}

class ScannerTestPage extends StatelessWidget {
  const ScannerTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('--- BUILDING ScannerTestPage ---');
    
    return Scaffold(
      backgroundColor: Colors.white, // Explicit background color
      appBar: AppBar(
        title: const Text('ML Kit Scanner Test'),
        backgroundColor: Colors.deepPurple.withOpacity(0.1),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ML Kit Scanner Ready',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              MlkitScannerButton(
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
              const SizedBox(height: 10),
              const Text('Tap the icon to start scanning'),
            ],
          ),
        ),
      ),
    );
  }
}
