import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class CorDetailScreen extends StatefulWidget {
  final Order order;
  const CorDetailScreen({super.key, required this.order});

  @override
  State<CorDetailScreen> createState() => _CorDetailScreenState();
}

class _CorDetailScreenState extends State<CorDetailScreen> {
  late Order _order;
  bool _isProcessing = false;
  final List<String> todoList = ["Cor", "Bersihkan", "QC"];
  List<String> checkedTodos = [];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    checkedTodos = List<String>.from(_order.castingWorkChecklist ?? []);
  }

  Future<void> _saveChecklist() async {
    final updatedOrder = _order.copyWith(castingWorkChecklist: checkedTodos);
    await OrderService().updateOrder(updatedOrder);
    setState(() => _order = updatedOrder);
  }

  Future<void> _submitToNext() async {
    setState(() => _isProcessing = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.waiting_carving,
      castingWorkChecklist: checkedTodos,
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
      workflowStatus: OrderWorkflowStatus.casting,
      assignedCaster: _order.assignedCaster ?? 'Nama Cor',
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

  @override
  Widget build(BuildContext context) {
    bool isWorking = _order.workflowStatus == OrderWorkflowStatus.casting;
    bool isWaiting =
        _order.workflowStatus == OrderWorkflowStatus.waiting_casting;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan Cor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_order.imagePaths != null && _order.imagePaths!.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _order.imagePaths!.length,
                  itemBuilder: (context, idx) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_order.imagePaths![idx]),
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (c, e, s) => Container(
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
            _buildDisplayField(
              'Nama Pelanggan',
              showField(_order.customerName),
            ),
            _buildDisplayField(
              'Nomor Telepon',
              showField(_order.customerContact),
            ),
            _buildDisplayField('Alamat', showField(_order.address)),
            _buildDisplayField(
              'Jenis Perhiasan',
              showField(_order.jewelryType),
            ),
            _buildDisplayField('Warna Emas', showField(_order.goldColor)),
            _buildDisplayField('Jenis Emas', showField(_order.goldType)),
            _buildDisplayField('Jenis Batu', showField(_order.stoneType)),
            _buildDisplayField('Ukuran Batu', showField(_order.stoneSize)),
            _buildDisplayField('Ukuran Cincin', showField(_order.ringSize)),
            _buildDisplayField('Status', _order.workflowStatus.label),
            const SizedBox(height: 24),
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
                onPressed:
                    checkedTodos.length == todoList.length && !_isProcessing
                        ? _submitToNext
                        : null,
                child: const Text('Submit ke Carver'),
              ),
            ],
            if (_order.castingWorkChecklist != null &&
                _order.castingWorkChecklist!.isNotEmpty &&
                !isWorking)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progress Cor:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...todoList.map(
                      (name) => Row(
                        children: [
                          Icon(
                            _order.castingWorkChecklist!.contains(name)
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color:
                                _order.castingWorkChecklist!.contains(name)
                                    ? Colors.green
                                    : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(name),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
