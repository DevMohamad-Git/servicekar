import 'package:flutter/material.dart';

void main() {
  runApp(const ServicarApp());
}

class ServicarApp extends StatelessWidget {
  const ServicarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('Servicar'))),
    );
  }
}
