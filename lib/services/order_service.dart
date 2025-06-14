import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderService {
  static const String baseUrl = 'http://192.168.187.174/sumatra_api/get_orders.php';

  Future<List<Order>> getOrders() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Order.fromJson(json)).toList().cast<Order>();
    } else {
      throw Exception('Gagal memuat pesanan: ${response.statusCode}');
    }
  }

  Future<void> addOrders(Order order) async {
    // Print isi imagePaths sebelum request
    print('ImagePaths yang dikirim: ${jsonEncode(order.imagePaths)}');

    final response = await http.post(
      Uri.parse('http://192.168.187.174/sumatra_api/add_orders.php'),
      body: {
        'id': order.id.toString(),
        'customer_name': order.customerName,
        'customer_contact': order.customerContact,
        'address': order.address,
        'jewelry_type': order.jewelryType,
        'gold_type': order.goldType,
        'gold_color': order.goldColor,
        'final_price': order.finalPrice.toString(),
        'notes': order.notes,
        'pickup_date': order.pickupDate != null ? DateFormat('yyyy-MM-dd').format(order.pickupDate!) : '',
        'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(order.createdAt),
        'gold_price_per_gram': order.goldPricePerGram.toString(),
        'stone_type': order.stoneType ?? '',
        'stone_size': order.stoneSize ?? '',
        'ring_size': order.ringSize ?? '',
        'ready_date': order.readyDate != null ? DateFormat('yyyy-MM-dd').format(order.readyDate!) : '',
        'dp': order.dp.toString(),
        'sisa_lunas': order.sisaLunas.toString(),
        'imagePaths': jsonEncode(order.imagePaths ?? []),
        'workflow_status': order.workflowStatus.name, // <-- Tambahkan baris ini!
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menambah pesanan: ${response.body}');
    }
    final result = json.decode(response.body);
    if (result['success'] != true) {
      throw Exception('Gagal menambah pesanan (API): ${response.body}');
    }
  }

  Future<bool> updateOrder(Order order) async {
    final response = await http.post(
      Uri.parse('http://192.168.187.174/sumatra_api/update_order.php'),
      body: {
        'id': order.id,
        'customer_name': order.customerName,
        'customer_contact': order.customerContact,
        'address': order.address,
        'jewelry_type': order.jewelryType,
        'gold_type': order.goldType,
        'gold_color': order.goldColor,
        'final_price': order.finalPrice.toString(),
        'notes': order.notes,
        'pickup_date': order.pickupDate != null
            ? "${order.pickupDate!.year.toString().padLeft(4, '0')}-${order.pickupDate!.month.toString().padLeft(2, '0')}-${order.pickupDate!.day.toString().padLeft(2, '0')}"
            : '',
        'gold_price_per_gram': order.goldPricePerGram.toString(),
        'stone_type': order.stoneType,
        'stone_size': order.stoneSize,
        'ring_size': order.ringSize,
        'ready_date': order.readyDate != null
            ? "${order.readyDate!.year.toString().padLeft(4, '0')}-${order.readyDate!.month.toString().padLeft(2, '0')}-${order.readyDate!.day.toString().padLeft(2, '0')}"
            : '',
        'dp': order.dp.toString(),
        'sisa_lunas': order.sisaLunas.toString(),
        'imagePaths': jsonEncode(order.imagePaths ?? []),
        'workflow_status': order.workflowStatus.name,
        'designerWorkChecklist': jsonEncode(order.designerWorkChecklist ?? []),
        'castingWorkChecklist': jsonEncode(order.castingWorkChecklist ?? []),
        'carvingWorkChecklist': jsonEncode(order.carvingWorkChecklist ?? []),
        'diamondSettingWorkChecklist': jsonEncode(order.diamondSettingWorkChecklist ?? []),
        'finishingWorkChecklist': jsonEncode(order.finishingWorkChecklist ?? []),
        'inventoryChecklist': jsonEncode(order.inventoryWorkChecklist ?? []),

        // Tambahkan checklist lain jika perlu
      },
    );
    if (response.statusCode != 200) return false;
    final result = json.decode(response.body);
    return result['success'] == true;
  }

  Future<void> deleteOrders(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl?id=$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus pesanan: ${response.body}');
    }
    final result = json.decode(response.body);
    if (result['success'] != true) {
      throw Exception('Gagal menghapus pesanan (API): ${response.body}');
    }
  }

  Future<Order> getOrderById(String id) async {
    final response = await http.get(
      Uri.parse('http://192.168.187.174/sumatra_api/get_order_by_id.php?id=$id'),
    );
    final data = jsonDecode(response.body);
    return Order.fromJson(data);
  }
}