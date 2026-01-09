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

class ScannerTestPage extends StatefulWidget {
  const ScannerTestPage({super.key});

  @override
  State<ScannerTestPage> createState() => _ScannerTestPageState();
}

class _ScannerTestPageState extends State<ScannerTestPage> {
  ScanResult? _lastResult;

  void _clearResult() {
    setState(() {
      _lastResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('--- BUILDING ScannerTestPage ---');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ML Kit Scanner Test'),
        backgroundColor: Colors.deepPurple.withOpacity(0.1),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_lastResult == null) ...[
                const Text(
                  'ML Kit Scanner Ready',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                MlkitScannerButton(
                  onResult: (result) {
                    debugPrint('Scan Result: ${result.status} - ${result.value}');
                    setState(() {
                      _lastResult = result;
                    });
                  },
                ),
                const SizedBox(height: 10),
                const Text('Tap the icon to start scanning'),
              ] else ...[
                Card(
                  margin: const EdgeInsets.all(20),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _lastResult!.status == 'pass' ? 'Scan Successful' : 'Scan Failed',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _lastResult!.status == 'pass' ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_lastResult!.status == 'pass')
                          SelectableText(
                            _lastResult!.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          )
                        else
                          Text(
                            _lastResult!.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: _clearResult,
                              icon: const Icon(Icons.close),
                              label: const Text('Clear / Cancel'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _clearResult,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Scan Again'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
