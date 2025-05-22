import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart'; // Pastikan mengimpor model Order Anda
import 'package:sumatra_jewelry_app/services/order_service.dart'; // Import OrderService
import 'dart:io'; // Untuk menampilkan gambar dari File
import 'package:intl/intl.dart'; // Untuk format tanggal

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  final String userRole; // Tambahkan parameter userRole

  const OrderDetailScreen({
    super.key,
    required this.order,
    this.userRole = 'sales', // Default value to 'sales'
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _currentOrder; // State lokal untuk order agar bisa diupdate
  final OrderService _orderService =
      OrderService(); // Inisialisasi OrderService
  bool _isProcessing =
      false; // State untuk mengontrol tombol saat ada proses async

  // Variabel untuk checklist designer
  bool _isDesignCompleted = false;
  bool _isPrintingCompleted = false;
  bool _isCheckingCompleted = false;

  // Variabel state baru untuk peran selanjutnya (ini akan diinisialisasi dari completionDate di model Order)
  bool _isCorCompleted = false;
  bool _isCarvingCompleted = false;
  bool _isDiamondSettingCompleted = false;
  bool _isFinishingCompleted = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order; // Inisialisasi dari widget.order
    _initializeChecklistStatus(); // Inisialisasi status checklist berdasarkan status order saat ini
  }

  /// Menginisialisasi status checkbox berdasarkan completionDate yang sudah ada di model Order.
  void _initializeChecklistStatus() {
    setState(() {
      _isDesignCompleted = _currentOrder.designCompletionDate != null;
      _isPrintingCompleted =
          _currentOrder.designCompletionDate !=
          null; // Umumnya printing & checking selesai bersamaan dengan design
      _isCheckingCompleted =
          _currentOrder.designCompletionDate !=
          null; // Umumnya printing & checking selesai bersamaan dengan design

      _isCorCompleted = _currentOrder.corCompletionDate != null;
      _isCarvingCompleted = _currentOrder.carvingCompletionDate != null;
      _isDiamondSettingCompleted =
          _currentOrder.diamondSettingCompletionDate != null;
      _isFinishingCompleted = _currentOrder.finishingCompletionDate != null;
    });
  }

  /// Fungsi pembantu untuk memformat tanggal
  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }
    return DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(date); // Tambahkan HH:mm untuk waktu
  }

  /// Widget pembantu untuk menampilkan baris detail
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140, // Lebar tetap untuk label agar lebih rapi
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  /// Metode generik untuk memperbarui status pesanan dan completionDate yang relevan
  Future<void> _updateOrderStatus(
    String newStatus, {
    String? newWorkerRole,
    DateTime? designCompletionDate,
    DateTime? corCompletionDate,
    DateTime? carvingCompletionDate,
    DateTime? diamondSettingCompletionDate,
    DateTime? finishingCompletionDate,
    DateTime? pickupDate, // Untuk final pickup date (diambil sales)
  }) async {
    if (_isProcessing) return; // Prevent double-tap

    setState(() {
      _isProcessing = true;
    });

    try {
      final updatedOrder = _currentOrder.copyWith(
        status: newStatus,
        currentWorkerRole: newWorkerRole,
        lastUpdate: DateTime.now(),
        // Perbarui completion dates secara kondisional.
        // Jika parameter null, gunakan nilai yang sudah ada di _currentOrder.
        designCompletionDate:
            designCompletionDate ?? _currentOrder.designCompletionDate,
        corCompletionDate: corCompletionDate ?? _currentOrder.corCompletionDate,
        carvingCompletionDate:
            carvingCompletionDate ?? _currentOrder.carvingCompletionDate,
        diamondSettingCompletionDate:
            diamondSettingCompletionDate ??
            _currentOrder.diamondSettingCompletionDate,
        finishingCompletionDate:
            finishingCompletionDate ?? _currentOrder.finishingCompletionDate,
        pickupDate:
            pickupDate ??
            _currentOrder.pickupDate, // Update pickupDate for sales
      );

      await _orderService.updateOrder(updatedOrder);

      setState(() {
        _currentOrder = updatedOrder;
        _initializeChecklistStatus(); // Re-initialize checkboxes after status update
      });

      _showSnackBar(
        'Status pesanan berhasil diperbarui menjadi ${newStatus.replaceAll('_', ' ')}!',
        isSuccess: true,
      );
      // Kembali ke dashboard dan refresh, atau bisa juga tetap di layar detail
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Gagal memperbarui status pesanan: $e', isSuccess: false);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // MARK: - Sales Actions
  Future<void> _assignToDesignerAsSales() async {
    if (_currentOrder.status == 'pending') {
      await _updateOrderStatus(
        'assigned_to_designer',
        newWorkerRole: 'Designer',
      );
    } else {
      _showSnackBar(
        'Pesanan ini tidak bisa dialihkan ke Designer dari status saat ini.',
        isSuccess: false,
      );
    }
  }

  Future<void> _markOrderAsCompletedAsSales() async {
    if (_currentOrder.status == 'ready_for_pickup') {
      await _updateOrderStatus(
        'completed',
        newWorkerRole: null, // Tidak ada pekerja aktif
        pickupDate: DateTime.now(), // Catat tanggal diambil
      );
    } else {
      _showSnackBar(
        'Pesanan hanya bisa diselesaikan jika sudah siap diambil.',
        isSuccess: false,
      );
    }
  }

  // MARK: - Designer Actions
  Future<void> _acceptOrderAsDesigner() async {
    if (_currentOrder.status == 'pending' ||
        _currentOrder.status == 'assigned_to_designer') {
      await _updateOrderStatus('designing', newWorkerRole: 'Designer');
    } else {
      _showSnackBar(
        'Pesanan ini tidak bisa diterima oleh Designer dari status saat ini.',
        isSuccess: false,
      );
    }
  }

  Future<void> _submitToCorStageAsDesigner() async {
    if (!_isDesignCompleted || !_isPrintingCompleted || !_isCheckingCompleted) {
      _showSnackBar(
        'Harap centang semua kewajiban sebelum mengajukan.',
        isSuccess: false,
      );
      return;
    }
    if (_currentOrder.status == 'designing') {
      // Set completionDate saat mengajukan ke tahap selanjutnya
      await _updateOrderStatus(
        'ready_for_cor',
        newWorkerRole: 'Cor',
        designCompletionDate: DateTime.now(), // Tandai design selesai
      );
    } else {
      _showSnackBar(
        'Desain belum selesai untuk diajukan ke tahap Cor.',
        isSuccess: false,
      );
    }
  }

  // MARK: - Cor Actions
  Future<void> _acceptOrderAsCor() async {
    if (_currentOrder.status == 'ready_for_cor') {
      await _updateOrderStatus('cor_in_progress', newWorkerRole: 'Cor');
    } else {
      _showSnackBar(
        'Pesanan ini tidak bisa diterima oleh Cor dari status saat ini.',
        isSuccess: false,
      );
    }
  }

  Future<void> _submitToCarverStageAsCor() async {
    if (!_isCorCompleted) {
      _showSnackBar(
        'Harap centang "Pengecoran Selesai" sebelum mengajukan.',
        isSuccess: false,
      );
      return;
    }
    if (_currentOrder.status == 'cor_in_progress') {
      // Set completionDate saat mengajukan ke tahap selanjutnya
      await _updateOrderStatus(
        'ready_for_carving',
        newWorkerRole: 'Carver',
        corCompletionDate: DateTime.now(), // Tandai cor selesai
      );
    } else {
      _showSnackBar(
        'Proses Cor belum selesai untuk diajukan ke tahap Pengukiran.',
        isSuccess: false,
      );
    }
  }

  // MARK: - Carver Actions
  Future<void> _acceptOrderAsCarver() async {
    if (_currentOrder.status == 'ready_for_carving') {
      await _updateOrderStatus('carving_in_progress', newWorkerRole: 'Carver');
    } else {
      _showSnackBar(
        'Pesanan ini tidak bisa diterima oleh Carver dari status saat ini.',
        isSuccess: false,
      );
    }
  }

  Future<void> _submitToDiamondSetterAsCarver() async {
    if (!_isCarvingCompleted) {
      _showSnackBar(
        'Harap centang "Pengukiran Selesai" sebelum mengajukan.',
        isSuccess: false,
      );
      return;
    }
    if (_currentOrder.status == 'carving_in_progress') {
      await _updateOrderStatus(
        'ready_for_diamond_setting',
        newWorkerRole: 'Diamond Setter',
        carvingCompletionDate: DateTime.now(), // Tandai carving selesai
      );
    } else {
      _showSnackBar(
        'Pengukiran belum selesai untuk diajukan ke Diamond Setter.',
        isSuccess: false,
      );
    }
  }

  // MARK: - Diamond Setter Actions
  Future<void> _acceptOrderAsDiamondSetter() async {
    if (_currentOrder.status == 'ready_for_diamond_setting') {
      await _updateOrderStatus(
        'diamond_setting_in_progress',
        newWorkerRole: 'Diamond Setter',
      );
    } else {
      _showSnackBar(
        'Pesanan ini tidak bisa diterima oleh Diamond Setter dari status saat ini.',
        isSuccess: false,
      );
    }
  }

  Future<void> _submitToFinisherAsDiamondSetter() async {
    if (!_isDiamondSettingCompleted) {
      _showSnackBar(
        'Harap centang "Pemasangan Berlian Selesai" sebelum mengajukan.',
        isSuccess: false,
      );
      return;
    }
    if (_currentOrder.status == 'diamond_setting_in_progress') {
      await _updateOrderStatus(
        'ready_for_finishing',
        newWorkerRole: 'Finisher',
        diamondSettingCompletionDate:
            DateTime.now(), // Tandai diamond setting selesai
      );
    } else {
      _showSnackBar(
        'Pemasangan berlian belum selesai untuk diajukan ke Finisher.',
        isSuccess: false,
      );
    }
  }

  // MARK: - Finisher Actions
  Future<void> _acceptOrderAsFinisher() async {
    if (_currentOrder.status == 'ready_for_finishing') {
      await _updateOrderStatus(
        'finishing_in_progress',
        newWorkerRole: 'Finisher',
      );
    } else {
      _showSnackBar(
        'Pesanan ini tidak bisa diterima oleh Finisher dari status saat ini.',
        isSuccess: false,
      );
    }
  }

  Future<void> _markAsReadyForPickupAsFinisher() async {
    if (!_isFinishingCompleted) {
      _showSnackBar(
        'Harap centang "Finishing Selesai" sebelum menandai siap diambil.',
        isSuccess: false,
      );
      return;
    }
    if (_currentOrder.status == 'finishing_in_progress') {
      await _updateOrderStatus(
        'ready_for_pickup',
        newWorkerRole: 'Sales', // Kembali ke Sales
        finishingCompletionDate: DateTime.now(), // Tandai finishing selesai
      );
    } else {
      _showSnackBar(
        'Finishing belum selesai untuk menyatakan siap diambil.',
        isSuccess: false,
      );
    }
  }

  /// Fungsi pembantu untuk menampilkan Snackbar
  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil jenis perhiasan dari productName jika formatnya (Jenis) Nama Produk
    String jewelryTypeParsed = 'Tidak Diketahui';
    if (_currentOrder.productName.contains('(') &&
        _currentOrder.productName.contains(')')) {
      try {
        jewelryTypeParsed = _currentOrder.productName.substring(
          _currentOrder.productName.indexOf('(') + 1,
          _currentOrder.productName.indexOf(')'),
        );
      } catch (e) {
        // Handle parsing error if needed, e.g., log it
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Informasi Pelanggan ---
            Text(
              'Informasi Pelanggan',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 10, thickness: 1),
            _buildDetailRow(
              context,
              'Nama Pelanggan',
              _currentOrder.customerName,
            ),
            _buildDetailRow(
              context,
              'Nomor Telepon',
              _currentOrder.phoneNumber,
            ),
            _buildDetailRow(context, 'Alamat', _currentOrder.address),
            const SizedBox(height: 20),

            // --- Detail Produk ---
            Text(
              'Detail Produk',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 10, thickness: 1),
            _buildDetailRow(context, 'Nama Produk', _currentOrder.productName),
            _buildDetailRow(context, 'Jenis Perhiasan', jewelryTypeParsed),
            _buildDetailRow(
              context,
              'Jenis Emas',
              _currentOrder.goldType ?? 'N/A',
            ),
            _buildDetailRow(
              context,
              'Deskripsi Produk',
              _currentOrder.productDescription,
            ),
            if (_currentOrder.diamondSize != null &&
                _currentOrder.diamondSize!.isNotEmpty)
              _buildDetailRow(
                context,
                'Ukuran Berlian',
                _currentOrder.diamondSize!,
              ),
            if (_currentOrder.ringSize != null &&
                _currentOrder.ringSize!.isNotEmpty)
              _buildDetailRow(
                context,
                'Ukuran Cincin',
                _currentOrder.ringSize!,
              ),
            if (_currentOrder.estimatedCompletionDate != null)
              _buildDetailRow(
                context,
                'Estimasi Selesai',
                _formatDate(_currentOrder.estimatedCompletionDate),
              ),
            if (_currentOrder.pickupDate != null)
              _buildDetailRow(
                context,
                'Tanggal Diambil',
                _formatDate(_currentOrder.pickupDate),
              ),
            if (_currentOrder.goldPricePerGram != null)
              _buildDetailRow(
                context,
                'Harga Emas/Gram',
                'Rp ${_currentOrder.goldPricePerGram!.toStringAsFixed(0)}',
              ),
            _buildDetailRow(
              context,
              'Estimasi Harga',
              'Rp ${_currentOrder.estimatedPrice.toStringAsFixed(0)}',
            ),
            if (_currentOrder.finalProductPrice != null)
              _buildDetailRow(
                context,
                'Harga Akhir Produk',
                'Rp ${_currentOrder.finalProductPrice!.toStringAsFixed(0)}',
              ),
            const SizedBox(height: 20),

            // --- Status & Tanggal ---
            Text(
              'Status Pesanan',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 10, thickness: 1),
            _buildDetailRow(
              context,
              'Status',
              _currentOrder.status
                  .replaceAll('_', ' ')
                  .toUpperCase(), // Format status
            ),
            _buildDetailRow(
              context,
              'Tanggal Pesanan',
              _formatDate(_currentOrder.orderDate),
            ),
            _buildDetailRow(
              context,
              'Role Pekerja Saat Ini',
              _currentOrder.currentWorkerRole ?? 'Tidak Ditentukan',
            ),
            const SizedBox(height: 20),

            // --- TANGGAL PENYELESAIAN SETIAP TAHAP ---
            Text(
              'Tanggal Penyelesaian Tahap',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 10, thickness: 1),
            _buildDetailRow(
              context,
              'Desain Selesai',
              _formatDate(_currentOrder.designCompletionDate),
            ),
            _buildDetailRow(
              context,
              'Cor Selesai',
              _formatDate(_currentOrder.corCompletionDate),
            ),
            _buildDetailRow(
              context,
              'Ukiran Selesai',
              _formatDate(_currentOrder.carvingCompletionDate),
            ),
            _buildDetailRow(
              context,
              'Pemasangan Berlian Selesai',
              _formatDate(_currentOrder.diamondSettingCompletionDate),
            ),
            _buildDetailRow(
              context,
              'Finishing Selesai',
              _formatDate(_currentOrder.finishingCompletionDate),
            ),
            const SizedBox(height: 20),

            // --- Kontrol Berdasarkan Peran Pengguna ---

            // Aksi untuk Sales
            if (widget.userRole == 'sales')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 30),
                  const Text(
                    'Aksi Sales:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_currentOrder.status == 'pending')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isProcessing ? null : _assignToDesignerAsSales,
                        icon:
                            _isProcessing
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.send_rounded),
                        label: Text(
                          _isProcessing
                              ? 'Memproses...'
                              : 'Serahkan ke Designer',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (_currentOrder.status == 'ready_for_pickup')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isProcessing ? null : _markOrderAsCompletedAsSales,
                        icon:
                            _isProcessing
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _isProcessing
                              ? 'Memproses...'
                              : 'Tandai Selesai (Diambil Pelanggan)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            // Aksi untuk Designer
            if (widget.userRole == 'designer')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 30),
                  const Text(
                    'Aksi Designer:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (_currentOrder.status == 'assigned_to_designer')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isProcessing
                                ? null
                                : _currentOrder.status == 'assigned_to_designer'
                                ? _acceptOrderAsDesigner
                                : null,
                        icon:
                            _isProcessing
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _isProcessing
                              ? 'Memproses...'
                              : 'Terima Pesanan (Mulai Desain)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (_currentOrder.status == 'designing')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kewajiban Desain:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('Design (Desain Selesai)'),
                          value: _isDesignCompleted,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isDesignCompleted = newValue ?? false;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Printing (Pencetakan Selesai)'),
                          value: _isPrintingCompleted,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isPrintingCompleted = newValue ?? false;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text(
                            'Pengecekan (Pengecekan Akhir Desain)',
                          ),
                          value: _isCheckingCompleted,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isCheckingCompleted = newValue ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isProcessing
                                    ? null
                                    : (_isDesignCompleted &&
                                        _isPrintingCompleted &&
                                        _isCheckingCompleted)
                                    ? _submitToCorStageAsDesigner
                                    : null, // Disable jika belum semua dicentang
                            icon:
                                _isProcessing
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.arrow_forward),
                            label: Text(
                              _isProcessing
                                  ? 'Memproses...'
                                  : 'Ajukan ke Tahap Cor',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

            // Aksi untuk Cor
            if (widget.userRole == 'cor')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 30),
                  const Text(
                    'Aksi Cor:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (_currentOrder.status == 'ready_for_cor')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _acceptOrderAsCor,
                        icon:
                            _isProcessing
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.play_arrow),
                        label: Text(
                          _isProcessing
                              ? 'Memproses...'
                              : 'Terima Pesanan (Mulai Cor)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  if (_currentOrder.status == 'cor_in_progress')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kewajiban Pengecoran:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('Pengecoran Selesai'),
                          value: _isCorCompleted,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isCorCompleted = newValue ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isProcessing
                                    ? null
                                    : _isCorCompleted
                                    ? _submitToCarverStageAsCor
                                    : null, // Disable jika belum dicentang
                            icon:
                                _isProcessing
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.arrow_forward),
                            label: Text(
                              _isProcessing
                                  ? 'Memproses...'
                                  : 'Ajukan ke Tahap Ukir (Carver)',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

            // Aksi untuk Carver
            if (widget.userRole == 'carver')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 30),
                  const Text(
                    'Aksi Carver:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (_currentOrder.status == 'ready_for_carving')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _acceptOrderAsCarver,
                        icon:
                            _isProcessing
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.cut),
                        label: Text(
                          _isProcessing
                              ? 'Memproses...'
                              : 'Terima Pesanan (Mulai Ukir)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  if (_currentOrder.status == 'carving_in_progress')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kewajiban Pengukiran:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('Pengukiran Selesai'),
                          value: _isCarvingCompleted,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isCarvingCompleted = newValue ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isProcessing
                                    ? null
                                    : _isCarvingCompleted
                                    ? _submitToDiamondSetterAsCarver
                                    : null,
                            icon:
                                _isProcessing
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.diamond_outlined),
                            label: Text(
                              _isProcessing
                                  ? 'Memproses...'
                                  : 'Ajukan ke Tahap Pemasangan Berlian',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

            // Aksi untuk Diamond Setter
            if (widget.userRole == 'diamond_setter')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 30),
                  const Text(
                    'Aksi Diamond Setter:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (_currentOrder.status == 'ready_for_diamond_setting')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isProcessing ? null : _acceptOrderAsDiamondSetter,
                        icon:
                            _isProcessing
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.diamond),
                        label: Text(
                          _isProcessing
                              ? 'Memproses...'
                              : 'Terima Pesanan (Mulai Pasang Berlian)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  if (_currentOrder.status == 'diamond_setting_in_progress')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kewajiban Pemasangan Berlian:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('Pemasangan Berlian Selesai'),
                          value: _isDiamondSettingCompleted,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isDiamondSettingCompleted = newValue ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isProcessing
                                    ? null
                                    : _isDiamondSettingCompleted
                                    ? _submitToFinisherAsDiamondSetter
                                    : null,
                            icon:
                                _isProcessing
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.auto_awesome),
                            label: Text(
                              _isProcessing
                                  ? 'Memproses...'
                                  : 'Ajukan ke Tahap Finishing',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

            // Aksi untuk Finisher
            if (widget.userRole == 'finisher')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 30),
                  const Text(
                    'Aksi Finisher:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (_currentOrder.status == 'ready_for_finishing')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isProcessing ? null : _acceptOrderAsFinisher,
                        icon:
                            _isProcessing
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.brush),
                        label: Text(
                          _isProcessing
                              ? 'Memproses...'
                              : 'Terima Pesanan (Mulai Finishing)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  if (_currentOrder.status == 'finishing_in_progress')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kewajiban Finishing:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('Finishing Selesai'),
                          value: _isFinishingCompleted,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isFinishingCompleted = newValue ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isProcessing
                                    ? null
                                    : _isFinishingCompleted
                                    ? _markAsReadyForPickupAsFinisher
                                    : null,
                            icon:
                                _isProcessing
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.store),
                            label: Text(
                              _isProcessing
                                  ? 'Memproses...'
                                  : 'Tandai Siap Diambil Pelanggan',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

            const SizedBox(height: 20),

            // --- Gambar Referensi ---
            Text(
              'Gambar Referensi',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 10, thickness: 1),
            if (_currentOrder.referenceImagePaths != null &&
                _currentOrder.referenceImagePaths!.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Tampilkan 2 gambar per baris
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _currentOrder.referenceImagePaths!.length,
                itemBuilder: (context, index) {
                  final imagePath = _currentOrder.referenceImagePaths![index];
                  // Pastikan path gambar valid dan File ada
                  if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
                    return ClipRRect(
                      // Tambahkan ClipRRect untuk border radius
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Handle error loading image
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 40,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Gambar tidak ditemukan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              )
            else
              const Text(
                'Tidak ada gambar referensi yang diunggah.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
