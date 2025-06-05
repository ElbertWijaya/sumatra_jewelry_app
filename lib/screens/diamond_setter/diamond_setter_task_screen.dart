```dart
import 'package:flutter/material.dart';

class DiamondSetterTaskScreen extends StatelessWidget {
  static const routeName = '/diamond-setter-task';

  final List<String> _tasks = ['Pasang Batu', 'Pengecekan', 'Serah ke Finisher'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diamond Setter Task'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  title: Text(_tasks[index]),
                  trailing: Checkbox(
                    value: false,
                    onChanged: (value) {
                      // Handle checkbox state change
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle submit action
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
```