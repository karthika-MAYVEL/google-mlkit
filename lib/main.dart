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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Text(
          "Welcome to seyo ai ",
          style: TextStyle(

            fontSize: 22,
            fontFamily: "poppins",
          ),
        ),
      ),
    );
  }
}