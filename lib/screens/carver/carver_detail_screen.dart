import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class CarverDetailScreen extends StatefulWidget {
  final Order order;
  const CarverDetailScreen({super.key, required this.order});

  @override
  State<CarverDetailScreen> createState() => _CarverDetailScreenState();
}

class _CarverDetailScreenState extends State<CarverDetailScreen> {
  late Order _order;
  bool _isProcessing = false;
  final List<String> todoList = [
    'Bom',
    'Polish',
    'Pengecekan',
    'Kasih ke Olivia',
  ];
  List<String> checkedTodos = [];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    checkedTodos = List<String>.from(_order.carvingWorkChecklist ?? []);
  }

  Future<void> _saveChecklist() async {
    final updatedOrder = _order.copyWith(carvingWorkChecklist: checkedTodos);
    await OrderService().updateOrder(updatedOrder);
  }

  Future<void> _submitToNext() async {
    setState(() => _isProcessing = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.waitingDiamondSetting,
      carvingWorkChecklist: checkedTodos,
      updatedAt: DateTime.now(),
    );
    await OrderService().updateOrder(updatedOrder);
    setState(() {
      _order = updatedOrder;
      _isProcessing = false;
    });
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _acceptOrder() async {
    setState(() => _isProcessing = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.carving,
      updatedAt: DateTime.now(),
    );
    await OrderService().updateOrder(updatedOrder);
    setState(() {
      _order = updatedOrder;
      _isProcessing = false;
    });
    if (mounted) Navigator.of(context).pop(true);
  }

  Widget _buildDisplayField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String showField(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Belum diisi' : value;

  double getOrderProgress(Order order) {
    final fullWorkflowStatuses = [
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
    ];
    final idx = fullWorkflowStatuses.indexOf(order.workflowStatus);
    final maxIdx = fullWorkflowStatuses.indexOf(OrderWorkflowStatus.done);
    if (idx < 0 || maxIdx <= 0) return 0.0;
    return idx / maxIdx;
  }

  @override
  Widget build(BuildContext context) {
    bool isWorking = _order.workflowStatus == OrderWorkflowStatus.carving;
    bool isWaiting =
        _order.workflowStatus == OrderWorkflowStatus.waitingCarving;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan Carver')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_order.imagePaths.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _order.imagePaths.length,
                  itemBuilder: (context, idx) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_order.imagePaths[idx]),
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 110,
                            height: 110,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            _buildDisplayField('Nama Pelanggan', showField(_order.customerName)),
            _buildDisplayField('Nomor Telepon', showField(_order.customerContact)),
            _buildDisplayField('Alamat', showField(_order.address)),
            _buildDisplayField('Jenis Perhiasan', showField(_order.jewelryType)),
            _buildDisplayField('Warna Emas', showField(_order.goldColor)),
            _buildDisplayField('Jenis Emas', showField(_order.goldType)),
            _buildDisplayField('Jenis Batu', showField(_order.stoneType)),
            _buildDisplayField('Ukuran Batu', showField(_order.stoneSize)),
            _buildDisplayField('Ukuran Cincin', showField(_order.ringSize)),
            _buildDisplayField('Status', _order.workflowStatus.label),
            const SizedBox(height: 24),
            if (_order.workflowStatus != OrderWorkflowStatus.done &&
                _order.workflowStatus != OrderWorkflowStatus.cancelled)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Pengerjaan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: LinearProgressIndicator(
                        value: getOrderProgress(_order),
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        color: Colors.amber[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Text(
                      '${(getOrderProgress(_order) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            if (isWaiting)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _acceptOrder,
                  child: const Text('Terima & Mulai Kerjakan Pesanan'),
                ),
              ),
            if (isWorking) ...[
              Text(
                'To Do Work',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...todoList.map(
                (task) => CheckboxListTile(
                  title: Text(task),
                  value: checkedTodos.contains(task),
                  onChanged: (val) async {
                    setState(() {
                      if (val == true && !checkedTodos.contains(task)) {
                        checkedTodos.add(task);
                      } else if (val == false && checkedTodos.contains(task)) {
                        checkedTodos.remove(task);
                      }
                    });
                    await _saveChecklist();
                  },
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: checkedTodos.length == todoList.length && !_isProcessing
                    ? _submitToNext
                    : null,
                child: const Text('Submit ke Diamond Setting'),
              ),
            ],
            if (!isWorking && !isWaiting)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Checklist Carver',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ...todoList.map(
                    (task) => Row(
                      children: [
                        Icon(
                          (_order.carvingWorkChecklist ?? []).contains(task)
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: (_order.carvingWorkChecklist ?? []).contains(task)
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(task),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}