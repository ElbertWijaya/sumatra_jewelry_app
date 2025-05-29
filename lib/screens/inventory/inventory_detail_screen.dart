import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'inventory_task_screen.dart';

class InventoryDetailScreen extends StatefulWidget {
  final Order order;
  const InventoryDetailScreen({super.key, required this.order});

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  late Order _order;
  bool _isProcessing = false; // Renamed from _isSaving for clarity
  bool _dataSaved = false; // Track if inventory data is saved

  final TextEditingController _kodeBarangController = TextEditingController();
  final TextEditingController _namaProdukController = TextEditingController(); // New controller
  final TextEditingController _lokasiRakController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  final _dateFormat = DateFormat('dd/MM/yyyy'); // Date formatter

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    // Load existing inventory data if available
    _kodeBarangController.text = _order.inventoryProductCode ?? '';
    _namaProdukController.text = _order.inventoryProductName ?? ''; // Load new field
    _lokasiRakController.text = _order.inventoryShelfLocation ?? '';
    _catatanController.text = _order.inventoryNotes ?? '';

    // Check if data was already saved (e.g., if revisiting the screen)
    _dataSaved = _order.inventoryProductCode != null &&
        _order.inventoryProductName != null &&
        _order.inventoryShelfLocation != null; // Check required fields

