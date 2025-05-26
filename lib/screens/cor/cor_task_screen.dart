import 'package:flutter/material.dart';

class CorTaskScreen extends StatelessWidget {
  const CorTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cor Task')),
      body: const Center(child: Text('Fitur Task Cor di sini.')),
    );
  }
}
