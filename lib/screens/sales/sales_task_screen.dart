import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'package:intl/intl.dart';

class SalesTaskScreen extends StatefulWidget {
  final Order order;
  const SalesTaskScreen({super.key, required this.order});

  @override
  State<SalesTaskScreen> createState() => _SalesTaskScreenState();
}

class _SalesTaskScreenState extends State<SalesTaskScreen> {
  late Order _order;
  bool _isProcessing = false;

  final _rupiahFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _submitToDesigner() async {
    setState(() => _isProcessing = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.waiting_designer,
    );
    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      setState(() {
        _order = updatedOrder;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dikirim ke designer!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal submit ke designer: $e')));
    }
    setState(() => _isProcessing = false);
  }

  String showField(String? value) =>
      (value == null || value.trim().isEmpty) ? '-' : value;

  String showDouble(double? value) =>
      value == null ? '-' : _rupiahFormat.format(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tugas Sales')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilkan detail order (ringkas, null safety)
            Text('Nama Pelanggan: ${showField(_order.customerName)}'),
            Text('Jenis Perhiasan: ${showField(_order.jewelryType)}'),
            Text('Nomor Telepon: ${showField(_order.customerContact)}'),
            Text('Alamat: ${showField(_order.address)}'),
            Text('Harga Barang / Perkiraan: ${showDouble(_order.finalPrice)}'),
            Text('Jumlah DP: ${showDouble(_order.dp)}'),
            Text('Sisa harga untuk lunas: ${showDouble(_order.sisaLunas)}'),
            const SizedBox(height: 16),
            // Tombol submit ke designer jika status waiting_sales_check
            if (_order.workflowStatus ==
                OrderWorkflowStatus.waiting_sales_check)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _submitToDesigner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isProcessing
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Submit ke Designer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            // ... tombol/aksi lain sesuai kebutuhan ...
          ],
        ),
      ),
    );
  }
}
