// sumatra_jewelry_app/screens/sales/create_order_screen.dart
import 'package:flutter/material.dart';
import 'package:sumatra_jewelry_app/models/order.dart';
import 'package:sumatra_jewelry_app/services/order_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk input teks
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController(); // Pastikan ini ada
  final TextEditingController _diamondSizeController = TextEditingController();
  final TextEditingController _ringSizeController = TextEditingController();
  final TextEditingController _estimatedCompletionDateController =
      TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _goldPricePerGramController =
      TextEditingController();
  final TextEditingController _finalProductPriceController =
      TextEditingController();
  final TextEditingController _estimatedPriceController =
      TextEditingController();

  String? _selectedJewelryType;
  String? _selectedGoldType;

  // List untuk menyimpan File gambar yang dipilih
  final List<File> _selectedReferenceImages = [];
  final ImagePicker _picker = ImagePicker();

  // List pilihan jenis perhiasan
  final List<String> _jewelryTypes = [
    'Cincin',
    'Kalung',
    'Anting',
    'Gelang',
    'Liontin',
    'Lainnya',
  ];

  // List pilihan jenis emas
  final List<String> _goldTypes = [
    'Emas Putih 18K',
    'Emas Putih 14K',
    'Emas Kuning 24K',
    'Emas Kuning 22K',
    'Emas Kuning 18K',
    'Emas Kuning 14K',
    'Rose Gold 18K',
    'Rose Gold 14K',
    'Perak',
    'Platinum',
    'Lainnya',
  ];

  final OrderService _orderService = OrderService();
  bool _isLoading = false;

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _pickReferenceImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedReferenceImages.addAll(
            images.map((xfile) => File(xfile.path)),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
      print('Error selecting images: $e');
    }
  }

  void _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      DateTime? estimatedCompletionDateTime;
      if (_estimatedCompletionDateController.text.isNotEmpty) {
        try {
          List<String> parts = _estimatedCompletionDateController.text.split(
            '/',
          );
          estimatedCompletionDateTime = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } catch (e) {
          print('Error parsing estimated completion date: $e');
        }
      }

      DateTime? pickupDateTime;
      if (_pickupDateController.text.isNotEmpty) {
        try {
          List<String> parts = _pickupDateController.text.split('/');
          pickupDateTime = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } catch (e) {
          print('Error parsing pickup date: $e');
        }
      }

      // Parsing nilai numerik
      double? estimatedPriceParsed;
      try {
        estimatedPriceParsed = double.parse(_estimatedPriceController.text);
      } catch (e) {
        // Handle error parsing, set to 0.0 or show error
        print('Error parsing estimated price: $e');
        estimatedPriceParsed = 0.0; // Default ke 0.0 jika gagal parse
      }

      final newOrder = Order(
        // PENTING: Gunakan ID unik untuk setiap pesanan baru
        id: DateTime.now().millisecondsSinceEpoch,
        customerName: _customerNameController.text,
        phoneNumber: _phoneNumberController.text,
        address: _addressController.text,
        // Gabungkan jenis perhiasan dengan nama produk
        productName:
            _selectedJewelryType != null
                ? '(${_selectedJewelryType!}) ${_productNameController.text}'
                : _productNameController.text,
        productDescription:
            _productDescriptionController
                .text, // Pastikan ini mengambil dari controller yang benar
        estimatedPrice:
            estimatedPriceParsed, // Gunakan nilai yang sudah di-parse
        status: 'pending', // Status awal untuk pesanan baru
        orderDate: DateTime.now(),
        currentWorkerRole: 'Sales', // Peran yang membuat pesanan
        diamondSize:
            _diamondSizeController.text.isNotEmpty
                ? _diamondSizeController.text
                : null,
        ringSize:
            _ringSizeController.text.isNotEmpty
                ? _ringSizeController.text
                : null,
        estimatedCompletionDate: estimatedCompletionDateTime,
        pickupDate: pickupDateTime,
        goldPricePerGram: double.tryParse(_goldPricePerGramController.text),
        finalProductPrice: double.tryParse(_finalProductPriceController.text),
        goldType: _selectedGoldType, // Biarkan nullable jika memungkinkan
        referenceImagePaths:
            _selectedReferenceImages.map((file) => file.path).toList(),
        lastUpdate: DateTime.now(), // Setel waktu update terakhir saat dibuat
      );

      try {
        await _orderService.addOrder(newOrder);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil ditambahkan!')),
        );
        // Kembali ke layar sebelumnya dan beri tahu bahwa ada pesanan baru
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan pesanan: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _productNameController.dispose();
    _productDescriptionController.dispose(); // Pastikan ini juga di-dispose
    _diamondSizeController.dispose();
    _ringSizeController.dispose();
    _estimatedCompletionDateController.dispose();
    _pickupDateController.dispose();
    _goldPricePerGramController.dispose();
    _finalProductPriceController.dispose();
    _estimatedPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pesanan Baru')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pelanggan',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama pelanggan wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor telepon wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Alamat',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Alamat wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Jenis Perhiasan',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        value: _selectedJewelryType,
                        items:
                            _jewelryTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedJewelryType = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jenis perhiasan wajib dipilih';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Jenis Emas',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.science),
                        ),
                        value: _selectedGoldType,
                        items:
                            _goldTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGoldType = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jenis emas wajib dipilih';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _productNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Produk (Detail Produk)',
                          hintText: 'Cincin Kawin Berlian',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama produk wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller:
                            _productDescriptionController, // Pastikan ini juga ada di sini
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi Produk',
                          hintText:
                              'Detail seperti bentuk, ukiran, atau fitur khusus',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _diamondSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Berlian',
                          hintText:
                              'Contoh: 0.004ct/16 biji, 0.105ct/5 biji, 1ct/1 biji',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.diamond),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _ringSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Ukuran Cincin',
                          hintText: 'Contoh: Size 14, Diameter 1.65 cm',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.ring_volume),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _estimatedCompletionDateController,
                        decoration: InputDecoration(
                          labelText: 'Estimasi Selesai',
                          hintText: 'DD/MM/YYYY',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed:
                                () => _selectDate(
                                  context,
                                  _estimatedCompletionDateController,
                                ),
                          ),
                        ),
                        readOnly: true,
                        onTap:
                            () => _selectDate(
                              context,
                              _estimatedCompletionDateController,
                            ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _pickupDateController,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Diambil',
                          hintText: 'DD/MM/YYYY',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed:
                                () =>
                                    _selectDate(context, _pickupDateController),
                          ),
                        ),
                        readOnly: true,
                        onTap:
                            () => _selectDate(context, _pickupDateController),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _goldPricePerGramController,
                        decoration: const InputDecoration(
                          labelText: 'Harga Emas/Gram',
                          hintText: 'Contoh: 950000',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _estimatedPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Estimasi Harga Produk',
                          hintText: 'Harga total perkiraan',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Estimasi harga produk wajib diisi';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Masukkan angka yang valid untuk harga';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _finalProductPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Harga Akhir Produk',
                          hintText: 'Akan diisi saat produk terjual',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.money),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24.0),
                      // Bagian untuk Multi-Upload Gambar Referensi
                      const Text(
                        'Gambar Referensi Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      ElevatedButton.icon(
                        onPressed: _pickReferenceImages,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Tambah Gambar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      _selectedReferenceImages.isEmpty
                          ? const Text(
                            'Belum ada gambar referensi yang dipilih.',
                          )
                          : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                ),
                            itemCount: _selectedReferenceImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Image.file(
                                    _selectedReferenceImages[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedReferenceImages.removeAt(
                                            index,
                                          );
                                        });
                                      },
                                      child: Container(
                                        color: Colors.black54,
                                        child: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      const SizedBox(height: 24.0),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'Buat Pesanan',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
