import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String ordersId;
  final String customerName;

  const OrderHistoryScreen({
    Key? key,
    required this.ordersId,
    required this.customerName,
  }) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();

  List<Map<String, dynamic>> _timeline = [];
  List<Map<String, dynamic>> _workflowTransitions = [];
  List<Map<String, dynamic>> _fullHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHistoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _orderService.getOrderTimeline(widget.ordersId),
        _orderService.getWorkflowTransitions(widget.ordersId),
        _orderService.getOrderHistory(widget.ordersId),
      ]);

      setState(() {
        _timeline = results[0];
        _workflowTransitions = results[1];
        _fullHistory = results[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading history: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('History Pesanan'),
            Text(
              widget.customerName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Timeline', icon: Icon(Icons.timeline)),
            Tab(text: 'Workflow', icon: Icon(Icons.swap_horiz)),
            Tab(text: 'Detail', icon: Icon(Icons.list_alt)),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildTimelineTab(),
                  _buildWorkflowTab(),
                  _buildDetailTab(),
                ],
              ),
    );
  }

  Widget _buildTimelineTab() {
    if (_timeline.isEmpty) {
      return const Center(child: Text('Tidak ada data timeline'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _timeline.length,
      itemBuilder: (context, index) {
        final item = _timeline[index];
        final isLast = index == _timeline.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getStatusColor(item['action'] ?? ''),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 50, color: Colors.grey[300]),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['description'] ?? 'No description',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                item['action'] ?? '',
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(item['action'] ?? ''),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              item['action'] ?? 'UNKNOWN',
                              style: TextStyle(
                                color: _getStatusColor(item['action'] ?? ''),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (item['changed_by_name'] != null)
                        Text(
                          'Oleh: ${item['changed_by_name']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(item['created_at']),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkflowTab() {
    if (_workflowTransitions.isEmpty) {
      return const Center(child: Text('Tidak ada data workflow transitions'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _workflowTransitions.length,
      itemBuilder: (context, index) {
        final transition = _workflowTransitions[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transition['from_status'] ?? 'Unknown',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transition['to_status'] ?? 'Unknown',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (transition['changed_by_name'] != null)
                  Text(
                    'Oleh: ${transition['changed_by_name']}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(transition['transition_date']),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (transition['notes'] != null &&
                    transition['notes'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Catatan: ${transition['notes']}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTab() {
    if (_fullHistory.isEmpty) {
      return const Center(child: Text('Tidak ada data history detail'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _fullHistory.length,
      itemBuilder: (context, index) {
        final item = _fullHistory[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              item['description'] ?? 'No description',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Action: ${item['action'] ?? 'UNKNOWN'}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  _formatDateTime(item['created_at']),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item['changed_by_name'] != null)
                      _buildDetailRow('Changed By', item['changed_by_name']),
                    if (item['old_data'] != null)
                      _buildDetailRow('Old Data', item['old_data'].toString()),
                    if (item['new_data'] != null)
                      _buildDetailRow('New Data', item['new_data'].toString()),
                    if (item['additional_data'] != null)
                      _buildDetailRow(
                        'Additional Data',
                        item['additional_data'].toString(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(String action) {
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
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'Unknown date';

    try {
      DateTime dt = DateTime.parse(dateTime.toString());
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (e) {
      return dateTime.toString();
    }
  }
}
