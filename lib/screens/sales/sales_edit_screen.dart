import 'package:flutter/material.dart';
import '../../models/order.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import '../../services/order_service.dart';

class SalesEditScreen extends StatefulWidget {
  const SalesEditScreen({super.key});

  @override
  State<SalesEditScreen> createState() => _SalesEditScreenState();
}

class _SalesEditScreenState extends State<SalesEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderService = OrderService();

  late Order order;
  bool _isLoading = false;

  // Form fields
  late String customerName;
  late String customerContact;
  late String address;
  late String jewelryType;
  String? stoneType;
  String? stoneSize;
  String? ringSize;
  DateTime? readyDate;
  String? notes;
  double? finalPrice;
  double? dp;
  double? sisaLunas;

  final TextEditingController _finalPriceController = TextEditingController();
  final TextEditingController _dpController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Order? argOrder =
        ModalRoute.of(context)?.settings.arguments as Order?;
    if (argOrder != null) {
      order = argOrder;
      customerName = order.customerName;
      customerContact = order.customerContact;
      address = order.address;
      jewelryType = order.jewelryType;
      stoneType = order.stoneType;
      stoneSize = order.stoneSize;
      ringSize = order.ringSize;
      readyDate = order.readyDate;
      notes = order.notes;
      finalPrice = order.finalPrice;
      dp = order.dp;
      sisaLunas = order.sisaLunas;
      _finalPriceController.text =
          finalPrice != null && finalPrice != 0
              ? toCurrencyString(
                finalPrice!.toStringAsFixed(0),
                thousandSeparator: ThousandSeparator.Period,
                mantissaLength: 0,
              )
              : '';
      _dpController.text =
          dp != null && dp != 0
              ? toCurrencyString(
                dp!.toStringAsFixed(0),
                thousandSeparator: ThousandSeparator.Period,
                mantissaLength: 0,
              )
              : '';
    }
  }

  double get _finalPriceValue {
    return double.tryParse(
          toNumericString(_finalPriceController.text, allowPeriod: false),
        ) ??
        0;
  }

  double get _dpValue {
    return double.tryParse(
          toNumericString(_dpController.text, allowPeriod: false),
        ) ??
        0;
  }

  double get _sisaLunasValue {
    final harga = _finalPriceValue;
    final dp = _dpValue;
    final sisa = harga - dp;
    return sisa < 0 ? 0 : sisa;
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final updatedOrder = order.copyWith(
      customerName: customerName,
      customerContact: customerContact,
      address: address,
      jewelryType: jewelryType,
      stoneType: stoneType,
      stoneSize: stoneSize,
      ringSize: ringSize,
      readyDate: readyDate,
      notes: notes,
      finalPrice: _finalPriceValue,
      dp: _dpValue,
      sisaLunas: _sisaLunasValue,
      updatedAt: DateTime.now(),
    );

    try {
      await _orderService.updateOrder(updatedOrder);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil diperbarui!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui pesanan: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)?.settings.arguments as Order?;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pesanan')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: customerName,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pelanggan *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Nama wajib diisi'
                                    : null,
                        onSaved: (v) => customerName = v?.trim() ?? '',
                      ),
                      TextFormField(
                        initialValue: customerContact,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon *',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nomor telepon wajib diisi';
                          }
                          if (v.length < 8) {
                            return 'Nomor telepon minimal 8 digit';
                          }
                          return null;
                        },
                        onSaved: (v) => customerContact = v?.trim() ?? '',
                      ),
                      TextFormField(
                        initialValue: address,
                        decoration: const InputDecoration(
                          labelText: 'Alamat *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Alamat wajib diisi'
                                    : null,
                        onSaved: (v) => address = v?.trim() ?? '',
                      ),
                      TextFormField(
                        initialValue: jewelryType,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Perhiasan *',
                        ),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Jenis perhiasan wajib diisi'
                                    : null,
                        onSaved: (v) => jewelryType = v?.trim() ?? '',
                      ),
                      TextFormField(
                        initialValue: stoneType,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Batu',
                        ),
                        onSaved: (v) => stoneType = v?.trim(),
                      ),
                      TextFormField(
                        initialValue: stoneSize,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Batu',
                        ),
                        onSaved: (v) => stoneSize = v?.trim(),
                      ),
                      TextFormField(
                        initialValue: ringSize,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Cincin',
                        ),
                        onSaved: (v) => ringSize = v?.trim(),
                      ),
                      // Harga Barang / Perkiraan
                      TextFormField(
                        controller: _finalPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Harga Barang / Perkiraan *',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CurrencyInputFormatter(
                            thousandSeparator: ThousandSeparator.Period,
                            mantissaLength: 0,
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Harga wajib diisi';
                          }
                          if (toNumericString(v, allowPeriod: false).isEmpty) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      // Jumlah DP
                      TextFormField(
                        controller: _dpController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah DP',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CurrencyInputFormatter(
                            thousandSeparator: ThousandSeparator.Period,
                            mantissaLength: 0,
                          ),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                      // Sisa harga untuk lunas (readonly)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const Text(
                              'Sisa harga untuk lunas: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              toCurrencyString(
                                _sisaLunasValue.toStringAsFixed(0),
                                thousandSeparator: ThousandSeparator.Period,
                                mantissaLength: 0,
                                leadingSymbol: 'Rp ',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        initialValue: notes,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Tambahan',
                        ),
                        onSaved: (v) => notes = v?.trim(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitEdit,
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Simpan Perubahan'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
