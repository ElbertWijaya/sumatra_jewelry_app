import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';
import '../../models/order.dart';

class DesignerDetailScreen extends StatefulWidget {
  final Order order;
  const DesignerDetailScreen({super.key, required this.order});

  @override
  State<DesignerDetailScreen> createState() => _DesignerDetailScreenState();
}

final List<OrderWorkflowStatus> fullWorkflowStatuses = [
  OrderWorkflowStatus.waitingSalesCheck,
  OrderWorkflowStatus.waitingDesigner,
  OrderWorkflowStatus.pending,
  OrderWorkflowStatus.designing,
  OrderWorkflowStatus.waitingCasting,
  OrderWorkflowStatus.readyForCasting,
  OrderWorkflowStatus.casting,
  OrderWorkflowStatus.waitingCarving,
  OrderWorkflowStatus.readyForCarving,
  OrderWorkflowStatus.carving,
  OrderWorkflowStatus.waitingDiamondSetting,
  OrderWorkflowStatus.readyForStoneSetting,
  OrderWorkflowStatus.stoneSetting,
  OrderWorkflowStatus.waitingFinishing,
  OrderWorkflowStatus.readyForFinishing,
  OrderWorkflowStatus.finishing,
  OrderWorkflowStatus.waitingInventory,
  OrderWorkflowStatus.readyForInventory,
  OrderWorkflowStatus.inventory,
  OrderWorkflowStatus.waitingSalesCompletion,
  OrderWorkflowStatus.done,
  OrderWorkflowStatus.cancelled,
  OrderWorkflowStatus.unknown,
  OrderWorkflowStatus.debut,
];

double getOrderProgress(Order order) {
  final idx = fullWorkflowStatuses.indexOf(order.workflowStatus);
  final maxIdx = fullWorkflowStatuses.indexOf(OrderWorkflowStatus.done);
  if (idx < 0) return 0.0;
  return idx / maxIdx;
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
    _order = widget.order;
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

  // Dialog konfirmasi hapus dengan checkbox persetujuan
  Future<bool?> _showDeleteConfirmationDialog() async {
    bool isAgreed = false;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('Konfirmasi Hapus'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Yakin ingin menghapus pesanan ini?'),
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
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed:
                        isAgreed
                            ? () => Navigator.pop(dialogContext, true)
                            : null,
                    child: const Text('Hapus'),
                  ),
                ],
              ),
        );
      },
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
            if (_order.workflowStatus == OrderWorkflowStatus.waitingSalesCheck)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final result = await Navigator.of(
                            context,
                          ).pushNamed('/sales/edit', arguments: _order);
                          if (!mounted) return;
                          if (result == true) {
                            Navigator.of(
                              context,
                            ).pop(true); // Refresh dashboard setelah edit
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final confirm = await _showDeleteConfirmationDialog();
                          if (!mounted) return;
                          if (confirm == true) {
                            await OrderService().deleteOrder(_order.id);
                            if (!mounted) return;
                            Navigator.of(context).pop(true);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (_order.workflowStatus == OrderWorkflowStatus.waitingSalesCheck)
              const SizedBox(height: 16),
            if (_order.workflowStatus == OrderWorkflowStatus.waitingSalesCheck)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Submit untuk Designer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    final confirm = await _showSubmitConfirmationDialog();
                    if (!mounted) return;
                    if (confirm == true) {
                      final updatedOrder = _order.copyWith(
                        workflowStatus: OrderWorkflowStatus.waitingDesigner,
                        updatedAt: DateTime.now(),
                      );
                      await OrderService().updateOrder(updatedOrder);
                      if (!mounted) return;
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
