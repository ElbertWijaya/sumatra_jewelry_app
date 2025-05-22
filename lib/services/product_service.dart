// lib/services/product_service.dart
class ProductService {
  // Metode placeholder untuk menambahkan produk
  // Nanti Anda akan menambahkan logika untuk menyimpan ke database/API
  Future<void> addProduct(String name, int quantity, double price) async {
    // Simulasi penyimpanan data
    print('Produk baru ditambahkan (simulasi):');
    print('Nama: $name');
    print('Jumlah: $quantity');
    print('Harga: $price');
    await Future.delayed(const Duration(milliseconds: 500)); // Simulasi delay
  }
}