import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';
import '../../models/order.dart';
import '../../models/order_workflow.dart';

class DesignerDetailScreen extends StatefulWidget {
  final Order order;
  const DesignerDetailScreen({super.key, required this.order});

  @override
  State<DesignerDetailScreen> createState() => _DesignerDetailScreenState();
}

class _DesignerDetailScreenState extends State<DesignerDetailScreen> {
  late Order _order;
  late List<String> _images;
  DateTime? _readyDate;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _stoneSizeController;
  late TextEditingController _ringSizeController;
  late TextEditingController _notesController;
  late TextEditingController _dateController;
  late TextEditingController _finalPriceController;
  late TextEditingController _dpController;

  final _rupiahFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    final latestOrder = await OrderService().getOrderById(widget.order.id);
    if (latestOrder == null) return; // atau tampilkan error/snackbar
    setState(() {
      _order = latestOrder;
      checkedTodos = List<String>.from(_order.designerWorkChecklist ?? []);
      _images = List<String>.from(_order.imagePaths ?? []);
      _nameController = TextEditingController(text: _order.customerName);
      _contactController = TextEditingController(text: _order.customerContact);
      _addressController = TextEditingController(text: _order.address);
      _stoneSizeController = TextEditingController(text: _order.stoneSize ?? "");
      _ringSizeController = TextEditingController(text: _order.ringSize ?? "");
      _notesController = TextEditingController(text: _order.notes ?? "");
      _finalPriceController = TextEditingController(
        text:
            _order.finalPrice != null && _order.finalPrice != 0
                ? _rupiahFormat.format(_order.finalPrice)
                : '',
      );
      _dpController = TextEditingController(
        text:
            _order.dp != null && _order.dp != 0
                ? _rupiahFormat.format(_order.dp)
                : '',
      );
      _readyDate = _order.readyDate;
      _dateController = TextEditingController(
        text:
            _readyDate == null
                ? ""
                : "${_readyDate!.day}/${_readyDate!.month}/${_readyDate!.year}",
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _stoneSizeController.dispose();
    _ringSizeController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _finalPriceController.dispose();
    _dpController.dispose();
    super.dispose();
  }

  String showField(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Belum diisi' : value;
  String showDouble(double? value) =>
      value == null ? 'Belum diisi' : _rupiahFormat.format(value);
  String showDate(DateTime? date) =>
      date == null ? 'Belum diisi' : "${date.day}/${date.month}/${date.year}";

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

  // Dialog konfirmasi submit dengan checkbox persetujuan
  Future<bool?> _showSubmitConfirmationDialog() async {
    bool isAgreed = false;
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('Konfirmasi Submit'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Yakin ingin submit pesanan ke Designer? Setelah submit, data tidak bisa diedit lagi.',
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: isAgreed,
                      onChanged:
                          (val) => setState(() => isAgreed = val ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Saya setuju dengan ketentuan ini'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: isAgreed ? () => Navigator.pop(ctx, true) : null,
                    child: const Text('Submit'),
                  ),
                ],
              ),
        );
      },
    );
  }

  bool _isProcessing = false;
  final List<String> designerTodoList = [
    'Designing',
    '3D Printing',
    'Pengecekan',
  ];
  List<String> checkedTodos = [];

  Future<void> _saveChecklist() async {
    // Simpan checklist ke database atau server
    // Misal: await OrderService().updateOrderChecklist(_order.id, checkedTodos);
  }

  Future<void> _acceptOrder() async {
    setState(() {
      _isProcessing = true;
    });
    try {
      final updatedOrder = _order.copyWith(
        workflowStatus: OrderWorkflowStatus.designing,
        updatedAt: DateTime.now(),
      );
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _submitToNext() async {
    setState(() {
      _isProcessing = true;
    });
    try {
      final updatedOrder = _order.copyWith(
        workflowStatus: OrderWorkflowStatus.waitingCasting,
        updatedAt: DateTime.now(),
      );
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_images.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, idx) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_images[idx]),
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (c, e, s) => Container(
                                width: 110,
                                height: 110,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
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
              'Harga Barang / Perkiraan',
              showDouble(_order.finalPrice),
            ),
            _buildDisplayField('Jumlah DP', showDouble(_order.dp)),
            _buildDisplayField(
              'Sisa harga untuk lunas',
              showDouble(_order.sisaLunas),
            ),
            _buildDisplayField('Catatan Tambahan', showField(_order.notes)),
            _buildDisplayField('Tanggal Siap', showDate(_order.readyDate)),
            _buildDisplayField('Status', _order.workflowStatus.label),
            if (_order.workflowStatus != OrderWorkflowStatus.done &&
                _order.workflowStatus != OrderWorkflowStatus.cancelled)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: getOrderProgress(_order),
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Progress: ${(getOrderProgress(_order) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            // Tombol terima pesanan (Waiting)
            if (_order.workflowStatus == OrderWorkflowStatus.waitingDesigner)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _acceptOrder,
                  child: const Text('Terima & Mulai Kerjakan Pesanan'),
                ),
              ),

            // Checklist dan tombol submit (Working)
            if (_order.workflowStatus == OrderWorkflowStatus.designing) ...[
              Text(
                'To Do Work',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...designerTodoList.map(
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
                    // Simpan checklist ke backend secara real-time
                    await OrderService().updateOrder(_order.copyWith(
                      designerWorkChecklist: checkedTodos,
                    ));
                  },
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: checkedTodos.length == designerTodoList.length && !_isProcessing
                    ? _submitToNext
                    : null,
                child: const Text('Submit ke Casting'),
              ),
            ],

            // Progress bar & persentase (On Progress)
            if ({
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
            }.contains(_order.workflowStatus))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progress Pesanan',
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
                      ),
                    ),
                  ],
                ),
              ),
            // Tombol submit untuk carver sudah dihilangkan
          ],
        ),
      ),
    );
  }
}