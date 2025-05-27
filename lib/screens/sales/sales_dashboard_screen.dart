import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/order.dart';
import '../../models/order_workflow.dart';
import '../../services/order_service.dart';
import 'sales_detail_screen.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  Object? _selectedStatusFilter;
  String? _selectedCategoryFilter;

  // Untuk filter sheet
  List<String> selectedJewelryTypes = [];
  List<String> selectedGoldColors = [];
  List<String> selectedGoldTypes = [];
  List<String> selectedStoneTypes = [];
  double? priceMin;
  double? priceMax;
  String? ringSize;

  // Random category display
  List<String> _randomCategoryFilters = [];
  bool _isRandomCategoryActive = true;

  final List<OrderWorkflowStatus> waitingStatuses = [
    OrderWorkflowStatus.waitingSalesCheck,
  ];

  final List<OrderWorkflowStatus> activeStatuses = [
    OrderWorkflowStatus.waitingSalesCheck,
    OrderWorkflowStatus.waitingDesigner,
    OrderWorkflowStatus.pending,
    OrderWorkflowStatus.designing,
    OrderWorkflowStatus.waitingCasting,
    OrderWorkflowStatus.readyForCasting,
    OrderWorkflowStatus.casting,
    OrderWorkflowStatus.waitingCarving,
    OrderWorkflowStatus.readyForCarving,
    OrderWorkflowStatus.carving,
    OrderWorkflowStatus.waitingDiamondSetting,
    OrderWorkflowStatus.readyForStoneSetting,
    OrderWorkflowStatus.stoneSetting,
    OrderWorkflowStatus.waitingFinishing,
    OrderWorkflowStatus.readyForFinishing,
    OrderWorkflowStatus.finishing,
    OrderWorkflowStatus.waitingInventory,
    OrderWorkflowStatus.readyForInventory,
    OrderWorkflowStatus.inventory,
    OrderWorkflowStatus.waitingSalesCompletion,
  ];

  final List<String> categories = ['Progress', 'Jenis', 'Harga'];

  final List<String> jewelryTypes = [
    "ring",
    "bangle",
    "earring",
    "pendant",
    "hairpin",
    "pin",
    "men ring",
    "women ring",
    "engagement ring",
    "custom",
  ];
  final List<String> goldColors = ["White Gold", "Rose Gold", "Yellow Gold"];
  final List<String> goldTypes = ["19K", "18K", "14K", "9K"];
  final List<String> stoneTypes = [
    "Opal",
    "Sapphire",
    "Jade",
    "Emerald",
    "Ruby",
    "Amethyst",
    "Diamond",
  ];

  static const Color categoryActiveBgColor = Color(0xFFFAF5E0);
  static const Color categoryInactiveBgColor = Colors.white;
  static const Color categoryInactiveTextColor = Color(0xFF656359);

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _generateRandomCategoryFilters() {
    final allOptions = [
      ...jewelryTypes,
      ...goldColors,
      ...goldTypes,
      ...stoneTypes,
      'Ring Size: 13',
      'Ring Size: 10',
      'Ring Size: 12',
      'Ring Size: 7',
      'Ring Size: 5',
    ];
    allOptions.shuffle(Random());
    setState(() {
      _randomCategoryFilters = allOptions.take(5).toList();
      _isRandomCategoryActive = true;
      _selectedCategoryFilter = null;
      selectedJewelryTypes.clear();
      selectedGoldColors.clear();
      selectedGoldTypes.clear();
      selectedStoneTypes.clear();
      priceMin = null;
      priceMax = null;
      ringSize = null;
    });
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final fetchedOrders = await _orderService.getOrders();
      setState(() {
        _orders = fetchedOrders;
      });
      _generateRandomCategoryFilters();
    } catch (e) {
      setState(() {
        _errorMessage =
            'Gagal memuat pesanan: ${e.toString().replaceAll('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String orderFullText(Order order) {
    return [
      order.customerName,
      order.customerContact,
      order.address,
      order.jewelryType,
      order.stoneType ?? '',
      order.stoneSize ?? '',
      order.ringSize ?? '',
      order.readyDate?.toIso8601String() ?? '',
      order.pickupDate?.toIso8601String() ?? '',
      order.goldPricePerGram?.toString() ?? '',
      order.finalPrice?.toString() ?? '',
      order.notes ?? '',
      order.workflowStatus.label,
      order.assignedDesigner ?? '',
      order.assignedCaster ?? '',
      order.assignedCarver ?? '',
      order.assignedDiamondSetter ?? '',
      order.assignedFinisher ?? '',
      order.assignedInventory ?? '',
    ].join(' ').toLowerCase();
  }

  List<Order> get _filteredOrders {
    List<Order> filtered =
        _orders
            .where((order) => activeStatuses.contains(order.workflowStatus))
            .toList();

    if (_selectedCategoryFilter != null &&
        _selectedCategoryFilter!.isNotEmpty &&
        !_isDefaultCategory(_selectedCategoryFilter!)) {
      filtered =
          filtered.where((order) {
            return orderFullText(
              order,
            ).contains(_selectedCategoryFilter!.toLowerCase());
          }).toList();
    }

    if (selectedJewelryTypes.isNotEmpty) {
      filtered =
          filtered.where((order) {
            return selectedJewelryTypes.any(
              (t) =>
                  (order.jewelryType.toLowerCase()).contains(t.toLowerCase()),
            );
          }).toList();
    }
    if (selectedGoldColors.isNotEmpty) {
      filtered =
          filtered.where((order) {
            final info = orderFullText(order);
            return selectedGoldColors.any(
              (gold) => info.contains(gold.toLowerCase()),
            );
          }).toList();
    }
    if (selectedGoldTypes.isNotEmpty) {
      filtered =
          filtered.where((order) {
            final info = orderFullText(order);
            return selectedGoldTypes.any((t) => info.contains(t.toLowerCase()));
          }).toList();
    }
    if (selectedStoneTypes.isNotEmpty) {
      filtered =
          filtered.where((order) {
            final stones = (order.stoneType ?? '').toLowerCase();
            return selectedStoneTypes.any(
              (stone) => stones.contains(stone.toLowerCase()),
            );
          }).toList();
    }
    if (priceMin != null) {
      filtered =
          filtered
              .where((order) => (order.finalPrice ?? 0) >= priceMin!)
              .toList();
    }
    if (priceMax != null) {
      filtered =
          filtered
              .where((order) => (order.finalPrice ?? 0) <= priceMax!)
              .toList();
    }
    if (ringSize != null && ringSize!.isNotEmpty) {
      filtered =
          filtered.where((order) {
            return (order.ringSize ?? '').toLowerCase().contains(
              ringSize!.toLowerCase(),
            );
          }).toList();
    }

    if (_selectedStatusFilter == null) {
      // Semua status aktif
    } else if (_selectedStatusFilter == 'waiting') {
      filtered =
          filtered
              .where((order) => waitingStatuses.contains(order.workflowStatus))
              .toList();
    } else if (_selectedStatusFilter is OrderWorkflowStatus) {
      filtered =
          filtered
              .where((order) => order.workflowStatus == _selectedStatusFilter)
              .toList();
    } else if (_selectedStatusFilter == 'onProgress') {
      filtered =
          filtered
              .where((order) => !waitingStatuses.contains(order.workflowStatus))
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((order) {
            return orderFullText(order).contains(_searchQuery.toLowerCase());
          }).toList();
    }

    return filtered;
  }

  bool _isDefaultCategory(String? value) {
    return value == 'Progress' || value == 'Jenis' || value == 'Harga';
  }

  Widget _buildStatusFilterButton(
    String label,
    Object? filterValue,
    Color color,
  ) {
    int count;
    if (filterValue == null) {
      count =
          _orders
              .where((order) => activeStatuses.contains(order.workflowStatus))
              .length;
    } else if (filterValue == 'waiting') {
      count =
          _orders
              .where((order) => waitingStatuses.contains(order.workflowStatus))
              .length;
    } else if (filterValue is OrderWorkflowStatus) {
      count =
          _orders.where((order) => order.workflowStatus == filterValue).length;
    } else if (filterValue == 'onProgress') {
      count =
          _orders
              .where(
                (order) =>
                    activeStatuses.contains(order.workflowStatus) &&
                    !waitingStatuses.contains(order.workflowStatus),
              )
              .length;
    } else {
      count = 0;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedStatusFilter = filterValue;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color:
                  _selectedStatusFilter == filterValue
                      ? color.withAlpha((255 * 0.8).round())
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _selectedStatusFilter == filterValue ? color : Colors.grey,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color:
                        _selectedStatusFilter == filterValue
                            ? Colors.white
                            : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color:
                        _selectedStatusFilter == filterValue
                            ? Colors.white
                            : color,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color:
                          _selectedStatusFilter == filterValue
                              ? color
                              : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetCategoryFilter() {
    setState(() {
      _generateRandomCategoryFilters();
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Jenis Perhiasan
                        Text(
                          "Jenis Perhiasan",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 8,
                          children:
                              jewelryTypes
                                  .map(
                                    (type) => FilterChip(
                                      label: Text(
                                        type,
                                        style: const TextStyle(
                                          color: categoryInactiveTextColor,
                                        ),
                                      ),
                                      selected: selectedJewelryTypes.contains(
                                        type,
                                      ),
                                      showCheckmark: false,
                                      backgroundColor: categoryInactiveBgColor,
                                      selectedColor: categoryActiveBgColor,
                                      side: BorderSide(
                                        color:
                                            selectedJewelryTypes.contains(type)
                                                ? categoryActiveBgColor
                                                : categoryInactiveBgColor,
                                      ),
                                      labelStyle: TextStyle(
                                        color: categoryInactiveTextColor,
                                      ),
                                      onSelected: (selected) {
                                        setModalState(() {
                                          selected
                                              ? selectedJewelryTypes.add(type)
                                              : selectedJewelryTypes.remove(
                                                type,
                                              );
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 16),
                        // Warna Emas
                        Text(
                          "Warna Emas",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 8,
                          children:
                              goldColors
                                  .map(
                                    (color) => FilterChip(
                                      label: Text(
                                        color,
                                        style: const TextStyle(
                                          color: categoryInactiveTextColor,
                                        ),
                                      ),
                                      selected: selectedGoldColors.contains(
                                        color,
                                      ),
                                      showCheckmark: false,
                                      backgroundColor: categoryInactiveBgColor,
                                      selectedColor: categoryActiveBgColor,
                                      side: BorderSide(
                                        color:
                                            selectedGoldColors.contains(color)
                                                ? categoryActiveBgColor
                                                : categoryInactiveBgColor,
                                      ),
                                      labelStyle: TextStyle(
                                        color: categoryInactiveTextColor,
                                      ),
                                      onSelected: (selected) {
                                        setModalState(() {
                                          selected
                                              ? selectedGoldColors.add(color)
                                              : selectedGoldColors.remove(
                                                color,
                                              );
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 16),
                        // Harga Min - Max
                        Text(
                          "Harga Min - Max",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Min",
                                ),
                                onChanged: (v) {
                                  setModalState(() {
                                    priceMin = double.tryParse(v);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Max",
                                ),
                                onChanged: (v) {
                                  setModalState(() {
                                    priceMax = double.tryParse(v);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Jenis Emas
                        Text(
                          "Jenis Emas",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 8,
                          children:
                              goldTypes
                                  .map(
                                    (type) => FilterChip(
                                      label: Text(
                                        type,
                                        style: const TextStyle(
                                          color: categoryInactiveTextColor,
                                        ),
                                      ),
                                      selected: selectedGoldTypes.contains(
                                        type,
                                      ),
                                      showCheckmark: false,
                                      backgroundColor: categoryInactiveBgColor,
                                      selectedColor: categoryActiveBgColor,
                                      side: BorderSide(
                                        color:
                                            selectedGoldTypes.contains(type)
                                                ? categoryActiveBgColor
                                                : categoryInactiveBgColor,
                                      ),
                                      labelStyle: TextStyle(
                                        color: categoryInactiveTextColor,
                                      ),
                                      onSelected: (selected) {
                                        setModalState(() {
                                          selected
                                              ? selectedGoldTypes.add(type)
                                              : selectedGoldTypes.remove(type);
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 16),
                        // Jenis Batu
                        Text(
                          "Jenis Batu",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 8,
                          children:
                              stoneTypes
                                  .map(
                                    (type) => FilterChip(
                                      label: Text(
                                        type,
                                        style: const TextStyle(
                                          color: categoryInactiveTextColor,
                                        ),
                                      ),
                                      selected: selectedStoneTypes.contains(
                                        type,
                                      ),
                                      showCheckmark: false,
                                      backgroundColor: categoryInactiveBgColor,
                                      selectedColor: categoryActiveBgColor,
                                      side: BorderSide(
                                        color:
                                            selectedStoneTypes.contains(type)
                                                ? categoryActiveBgColor
                                                : categoryInactiveBgColor,
                                      ),
                                      labelStyle: TextStyle(
                                        color: categoryInactiveTextColor,
                                      ),
                                      onSelected: (selected) {
                                        setModalState(() {
                                          selected
                                              ? selectedStoneTypes.add(type)
                                              : selectedStoneTypes.remove(type);
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 16),
                        // Ring Size
                        Text(
                          "Ring Size",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            hintText: "Ring Size",
                          ),
                          onChanged: (v) {
                            setModalState(() {
                              ringSize = v;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _isRandomCategoryActive = false;
                                  });
                                },
                                child: const Text("Terapkan Filter"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.redAccent),
                    tooltip: "Reset Category",
                    onPressed: () {
                      Navigator.pop(context);
                      _resetCategoryFilter();
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userRole');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  double getOrderProgress(Order order) {
    final idx = fullWorkflowStatuses.indexOf(order.workflowStatus);
    final maxIdx = fullWorkflowStatuses.indexOf(OrderWorkflowStatus.done);
    if (idx < 0) return 0.0;
    return idx / maxIdx;
  }

  @override
  Widget build(BuildContext context) {
    List<String> categoryToShow;
    if (_isRandomCategoryActive) {
      categoryToShow = _randomCategoryFilters;
    } else {
      categoryToShow = [
        ...selectedJewelryTypes,
        ...selectedGoldColors,
        ...selectedGoldTypes,
        ...selectedStoneTypes,
        if (ringSize != null && ringSize!.isNotEmpty) 'Ring Size: $ringSize',
      ];
      if (categoryToShow.every((e) => e.isEmpty) || categoryToShow.isEmpty) {
        categoryToShow = _randomCategoryFilters;
        _isRandomCategoryActive = true;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/sales/create').then((value) {
            if (value == true) _fetchOrders();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pesanan'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/toko_sumatra.jpg',
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken,
              color: Colors.black.withAlpha((255 * 0.9).round()),
            ),
          ),
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : _errorMessage.isNotEmpty
              ? Center(
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchOrders,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(
                        height:
                            AppBar().preferredSize.height +
                            MediaQuery.of(context).padding.top +
                            20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Search',
                            hintText:
                                'Cari nama pelanggan atau jenis perhiasan...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white70,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withAlpha(
                              (255 * 0.9).round(),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintStyle: const TextStyle(color: Colors.white54),
                            floatingLabelStyle: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 100.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatusFilterButton(
                              'Semua',
                              null,
                              Colors.deepPurple,
                            ),
                            _buildStatusFilterButton(
                              'Waiting',
                              'waiting',
                              Colors.orange,
                            ),
                            _buildStatusFilterButton(
                              'On Progress',
                              'onProgress',
                              Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    categoryToShow.length,
                                    (index) {
                                      final cat = categoryToShow[index];
                                      final isSelected = false;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 4.0,
                                        ),
                                        child: ChoiceChip(
                                          label: Text(
                                            cat,
                                            style: TextStyle(
                                              color: categoryInactiveTextColor,
                                            ),
                                          ),
                                          selected: isSelected,
                                          onSelected: (_) {},
                                          backgroundColor:
                                              categoryInactiveBgColor,
                                          selectedColor: categoryActiveBgColor,
                                          labelStyle: TextStyle(
                                            color: categoryInactiveTextColor,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: categoryInactiveBgColor,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.filter_list,
                                color: Colors.white70,
                              ),
                              onPressed: _openFilterSheet,
                            ),
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              MediaQuery.of(context).size.height -
                              AppBar().preferredSize.height -
                              MediaQuery.of(context).padding.top -
                              (10.0 + 12.0 * 2 + 16.0 * 2) -
                              100.0 -
                              (8.0 * 2 + 20.0 + 16.0 * 2) -
                              (8.0 * 2 + 20.0 + 16.0 * 2) -
                              MediaQuery.of(context).viewInsets.bottom -
                              80,
                        ),
                        child:
                            _filteredOrders.isEmpty
                                ? Center(
                                  child: Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Tidak ada pesanan cocok dengan pencarian Anda.'
                                        : 'Tidak ada pesanan aktif.',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  itemCount: _filteredOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = _filteredOrders[index];

                                    Widget leadingWidget;
                                    if (order.imagePaths != null &&
                                        order.imagePaths!.isNotEmpty &&
                                        order.imagePaths!.first.isNotEmpty &&
                                        File(
                                          order.imagePaths!.first,
                                        ).existsSync()) {
                                      leadingWidget = ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(order.imagePaths!.first),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.image_not_supported,
                                                    size: 32,
                                                    color: Colors.grey,
                                                  ),
                                        ),
                                      );
                                    } else {
                                      leadingWidget = const CircleAvatar(
                                        backgroundColor: Colors.blueGrey,
                                        radius: 40,
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      );
                                    }

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      color: Colors.white.withAlpha(
                                        (255 * 0.9).round(),
                                      ),
                                      child: ListTile(
                                        leading: leadingWidget,
                                        minLeadingWidth: 90,
                                        contentPadding: const EdgeInsets.all(8),
                                        title: Text(
                                          order.customerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Jenis: ${order.jewelryType}'),
                                            Text(
                                              'Status: ${order.workflowStatus.label}',
                                              style: TextStyle(
                                                color:
                                                    order.workflowStatus ==
                                                            OrderWorkflowStatus
                                                                .waitingSalesCheck
                                                        ? Colors.orange
                                                        : order.workflowStatus ==
                                                            OrderWorkflowStatus
                                                                .done
                                                        ? Colors.green
                                                        : order.workflowStatus ==
                                                            OrderWorkflowStatus
                                                                .cancelled
                                                        ? Colors.red
                                                        : order.workflowStatus ==
                                                            OrderWorkflowStatus
                                                                .waitingSalesCompletion
                                                        ? Colors.orange
                                                        : Colors.blue,
                                              ),
                                            ),
                                            if (order.workflowStatus !=
                                                    OrderWorkflowStatus
                                                        .waitingSalesCheck &&
                                                order.workflowStatus !=
                                                    OrderWorkflowStatus.done &&
                                                order.workflowStatus !=
                                                    OrderWorkflowStatus
                                                        .cancelled)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 6.0,
                                                  bottom: 2.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${(getOrderProgress(order) * 100).toStringAsFixed(0)}%',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    LinearProgressIndicator(
                                                      value: getOrderProgress(
                                                        order,
                                                      ),
                                                      minHeight: 6,
                                                      backgroundColor:
                                                          Colors.grey[200],
                                                      color: Colors.amber[700],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (order.workflowStatus !=
                                                    OrderWorkflowStatus
                                                        .waitingSalesCheck &&
                                                order.workflowStatus !=
                                                    OrderWorkflowStatus.done &&
                                                order.workflowStatus !=
                                                    OrderWorkflowStatus
                                                        .cancelled)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 2.0,
                                                ),
                                                child: Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.visibility,
                                                      color: Colors.blue,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'On Monitoring',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey,
                                        ),
                                        onTap: () async {
                                          final result = await Navigator.of(
                                            context,
                                          ).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      SalesDetailScreen(
                                                        order: order,
                                                      ),
                                            ),
                                          );
                                          if (result == true) _fetchOrders();
                                        },
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
