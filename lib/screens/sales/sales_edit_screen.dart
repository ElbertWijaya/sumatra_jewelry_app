import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';

class SalesEditScreen extends StatefulWidget {
  final String orderId;
  const SalesEditScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<SalesEditScreen> createState() => _SalesEditScreenState();
}

class _SalesEditScreenState extends State<SalesEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<OrderItem> _orderItems = [];
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  Product? _selectedProduct;
  int _selectedQuantity = 1;
  OrderStatus? _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    try {
      final order = await _orderService.getOrderById(widget.orderId);
      final products = await _productService.getProducts();
      if (!mounted) return;
      if (order != null) {
        _customerNameController.text = order.customerName;
        _notesController.text = order.notes ?? '';
        _orderItems = List<OrderItem>.from(order.items);
        _selectedStatus = order.status;
      }
      _products = products;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
    }
    setState(() => _isLoading = false);
  }

  void _addOrderItem() {
    if (_selectedProduct == null) return;
    final existsIndex = _orderItems.indexWhere(
      (item) => item.productId == _selectedProduct!.id,
    );
    if (existsIndex != -1) {
      setState(() {
        _orderItems[existsIndex] = _orderItems[existsIndex].copyWith(
          quantity: _orderItems[existsIndex].quantity + _selectedQuantity,
        );
      });
    } else {
      setState(() {
        _orderItems.add(
          OrderItem(
            productId: _selectedProduct!.id,
            productName: _selectedProduct!.name,
            quantity: _selectedQuantity,
            price: _selectedProduct!.price,
          ),
        );
      });
    }
    _selectedProduct = null;
    _selectedQuantity = 1;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() ||
        _orderItems.isEmpty ||
        _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields, select status, and add at least one product.',
          ),
        ),
      );
      return;
    }
    final updatedOrder = Order(
      id: widget.orderId,
      customerName: _customerNameController.text.trim(),
      items: List<OrderItem>.from(_orderItems),
      status: _selectedStatus!,
      createdAt:
          DateTime.now(), // Optionally: keep original createdAt if available
      updatedAt: DateTime.now(),
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
    );
    setState(() => _isLoading = true);
    try {
      await _orderService.updateOrder(updatedOrder);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update order: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI code, no major changes, just maintainable logic
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Order')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                        ),
                        validator:
                            (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                      ),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<Product>(
                              value: _selectedProduct,
                              hint: const Text('Select Product'),
                              items:
                                  _products
                                      .map(
                                        (product) => DropdownMenuItem(
                                          value: product,
                                          child: Text(
                                            '${product.name} (\u20B9${product.price.toStringAsFixed(2)})',
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (product) {
                                setState(() {
                                  _selectedProduct = product;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 70,
                            child: TextFormField(
                              initialValue: _selectedQuantity.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Qty',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                final q = int.tryParse(val) ?? 1;
                                setState(
                                  () => _selectedQuantity = q.clamp(1, 100),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed:
                                _selectedProduct == null ? null : _addOrderItem,
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_orderItems.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Order Items:'),
                            ..._orderItems.map(
                              (item) => ListTile(
                                title: Text(
                                  '${item.productName} x${item.quantity}',
                                ),
                                subtitle: Text(
                                  '\u20B9${(item.price * item.quantity).toStringAsFixed(2)}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _orderItems.remove(item);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<OrderStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Order Status',
                        ),
                        items:
                            OrderStatus.values
                                .where((s) => s != OrderStatus.unknown)
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status.label),
                                  ),
                                )
                                .toList(),
                        onChanged: (status) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        },
                        validator:
                            (value) => value == null ? 'Select status' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          child: const Text('Update Order'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
