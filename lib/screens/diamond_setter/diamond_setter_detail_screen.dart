import 'package:flutter/material.dart';

class DiamondSetterDetailScreen extends StatelessWidget {
  final List<String> _tasks = ['Pasang Batu', 'Pengecekan', 'Serah ke Finisher'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diamond Setting Detail'),
      ),
      body: Column(
        children: [
          // ...existing code for displaying order details...
          Text('Diamond Setting Tasks:'),
          ..._tasks.map((task) => CheckboxListTile(
                value: false,
                onChanged: (bool? value) {},
                title: Text(task),
              )),
          // ...existing code for other details...
        ],
      ),
    );
  }
}