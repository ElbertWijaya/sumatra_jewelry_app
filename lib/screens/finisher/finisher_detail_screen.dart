import 'package:flutter/material.dart';

class FinisherDetailScreen extends StatelessWidget {
  // Dummy order data
  final _order = Order(finishingWorkChecklist: [
    'Task 1',
    'Task 2',
    'Task 3',
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finisher Detail'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _order.finishingWorkChecklist.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_order.finishingWorkChecklist[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle finish action
              },
              child: Text('Finish'),
            ),
          ),
        ],
      ),
    );
  }
}

class Order {
  final List<String> finishingWorkChecklist;

  Order({required this.finishingWorkChecklist});
}