    // Listen to changes to trigger rebuild for button enable/disable
    _kodeBarangController.addListener(_onFormChanged);
    _namaProdukController.addListener(_onFormChanged); // Listen to new controller
    _lokasiRakController.addListener(_onFormChanged);
    _catatanController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _kodeBarangController.removeListener(_onFormChanged);
    _namaProdukController.removeListener(_onFormChanged); // Remove listener
    _lokasiRakController.removeListener(_onFormChanged);
    _catatanController.removeListener(_onFormChanged);
    _kodeBarangController.dispose();
    _namaProdukController.dispose(); // Dispose new controller
    _lokasiRakController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    // Trigger rebuild only if the status is currently inventory (input phase)
    if (_order.workflowStatus == OrderWorkflowStatus.inventory) {
      setState(() {});
    }
  }

  // Helper to show field value or 'Belum diisi'
  String showField(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Belum diisi' : value;

  // Helper to show date value or 'Belum diisi'
  String showDate(DateTime? date) =>
      date == null ? 'Belum diisi' : _dateFormat.format(date);


  Future<void> _mulaiInputInventory() async {
    setState(() => _isProcessing = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.inventory,
      updatedAt: DateTime.now(),
    );
    try {
      await OrderService().updateOrder(updatedOrder);
      // Update local order state and trigger rebuild
      setState(() {
        _order = updatedOrder;
        _isProcessing = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan masuk proses Inventory!')),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update pesanan: $e')));
    }
  }

  Future<void> _simpanDataInventory() async {
    setState(() => _isProcessing = true);

    // Create updated order with data from controllers
    final updatedOrder = _order.copyWith(
      inventoryProductCode: _kodeBarangController.text.trim(),
      inventoryProductName: _namaProdukController.text.trim(), // Save new field
      inventoryShelfLocation: _lokasiRakController.text.trim(),
      inventoryNotes: _catatanController.text.trim(),
      updatedAt: DateTime.now(),
      // TODO: If other details like Jenis Perhiasan, etc., are re-inputted,
      // save them to appropriate fields in the Order model here.
      // Example: inventoryJewelryType: _jenisPerhiasanController.text.trim(),
    );

    try {
      await OrderService().updateOrder(updatedOrder);
      // Update local order state and trigger rebuild
      setState(() {
        _order = updatedOrder;
        _dataSaved = true; // Mark data as saved
        _isProcessing = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data Inventory berhasil disimpan!'),
        ),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    }
  }

  Future<void> _submitKeSales() async {
    setState(() => _isProcessing = true);
    final updatedOrder = _order.copyWith(
      workflowStatus: OrderWorkflowStatus.waitingSalesCompletion,
      updatedAt: DateTime.now(),
      // Ensure the latest inventory data is included if not saved previously
      inventoryProductCode: _kodeBarangController.text.trim(),
      inventoryProductName: _namaProdukController.text.trim(),
      inventoryShelfLocation: _lokasiRakController.text.trim(),
      inventoryNotes: _catatanController.text.trim(),
    );

    try {
      await OrderService().updateOrder(updatedOrder);
      if (!mounted) return;
      Navigator.of(context).pop(true); // Pop with true to indicate success/change
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan diteruskan ke Sales!')),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update pesanan: $e')));
    }
  }

  // Check if required input fields are filled
  bool get _isFormValid =>
      _kodeBarangController.text.trim().isNotEmpty &&
      _namaProdukController.text.trim().isNotEmpty && // Nama Produk is required
      _lokasiRakController.text.trim().isNotEmpty;

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
    final imageList = List<String>.from(_order.imagePaths ?? []);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan - Inventory')),
      body:
          _isProcessing
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referensi Gambar',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageList.length,
                        itemBuilder:
                            (context, idx) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(imageList[idx]),
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
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Display initial order details
                    Text(
                      'Nama Pelanggan: ${showField(_order.customerName)}',
                    ),
                    Text(
                      'Nomor Telepon: ${showField(_order.customerContact)}',
                    ),
                    Text('Alamat: ${showField(_order.address)}'),
                    Text(
                      'Jenis Perhiasan: ${showField(_order.jewelryType)}',
                    ),
                    Text('Warna Emas: ${showField(_order.goldColor)}'),
                    Text('Jenis Emas: ${showField(_order.goldType)}'),
                    Text('Jenis Batu: ${showField(_order.stoneType)}'),
                    Text('Ukuran Batu: ${showField(_order.stoneSize)}'),
                    Text('Ukuran Cincin: ${showField(_order.ringSize)}'),
                    Text('Catatan Awal: ${showField(_order.notes)}'),
                    Text('Tanggal Siap: ${showDate(_order.readyDate)}'),
                    const SizedBox(height: 24),

                    // --- Workflow Logic ---

                    // State: Waiting for Inventory to start
                    if (_order.workflowStatus ==
                        OrderWorkflowStatus.waitingInventory)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _mulaiInputInventory,
                          child: const Text('Mulai Input Inventory'),
                        ),
                      ),

                    // State: Inventory is inputting data
                    if (_order.workflowStatus == OrderWorkflowStatus.inventory)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Input Data Inventory',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          InventoryTaskScreen(
                            kodeBarangController: _kodeBarangController,
                            namaProdukController: _namaProdukController, // Pass new controller
                            lokasiRakController: _lokasiRakController,
                            catatanController: _catatanController,
                            enabled: !_dataSaved && !_isProcessing, // Disable fields after saving
                          ),
                          const SizedBox(height: 16),
                          // Show Save button if data is not yet saved
                          if (!_dataSaved)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isFormValid && !_isProcessing
                                        ? _simpanDataInventory
                                        : null,
                                child: const Text(
                                  'Simpan Data Inventory',
                                ),
                              ),
                            ),
                          // Show Submit button if data is saved
                          if (_dataSaved)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.only(
                                    bottom: 10,
                                    top: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: const Text(
                                    'Data Inventory telah disimpan. Silakan submit ke Sales.',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        !_isProcessing ? _submitKeSales : null,
                                    child: const Text('Submit ke Sales'),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                    // State: Data already inputted and submitted (or in later stages)
                    // Display the saved inventory data
                    if (_order.workflowStatus !=
                            OrderWorkflowStatus.waitingInventory &&
                        _order.workflowStatus != OrderWorkflowStatus.inventory)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data Inventory yang Diinput:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kode Produk: ${showField(_order.inventoryProductCode)}',
                          ),
                          Text(
                            'Nama Produk: ${showField(_order.inventoryProductName)}', // Display new field
                          ),
                          Text(
                            'Lokasi Rak: ${showField(_order.inventoryShelfLocation)}',
                          ),
                          Text(
                            'Catatan Inventory: ${showField(_order.inventoryNotes)}',
                          ),
                          // TODO: Display other re-inputted details if you added fields for them
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Always show progress bar if not done or cancelled
                    if (_order.workflowStatus != OrderWorkflowStatus.done &&
                        _order.workflowStatus != OrderWorkflowStatus.cancelled)
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
                  ],
                ),
              ),
    );
  }
}

// Ensure this helper function is accessible or defined here if not global
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

// Tidak perlu perubahan di file ini jika model sudah benar
