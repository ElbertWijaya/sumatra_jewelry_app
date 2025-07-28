import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class SalesTaskScreen extends StatefulWidget {
  final Order order;
  const SalesTaskScreen({super.key, required this.order});

  @override
  State<SalesTaskScreen> createState() => _SalesTaskScreenState();
}

class _SalesTaskScreenState extends State<SalesTaskScreen> {
  late Order _order;
  bool _isProcessing = false;
  List<String> _designerChecklist = [];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _designerChecklist = List<String>.from(_order.ordersDesignerWorkChecklist);
  }

  Future<void> _updateChecklist() async {
    setState(() => _isProcessing = true);
    try {
      final updatedOrder = _order.copyWith(
        ordersDesignerWorkChecklist: _designerChecklist,
      );
      await OrderService().updateOrder(updatedOrder);
      setState(() {
        _order = updatedOrder;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checklist berhasil diupdate')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Designer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // PATCH: Tampilkan gambar referensi order (jika ada)
          if (_order.ordersImagePaths.isNotEmpty) ...[
            const Text(
              'Referensi Gambar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._order.ordersImagePaths.map((img) {
                    final String imageUrl =
                        img.startsWith('http')
                            ? img
                            : 'http://192.168.7.25/sumatra_api/$img';
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          CheckboxListTile(
            value: _designerChecklist.contains('Designing'),
            title: const Text('Designing'),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _designerChecklist.add('Designing');
                } else {
                  _designerChecklist.remove('Designing');
                }
              });
            },
          ),
          // Tambahkan checklist lain sesuai kebutuhan
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isProcessing ? null : _updateChecklist,
            child:
                _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text('Update Checklist'),
          ),
        ],
      ),
    );
  }
}
