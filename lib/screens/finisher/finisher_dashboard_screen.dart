```dart
import 'package:flutter/material.dart';
import 'package:your_project_name/models/order_workflow_status.dart';

class FinisherDashboardScreen extends StatelessWidget {
  static const routeName = '/finisher-dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finisher Dashboard'),
      ),
      body: Center(
        child: Text('Welcome to the Finisher Dashboard'),
      ),
    );
  }
}

final List<OrderWorkflowStatus> waitingStatuses = [
  OrderWorkflowStatus.waitingFinishing,
];
final List<OrderWorkflowStatus> workingStatuses = [
  OrderWorkflowStatus.finishing,
];
final List<OrderWorkflowStatus> onProgressStatuses = [
  OrderWorkflowStatus.waitingInventory,
  OrderWorkflowStatus.inventory,
];
```