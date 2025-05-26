import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class DesignerDetailScreen extends StatefulWidget {
  final Order order;
  const DesignerDetailScreen({super.key, required this.order});

  @override
  State<DesignerDetailScreen> createState() => _DesignerDetailScreenState();
}

class _DesignerDetailScreenState extends State<DesignerDetailScreen>
    with SingleTickerProviderStateMixin {
  late Order _order;
  bool _isProcessing = false;
  final List<String> todoList = ["Design", "Print", "Pengecekan"];
  List<String> checkedTodos = [];

  // Tambahkan TabController untuk mengatur tab
  late TabController _tabController;

  // Misal, tab ke-1 adalah "On Progress"
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    checkedTodos = List<String>.from(_order.designerWorkChecklist ?? []);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  Future<void> _saveChecklist() async {
    final updatedOrder = _order.copyWith(designerWorkChecklist: checkedTodos);
    await OrderService().updateOrder(updatedOrder);
    setState(() => _order = updatedOrder);
  }

  Future<void> _submitToCor() async {
    setState(() => _isProcessing = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.waiting_casting,
      designerWorkChecklist: checkedTodos,
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
    // TODO: Ganti 'Nama Designer' dengan nama user login jika ada sistem login
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.designing,
      assignedDesigner: _order.assignedDesigner ?? 'Nama Designer',
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
    final List<OrderWorkflowStatus> onProgressStatuses = [
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
    ];
    final idx = onProgressStatuses.indexOf(order.workflowStatus);
    if (idx < 0) return 0.0;
    return (idx + 1) / onProgressStatuses.length;
  }

  @override
  Widget build(BuildContext context) {
    bool isWorking = _order.workflowStatus == OrderWorkflowStatus.designing;
    bool isWaitingDesigner =
        _order.workflowStatus == OrderWorkflowStatus.waiting_designer;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan Designer')),
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
            _buildDisplayField(
              'Status',
              _order.workflowStatus.label,
            ),
            const SizedBox(height: 24),

            // PATCH: Tambahkan tombol "Terima & Mulai Kerjakan Pesanan"
            if (isWaitingDesigner)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _acceptOrder,
                  child: const Text('Terima & Mulai Kerjakan Pesanan'),
                ),
              ),

            // Tampilkan To Do Work checklist & Submit ke Cor jika status "designing"
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
                    ? _submitToCor
                    : null,
                child: const Text('Submit ke Cor'),
              ),
            ],

            // Progress bar: tampilkan jika status sudah masuk tahap on progress
            if ({
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
            }.contains(_order.workflowStatus))
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
