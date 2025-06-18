import 'package:flutter/material.dart';

class InventoryListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> inventoryItems;
  final void Function(Map<String, dynamic>)? onEdit;
  final void Function(Map<String, dynamic>)? onDelete;

  const InventoryListScreen({
    super.key,
    required this.inventoryItems,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Inventory'),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: ListView.builder(
        itemCount: inventoryItems.length,
        itemBuilder: (context, index) {
          final item = inventoryItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(item['inventory_product_id'] ?? '-'),
              subtitle: Text(item['inventory_jewelry_type'] ?? '-'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.amber),
                    onPressed: onEdit != null ? () => onEdit!(item) : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete != null ? () => onDelete!(item) : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
