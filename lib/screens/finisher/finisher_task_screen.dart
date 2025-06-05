import 'package:flutter/material.dart';

class FinisherTaskScreen extends StatelessWidget {
  // Define the list of tasks for the finishing process
  final List<String> _tasks = ['Finishing', 'Pengecekan', 'Serah ke Inventory'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finisher Task Screen'),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_tasks[index]),
            // Navigate to the corresponding checklist screen
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinishingWorkChecklist(task: _tasks[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Dummy checklist screen for the finishing tasks
class FinishingWorkChecklist extends StatelessWidget {
  final String task;

  const FinishingWorkChecklist({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$task Checklist'),
      ),
      body: Center(
        child: Text('Checklist for $task'),
      ),
    );
  }
}