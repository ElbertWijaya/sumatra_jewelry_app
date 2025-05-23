import 'package:flutter/material.dart';

class FinishingTaskScreen extends StatelessWidget {
  const FinishingTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finisher Tasks')),
      body: const Center(
        child: Text('This is where finisher tasks will be managed.'),
      ),
    );
  }
}
