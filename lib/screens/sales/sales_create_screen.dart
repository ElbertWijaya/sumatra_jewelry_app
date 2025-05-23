import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';

class SalesCreateScreen extends StatefulWidget {
  const SalesCreateScreen({Key? key}) : super(key: key);

  @override
  State<SalesCreateScreen> createState() => _SalesCreateScreenState();
}

class _SalesCreateScreenState extends State<SalesCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<OrderItem> _orderItems = [];
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  Product? _selectedProduct;
  int _selectedQuantity = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      _products = await _productService.getProducts();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
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
    if (!_formKey.currentState!.validate() || _orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and add at least one product.'),
        ),
      );
      return;
    }
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: _customerNameController.text.trim(),
      items: List<OrderItem>.from(_orderItems),
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
    );
    setState(() => _isLoading = true);
    try {
      await _orderService.addOrder(newOrder);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create order: $e')));
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
      appBar: AppBar(title: const Text('Create Order')),
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          child: const Text('Submit Order'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
