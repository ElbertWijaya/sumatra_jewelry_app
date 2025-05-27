import 'order.dart';

final List<OrderWorkflowStatus> fullWorkflowStatuses = [
  OrderWorkflowStatus.waitingSalesCheck,
  OrderWorkflowStatus.waitingDesigner,
  OrderWorkflowStatus.designing,
  OrderWorkflowStatus.waitingCasting,
  OrderWorkflowStatus.casting,
  OrderWorkflowStatus.waitingCarving,
  OrderWorkflowStatus.carving,
  OrderWorkflowStatus.waitingDiamondSetting,
  OrderWorkflowStatus.stoneSetting,
  OrderWorkflowStatus.waitingFinishing,
  OrderWorkflowStatus.finishing,
  OrderWorkflowStatus.waitingInventory,
  OrderWorkflowStatus.inventory,
  OrderWorkflowStatus.waitingSalesCompletion,
  OrderWorkflowStatus.done,
  OrderWorkflowStatus.cancelled,
];

double getOrderProgress(Order order) {
  final idx = fullWorkflowStatuses.indexOf(order.workflowStatus);
  final maxIdx = fullWorkflowStatuses.indexOf(OrderWorkflowStatus.done);
  if (idx < 0) return 0.0;
  return idx / maxIdx;
}
