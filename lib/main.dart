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
  final _assetIdController = TextEditingController();
  final _locationController = TextEditingController();
  final _serialNumberController = TextEditingController();

  @override
  void dispose() {
    _assetIdController.dispose();
    _locationController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final assetId = _assetIdController.text;
    final location = _locationController.text;
    final serial = _serialNumberController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Submitted: Asset=$assetId, Location=$location, Serial=$serial'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('--- BUILDING ScannerTestPage Form ---');
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Inventory Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Scan or enter details below',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              _buildField(
                label: 'Asset ID',
                controller: _assetIdController,
                hint: 'Scan or type asset ID',
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 24),
              
              _buildField(
                label: 'Location Code',
                controller: _locationController,
                hint: 'Scan or type location',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 24),
              
              _buildField(
                label: 'Serial Number',
                controller: _serialNumberController,
                hint: 'Scan or type serial number',
                icon: Icons.tag,
              ),
              
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Submit Entry',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.deepPurple.withOpacity(0.7)),
            suffixIcon: MlkitScannerButton(controller: controller),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
