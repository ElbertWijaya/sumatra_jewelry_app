import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryService {
  static const String baseUrl = 'http://192.168.110.147/sumatra_api';

  // Get order history timeline
  static Future<List<Map<String, dynamic>>> getOrderTimeline(
    String ordersId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_history.php?action=order_timeline&orders_id=$ordersId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('Failed to load order timeline');
    } catch (e) {
      throw Exception('Error fetching order timeline: $e');
    }
  }

  // Get workflow transitions
  static Future<List<Map<String, dynamic>>> getWorkflowTransitions(
    String ordersId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_history.php?action=workflow_transitions&orders_id=$ordersId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('Failed to load workflow transitions');
    } catch (e) {
      throw Exception('Error fetching workflow transitions: $e');
    }
  }

  // Get order snapshots
  static Future<List<Map<String, dynamic>>> getOrderSnapshots(
    String ordersId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_history.php?action=order_snapshots&orders_id=$ordersId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('Failed to load order snapshots');
    } catch (e) {
      throw Exception('Error fetching order snapshots: $e');
    }
  }

  // Get inventory history
  static Future<List<Map<String, dynamic>>> getInventoryHistory({
    String? ordersId,
    String? inventoryId,
  }) async {
    try {
      String url = '$baseUrl/get_history.php?action=inventory_history';
      if (ordersId != null) {
        url += '&orders_id=$ordersId';
      } else if (inventoryId != null) {
        url += '&inventory_id=$inventoryId';
      } else {
        throw Exception('Either ordersId or inventoryId must be provided');
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('Failed to load inventory history');
    } catch (e) {
      throw Exception('Error fetching inventory history: $e');
    }
  }

  // Get checklist progress
  static Future<List<Map<String, dynamic>>> getChecklistProgress(
    String ordersId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_history.php?action=checklist_progress&orders_id=$ordersId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('Failed to load checklist progress');
    } catch (e) {
      throw Exception('Error fetching checklist progress: $e');
    }
  }

  // Get recent activity
  static Future<List<Map<String, dynamic>>> getRecentActivity({
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_history.php?action=recent_activity&limit=$limit',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('Failed to load recent activity');
    } catch (e) {
      throw Exception('Error fetching recent activity: $e');
    }
  }

  // Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      String url = '$baseUrl/history_dashboard.php?action=dashboard_stats';
      if (dateFrom != null) url += '&date_from=$dateFrom';
      if (dateTo != null) url += '&date_to=$dateTo';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      throw Exception('Failed to load dashboard stats');
    } catch (e) {
      throw Exception('Error fetching dashboard stats: $e');
    }
  }

  // Get daily activity for charts
  static Future<List<Map<String, dynamic>>> getDailyActivity({
    int days = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/history_dashboard.php?action=daily_activity&days=$days',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('Failed to load daily activity');
    } catch (e) {
      throw Exception('Error fetching daily activity: $e');
    }
  }

  // Get performance metrics
  static Future<Map<String, dynamic>> getPerformanceMetrics({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      String url = '$baseUrl/history_dashboard.php?action=performance_metrics';
      if (dateFrom != null) url += '&date_from=$dateFrom';
      if (dateTo != null) url += '&date_to=$dateTo';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      throw Exception('Failed to load performance metrics');
    } catch (e) {
      throw Exception('Error fetching performance metrics: $e');
    }
  }

  // Get system health
  static Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history_dashboard.php?action=system_health'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      throw Exception('Failed to load system health');
    } catch (e) {
      throw Exception('Error fetching system health: $e');
    }
  }

  // Manually log history (for testing or special cases)
  static Future<bool> logOrderHistory({
    required String ordersId,
    required String actionType,
    String? fieldName,
    String? oldValue,
    String? newValue,
    String? workflowFrom,
    String? workflowTo,
    int? performedById,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/history_logger.php'),
        body: {
          'action': 'log_order_history',
          'orders_id': ordersId,
          'action_type': actionType,
          if (fieldName != null) 'field_name': fieldName,
          if (oldValue != null) 'old_value': oldValue,
          if (newValue != null) 'new_value': newValue,
          if (workflowFrom != null) 'workflow_from': workflowFrom,
          if (workflowTo != null) 'workflow_to': workflowTo,
          if (performedById != null)
            'performed_by_id': performedById.toString(),
          if (description != null) 'description': description,
          if (metadata != null) 'metadata': json.encode(metadata),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error logging history: $e');
      return false;
    }
  }

  // Log workflow transition
  static Future<bool> logWorkflowTransition({
    required String ordersId,
    required String fromStatus,
    required String toStatus,
    int? fromAccountId,
    int? toAccountId,
    int? performedById,
    Map<String, dynamic>? checklist,
    String? notes,
    int? duration,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/history_logger.php'),
        body: {
          'action': 'log_workflow_transition',
          'orders_id': ordersId,
          'from_status': fromStatus,
          'to_status': toStatus,
          if (fromAccountId != null)
            'from_account_id': fromAccountId.toString(),
          if (toAccountId != null) 'to_account_id': toAccountId.toString(),
          if (performedById != null)
            'performed_by_id': performedById.toString(),
          if (checklist != null) 'checklist': json.encode(checklist),
          if (notes != null) 'notes': notes,
          if (duration != null) 'duration': duration.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error logging workflow transition: $e');
      return false;
    }
  }

  // Create order snapshot
  static Future<bool> createOrderSnapshot({
    required String ordersId,
    required String workflowStatus,
    required Map<String, dynamic> orderData,
    Map<String, dynamic>? inventoryData,
    String? triggerAction,
    int? performedById,
    String snapshotType = 'MANUAL',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/history_logger.php'),
        body: {
          'action': 'create_snapshot',
          'orders_id': ordersId,
          'workflow_status': workflowStatus,
          'order_data': json.encode(orderData),
          if (inventoryData != null)
            'inventory_data': json.encode(inventoryData),
          if (triggerAction != null) 'trigger_action': triggerAction,
          if (performedById != null)
            'performed_by_id': performedById.toString(),
          'snapshot_type': snapshotType,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error creating snapshot: $e');
      return false;
    }
  }
}
