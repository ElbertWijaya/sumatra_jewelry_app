import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class DesignerTaskScreen extends StatefulWidget {
  final Order order;
  const DesignerTaskScreen({super.key, required this.order});

  @override
  State<DesignerTaskScreen> createState() => _DesignerTaskScreenState();
}

class _DesignerTaskScreenState extends State<DesignerTaskScreen> {
  late Order _order;
  bool _isProcessing = false;
  final List<String> designerTodoList = [
    'Designing',
    '3D Printing',
    'Pengecekan',
  ];
  List<String> checkedTodos = [];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    checkedTodos = List<String>.from(_order.designerWorkChecklist ?? []);
  }

  Future<void> _acceptOrder() async {
    setState(() => _isProcessing = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.designing,
      updatedAt: DateTime.now(),
    );
    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      setState(() {
        _order = updatedOrder;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan diterima, silakan mulai desain!'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menerima pesanan: $e')),
      );
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _submitToNext() async {
    setState(() => _isProcessing = true);
    final updatedOrder = _order.copyWith(
      designerWorkChecklist: checkedTodos,
      workflowStatus: OrderWorkflowStatus.waitingCasting,
      updatedAt: DateTime.now(),
    );
    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      setState(() {
        _order = updatedOrder;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checklist selesai. Pesanan lanjut ke Casting!'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal submit: $e')),
      );
    }
    setState(() => _isProcessing = false);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Tugas Designer')),
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
            if (_order.workflowStatus == OrderWorkflowStatus.waitingDesigner)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _acceptOrder,
                  child: const Text(
                    'Terima Pesanan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (_order.workflowStatus == OrderWorkflowStatus.designing) ...[
              Text(
                'Checklist Pekerjaan',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...designerTodoList.map(
                (task) => CheckboxListTile(
                  title: Text(task),
                  value: checkedTodos.contains(task),
                  onChanged: (val) {
                    setState(() {
                      if (val == true && !checkedTodos.contains(task)) {
                        checkedTodos.add(task);
                      } else if (val == false && checkedTodos.contains(task)) {
                        checkedTodos.remove(task);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: checkedTodos.length == designerTodoList.length && !_isProcessing
                      ? _submitToNext
                      : null,
                  child: const Text('Submit ke Casting'),
                ),
              ),
            ],
            if (_order.workflowStatus != OrderWorkflowStatus.waitingDesigner &&
                _order.workflowStatus != OrderWorkflowStatus.designing)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Checklist Designer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ...designerTodoList.map(
                    (task) => Row(
                      children: [
                        Icon(
                          (_order.designerWorkChecklist ?? []).contains(task)
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: (_order.designerWorkChecklist ?? []).contains(task)
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