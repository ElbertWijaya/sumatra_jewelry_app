import 'order.dart';

final List<OrderWorkflowStatus> fullWorkflowStatuses = [
  OrderWorkflowStatus.waiting_sales_check,
  OrderWorkflowStatus.waiting_designer,
  OrderWorkflowStatus.designing,
  OrderWorkflowStatus.waiting_casting,
  OrderWorkflowStatus.casting,
  OrderWorkflowStatus.waiting_carving,
  OrderWorkflowStatus.carving,
  OrderWorkflowStatus.waiting_diamond_setting,
  OrderWorkflowStatus.stoneSetting,
  OrderWorkflowStatus.waiting_finishing,
  OrderWorkflowStatus.finishing,
  OrderWorkflowStatus.waiting_inventory,
  OrderWorkflowStatus.inventory,
  OrderWorkflowStatus.waiting_sales_completion,
  OrderWorkflowStatus.done,
  OrderWorkflowStatus.cancelled,
];

double getOrderProgress(Order order) {
  final idx = fullWorkflowStatuses.indexOf(order.workflowStatus);
  final maxIdx = fullWorkflowStatuses.indexOf(OrderWorkflowStatus.done);
  if (idx < 0) return 0.0;
  return idx / maxIdx;
}