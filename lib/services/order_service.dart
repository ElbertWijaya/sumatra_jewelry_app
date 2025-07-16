import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderService {
  static const String baseUrl =
      'http://192.168.83.54/sumatra_api/get_orders.php';

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
    print('ImagePaths yang dikirim: ${jsonEncode(order.ordersImagePaths)}');
    final response = await http.post(
      Uri.parse('http://192.168.83.54/sumatra_api/add_orders.php'),
      body: {
        'orders_id': order.ordersId,
        'orders_customer_name': order.ordersCustomerName,
        'orders_customer_contact': order.ordersCustomerContact,
        'orders_address': order.ordersAddress,
        'orders_jewelry_type': order.ordersJewelryType,
        'orders_gold_type': order.ordersGoldType,
        'orders_gold_color': order.ordersGoldColor,
        'orders_final_price': order.ordersFinalPrice.toString(),
        'orders_note': order.ordersNote,
        'orders_pickup_date':
            order.ordersPickupDate != null
                ? DateFormat('yyyy-MM-dd').format(order.ordersPickupDate!)
                : '',
        'orders_created_at': DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(order.ordersCreatedAt),
        'orders_gold_price_per_gram': order.ordersGoldPricePerGram.toString(),
        'orders_ring_size': order.ordersRingSize,
        'orders_ready_date':
            order.ordersReadyDate != null
                ? DateFormat('yyyy-MM-dd').format(order.ordersReadyDate!)
                : '',
        'orders_dp': order.ordersDp.toString(),
        'orders_sisa_lunas': order.ordersSisaLunas.toString(),
        'orders_imagePaths': jsonEncode(order.ordersImagePaths),
        'orders_workflowStatus': order.ordersWorkflowStatus.name,
        'orders_designerWorkChecklist': jsonEncode(
          order.ordersDesignerWorkChecklist,
        ),
        'orders_castingWorkChecklist': jsonEncode(
          order.ordersCastingWorkChecklist,
        ),
        'orders_carvingWorkChecklist': jsonEncode(
          order.ordersCarvingWorkChecklist,
        ),
        'orders_diamondSettingWorkChecklist': jsonEncode(
          order.ordersDiamondSettingWorkChecklist,
        ),
        'orders_finishingWorkChecklist': jsonEncode(
          order.ordersFinishingWorkChecklist,
        ),
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
      Uri.parse('http://192.168.83.54/sumatra_api/update_order.php'),
      body: {
        'orders_id': order.ordersId,
        'orders_customer_name': order.ordersCustomerName,
        'orders_customer_contact': order.ordersCustomerContact,
        'orders_address': order.ordersAddress,
        'orders_jewelry_type': order.ordersJewelryType,
        'orders_gold_type': order.ordersGoldType,
        'orders_gold_color': order.ordersGoldColor,
        'orders_final_price': order.ordersFinalPrice.toString(),
        'orders_note': order.ordersNote,
        'orders_pickup_date':
            order.ordersPickupDate != null
                ? "${order.ordersPickupDate!.year.toString().padLeft(4, '0')}-${order.ordersPickupDate!.month.toString().padLeft(2, '0')}-${order.ordersPickupDate!.day.toString().padLeft(2, '0')}"
                : '',
        'orders_gold_price_per_gram': order.ordersGoldPricePerGram.toString(),
        'orders_ring_size': order.ordersRingSize,
        'orders_ready_date':
            order.ordersReadyDate != null
                ? "${order.ordersReadyDate!.year.toString().padLeft(4, '0')}-${order.ordersReadyDate!.month.toString().padLeft(2, '0')}-${order.ordersReadyDate!.day.toString().padLeft(2, '0')}"
                : '',
        'orders_dp': order.ordersDp.toString(),
        'orders_sisa_lunas': order.ordersSisaLunas.toString(),
        'orders_imagePaths': jsonEncode(order.ordersImagePaths),
        'orders_workflowStatus': order.ordersWorkflowStatus.name,
        'orders_designerWorkChecklist': jsonEncode(
          order.ordersDesignerWorkChecklist,
        ),
        'orders_castingWorkChecklist': jsonEncode(
          order.ordersCastingWorkChecklist,
        ),
        'orders_carvingWorkChecklist': jsonEncode(
          order.ordersCarvingWorkChecklist,
        ),
        'orders_diamondSettingWorkChecklist': jsonEncode(
          order.ordersDiamondSettingWorkChecklist,
        ),
        'orders_finishingWorkChecklist': jsonEncode(
          order.ordersFinishingWorkChecklist,
        ),
      },
    );
    if (response.statusCode != 200) return false;
    final result = json.decode(response.body);
    return result['success'] == true;
  }

  Future<void> deleteOrders(String ordersId) async {
    final response = await http.delete(
      Uri.parse(
        'http://192.168.83.54/sumatra_api/delete_orders.php?orders_id=$ordersId',
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus pesanan: ${response.body}');
    }
    final result = json.decode(response.body);
    if (result['success'] != true) {
      throw Exception('Gagal menghapus pesanan (API): ${response.body}');
    }
  }

  Future<Order> getOrderById(String ordersId) async {
    final response = await http.get(
      Uri.parse(
        'http://192.168.83.54/sumatra_api/get_order_by_id.php?orders_id=$ordersId',
      ),
    );
    print('RESPONSE BODY: ${response.body}');
    final data = jsonDecode(response.body);
    return Order.fromJson(data);
  }
}
