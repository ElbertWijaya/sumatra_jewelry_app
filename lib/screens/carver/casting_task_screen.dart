import 'package:flutter/material.dart';

class CastingTaskScreen extends StatelessWidget {
  const CastingTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carver Tasks')),
      body: const Center(
        child: Text('This is where carver tasks will be managed.'),
      ),
    );
  }
}
