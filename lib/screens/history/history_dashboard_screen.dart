import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';

class HistoryDashboardScreen extends StatefulWidget {
  const HistoryDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HistoryDashboardScreen> createState() => _HistoryDashboardScreenState();
}

class _HistoryDashboardScreenState extends State<HistoryDashboardScreen> {
  final OrderService _orderService = OrderService();

  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _recentActivity = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _orderService.getDashboardStats(),
        _orderService.getRecentActivity(limit: 20),
      ]);

      setState(() {
        _dashboardStats = results[0] as Map<String, dynamic>;
        _recentActivity = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsSection(),
                      const SizedBox(height: 24),
                      _buildRecentActivitySection(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Sistem',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              'Total Orders',
              _dashboardStats['total_orders']?.toString() ?? '0',
              Icons.shopping_cart,
              Colors.blue,
            ),
            _buildStatCard(
              'Active Orders',
              _dashboardStats['active_orders']?.toString() ?? '0',
              Icons.pending_actions,
              Colors.orange,
            ),
            _buildStatCard(
              'Completed Orders',
              _dashboardStats['completed_orders']?.toString() ?? '0',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Total Inventory',
              _dashboardStats['total_inventory']?.toString() ?? '0',
              Icons.inventory,
              Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Workflow',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (_dashboardStats['workflow_status'] != null)
                  ..._buildWorkflowStatusList(
                    _dashboardStats['workflow_status'],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktivitas Hari Ini',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTodayActivityItem(
                      'Orders Created',
                      _dashboardStats['orders_today']?.toString() ?? '0',
                      Icons.add_circle,
                      Colors.blue,
                    ),
                    _buildTodayActivityItem(
                      'Status Changes',
                      _dashboardStats['status_changes_today']?.toString() ??
                          '0',
                      Icons.swap_horiz,
                      Colors.orange,
                    ),
                    _buildTodayActivityItem(
                      'Updates',
                      _dashboardStats['updates_today']?.toString() ?? '0',
                      Icons.edit,
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWorkflowStatusList(Map<String, dynamic> workflowStatus) {
    List<Widget> widgets = [];

    workflowStatus.forEach((status, count) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _formatStatusName(status),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(status)),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    return widgets;
  }

  Widget _buildTodayActivityItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas Terbaru',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full activity log
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_recentActivity.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Tidak ada aktivitas terbaru',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentActivity.length,
            itemBuilder: (context, index) {
              final activity = _recentActivity[index];
              return _buildActivityItem(activity);
            },
          ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActivityColor(
            activity['action'] ?? '',
          ).withOpacity(0.1),
          child: Icon(
            _getActivityIcon(activity['action'] ?? ''),
            color: _getActivityColor(activity['action'] ?? ''),
            size: 20,
          ),
        ),
        title: Text(
          activity['description'] ?? 'No description',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (activity['changed_by_name'] != null)
              Text(
                'Oleh: ${activity['changed_by_name']}',
                style: const TextStyle(fontSize: 12),
              ),
            Text(
              _formatDateTime(activity['created_at']),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getActivityColor(activity['action'] ?? '').withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            activity['action'] ?? 'UNKNOWN',
            style: TextStyle(
              color: _getActivityColor(activity['action'] ?? ''),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'waitingsalescheck':
        return Colors.blue;
      case 'waitingdesigner':
        return Colors.purple;
      case 'designing':
        return Colors.indigo;
      case 'waitingcasting':
        return Colors.orange;
      case 'casting':
        return Colors.deepOrange;
      case 'waitingcarving':
        return Colors.amber;
      case 'carving':
        return Colors.yellow[700]!;
      case 'waitingdiamondsetting':
        return Colors.pink;
      case 'stonesetting':
        return Colors.red;
      case 'waitingfinishing':
        return Colors.cyan;
      case 'finishing':
        return Colors.teal;
      case 'waitinginventory':
        return Colors.brown;
      case 'waitingsalescompletion':
        return Colors.lightGreen;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getActivityColor(String action) {
    switch (action.toUpperCase()) {
      case 'ORDER_CREATED':
        return Colors.blue;
      case 'STATUS_CHANGED':
        return Colors.orange;
      case 'SUBMIT_TO_DESIGNER':
        return Colors.purple;
      case 'ORDER_COMPLETED':
        return Colors.green;
      case 'ORDER_UPDATED':
        return Colors.amber;
      case 'INVENTORY_UPDATED':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String action) {
    switch (action.toUpperCase()) {
      case 'ORDER_CREATED':
        return Icons.add_circle;
      case 'STATUS_CHANGED':
        return Icons.swap_horiz;
      case 'SUBMIT_TO_DESIGNER':
        return Icons.send;
      case 'ORDER_COMPLETED':
        return Icons.check_circle;
      case 'ORDER_UPDATED':
        return Icons.edit;
      case 'INVENTORY_UPDATED':
        return Icons.inventory;
      default:
        return Icons.info;
    }
  }

  String _formatStatusName(String status) {
    switch (status.toLowerCase()) {
      case 'waitingsalescheck':
        return 'Waiting Sales Check';
      case 'waitingdesigner':
        return 'Waiting Designer';
      case 'designing':
        return 'Designing';
      case 'waitingcasting':
        return 'Waiting Casting';
      case 'casting':
        return 'Casting';
      case 'waitingcarving':
        return 'Waiting Carving';
      case 'carving':
        return 'Carving';
      case 'waitingdiamondsetting':
        return 'Waiting Diamond Setting';
      case 'stonesetting':
        return 'Stone Setting';
      case 'waitingfinishing':
        return 'Waiting Finishing';
      case 'finishing':
        return 'Finishing';
      case 'waitinginventory':
        return 'Waiting Inventory';
      case 'waitingsalescompletion':
        return 'Waiting Sales Completion';
      case 'done':
        return 'Done';
      default:
        return status;
    }
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'Unknown date';

    try {
      DateTime dt = DateTime.parse(dateTime.toString());
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('dd MMM yyyy, HH:mm').format(dt);
      }
    } catch (e) {
      return dateTime.toString();
    }
  }
}
