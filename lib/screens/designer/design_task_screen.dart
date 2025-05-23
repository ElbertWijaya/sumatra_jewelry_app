import 'package:flutter/material.dart';

class DesignTaskScreen extends StatelessWidget {
  const DesignTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Designer Tasks')),
      body: const Center(
        child: Text('This is where designer tasks will be managed.'),
      ),
    );
  }
}
