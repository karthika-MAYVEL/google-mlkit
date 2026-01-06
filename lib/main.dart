import 'package:flutter/material.dart';
//main function - the entry point of every flutter application
void main() {
  runApp(const MyApp());
}
//app widget building
class MyApp extends StatelessWidget {
  const MyApp({super.key}) ;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //material app is the app wrapper
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home : const HomeScreen(),
    );
  }
}


enum SmartFieldType { qr, text }

class SmartField extends StatefulWidget {
  final String label;
  final SmartFieldType type;
  final TextEditingController controller;

  const SmartField({
    super.key,
    required this.label,
    required this.type,
    required this.controller,
  });

  @override
  State<SmartField> createState() => _SmartFieldState();
}

class _SmartFieldState extends State<SmartField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      debugPrint("Focus gained on: ${widget.label} (${widget.type})");
      // This is where we will trigger the camera in the next step
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              widget.type == SmartFieldType.qr
                  ? Icons.qr_code_scanner
                  : Icons.camera_alt,
            ),
            onPressed: () {
              debugPrint("Scan button pressed for: ${widget.label}");
            },
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _serialController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seyo AI Smart Scanner"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Welcome to Seyo AI",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "poppins",
              ),
            ),
            const SizedBox(height: 20),
            SmartField(
              label: "Serial Number",
              type: SmartFieldType.qr,
              controller: _serialController,
            ),
            SmartField(
              label: "Product Name",
              type: SmartFieldType.text,
              controller: _nameController,
            ),
          ],
        ),
      ),
    );
  }
}