import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';

class SalesDetailScreen extends StatefulWidget {
  final Order order;
  const SalesDetailScreen({super.key, required this.order});

  @override
  State<SalesDetailScreen> createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
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
            // ...lanjutkan dengan checklist dan tombol aksi sesuai kebutuhan...
          ],
        ),
      ),
    );
  }
}
