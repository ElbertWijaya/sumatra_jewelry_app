import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'cor_detail_screen.dart';

class CorDashboardScreen extends StatefulWidget {
  const CorDashboardScreen({super.key});

  @override
  State<CorDashboardScreen> createState() => _CorDashboardScreenState();
}

class _CorDashboardScreenState extends State<CorDashboardScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedTab = 'waiting'; // default tab designer

  // Filter state
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

  // Status yang relevan untuk caster
  final List<OrderWorkflowStatus> waitingStatuses = [
    OrderWorkflowStatus.waitingCasting,
  ];

  final List<OrderWorkflowStatus> workingStatuses = [
    OrderWorkflowStatus.casting,
  ];

  final List<OrderWorkflowStatus> onProgressStatuses = [
    OrderWorkflowStatus.waitingCarving,
    OrderWorkflowStatus.carving,
    OrderWorkflowStatus.waitingDiamondSetting,
    OrderWorkflowStatus.stoneSetting,
    OrderWorkflowStatus.waitingFinishing,
    OrderWorkflowStatus.finishing,
    OrderWorkflowStatus.waitingInventory,
    OrderWorkflowStatus.inventory,
  ];

  // Daftar pilihan filter
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

  static const Color categoryActiveBgColor = Color(0xFFEAE38C);
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
    // Gunakan inventoryStoneUsed jika ada, jika tidak fallback ke ordersStoneType
    String stoneType = '';
    String stoneSize = '';
    if (order.inventoryStoneUsed != null &&
        order.inventoryStoneUsed!.isNotEmpty) {
      stoneType = order.inventoryStoneUsed![0]['type']?.toString() ?? '';
      stoneSize = order.inventoryStoneUsed![0]['size']?.toString() ?? '';
    } else {
      stoneType = '';
      stoneSize = '';
    }
    return [
      order.ordersCustomerName,
      order.ordersCustomerContact,
      order.ordersAddress,
      order.ordersJewelryType,
      stoneType,
      stoneSize,
      order.ordersRingSize,
      order.ordersReadyDate?.toIso8601String() ?? '',
      order.ordersPickupDate?.toIso8601String() ?? '',
      order.ordersGoldPricePerGram.toString(),
      order.ordersFinalPrice.toString(),
      order.ordersNote,
      order.ordersWorkflowStatus.label,
    ].join(' ').toLowerCase();
  }

  List<Order> get _filteredOrders {
    List<Order> filtered =
        _orders
            .where(
              (order) =>
                  order.ordersWorkflowStatus != OrderWorkflowStatus.done &&
                  order.ordersWorkflowStatus != OrderWorkflowStatus.cancelled,
            )
            .toList();

    // Tab logic khusus caster
    if (_selectedTab == 'waiting') {
      filtered =
          filtered
              .where(
                (order) => waitingStatuses.contains(order.ordersWorkflowStatus),
              )
              .toList();
    } else if (_selectedTab == 'working') {
      filtered =
          filtered
              .where(
                (order) => workingStatuses.contains(order.ordersWorkflowStatus),
              )
              .toList();
    } else if (_selectedTab == 'onprogress') {
      filtered =
          filtered
              .where(
                (order) =>
                    onProgressStatuses.contains(order.ordersWorkflowStatus),
              )
              .toList();
    } else if (_selectedTab == 'all') {
      // tampilkan semua yang bukan done/cancelled (sudah di atas)
    }

    // Filter kategori dari filter bar/sheet
    if (selectedJewelryTypes.isNotEmpty) {
      filtered =
          filtered
              .where(
                (order) => selectedJewelryTypes.any(
                  (t) => order.ordersJewelryType.toLowerCase().contains(
                    t.toLowerCase(),
                  ),
                ),
              )
              .toList();
    }
    if (selectedGoldColors.isNotEmpty) {
      filtered =
          filtered
              .where(
                (order) => selectedGoldColors.any(
                  (gold) => orderFullText(order).contains(gold.toLowerCase()),
                ),
              )
              .toList();
    }
    if (selectedGoldTypes.isNotEmpty) {
      filtered =
          filtered
              .where(
                (order) => selectedGoldTypes.any(
                  (t) => orderFullText(order).contains(t.toLowerCase()),
                ),
              )
              .toList();
    }
    if (selectedStoneTypes.isNotEmpty) {
      filtered =
          filtered
              .where(
                (order) => selectedStoneTypes.any(
                  (stone) =>
                      ((order.inventoryStoneUsed != null &&
                              order.inventoryStoneUsed!.isNotEmpty)
                          ? (order.inventoryStoneUsed![0]['type']?.toString() ??
                                  '')
                              .toLowerCase()
                              .contains(stone.toLowerCase())
                          : ''.contains(stone.toLowerCase())),
                ),
              )
              .toList();
    }
    if (priceMin != null) {
      filtered =
          filtered
              .where((order) => (order.ordersFinalPrice) >= priceMin!)
              .toList();
    }
    if (priceMax != null) {
      filtered =
          filtered
              .where((order) => (order.ordersFinalPrice) <= priceMax!)
              .toList();
    }
    if (ringSize != null && ringSize!.isNotEmpty) {
      filtered =
          filtered
              .where(
                (order) => order.ordersRingSize.toLowerCase().contains(
                  ringSize!.toLowerCase(),
                ),
              )
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (order) =>
                    orderFullText(order).contains(_searchQuery.toLowerCase()),
              )
              .toList();
    }

    return filtered;
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
            return Padding(
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
                                  selected: selectedJewelryTypes.contains(type),
                                  showCheckmark: false,
                                  backgroundColor: categoryInactiveBgColor,
                                  selectedColor: categoryActiveBgColor,
                                  side: BorderSide(
                                    color:
                                        selectedJewelryTypes.contains(type)
                                            ? categoryActiveBgColor
                                            : categoryInactiveBgColor,
                                  ),
                                  onSelected: (selected) {
                                    setModalState(() {
                                      selected
                                          ? selectedJewelryTypes.add(type)
                                          : selectedJewelryTypes.remove(type);
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
                                  selected: selectedGoldColors.contains(color),
                                  showCheckmark: false,
                                  backgroundColor: categoryInactiveBgColor,
                                  selectedColor: categoryActiveBgColor,
                                  side: BorderSide(
                                    color:
                                        selectedGoldColors.contains(color)
                                            ? categoryActiveBgColor
                                            : categoryInactiveBgColor,
                                  ),
                                  onSelected: (selected) {
                                    setModalState(() {
                                      selected
                                          ? selectedGoldColors.add(color)
                                          : selectedGoldColors.remove(color);
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
                            decoration: const InputDecoration(hintText: "Min"),
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
                            decoration: const InputDecoration(hintText: "Max"),
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
                                  selected: selectedGoldTypes.contains(type),
                                  showCheckmark: false,
                                  backgroundColor: categoryInactiveBgColor,
                                  selectedColor: categoryActiveBgColor,
                                  side: BorderSide(
                                    color:
                                        selectedGoldTypes.contains(type)
                                            ? categoryActiveBgColor
                                            : categoryInactiveBgColor,
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
                                  selected: selectedStoneTypes.contains(type),
                                  showCheckmark: false,
                                  backgroundColor: categoryInactiveBgColor,
                                  selectedColor: categoryActiveBgColor,
                                  side: BorderSide(
                                    color:
                                        selectedStoneTypes.contains(type)
                                            ? categoryActiveBgColor
                                            : categoryInactiveBgColor,
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
                      decoration: const InputDecoration(hintText: "Ring Size"),
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
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.redAccent,
                          ),
                          tooltip: "Reset Filter",
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _generateRandomCategoryFilters();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

  Widget _buildTabButton(String label, String value, Color color) {
    final bool selected = _selectedTab == value;
    int count = 0;
    if (value == 'waiting') {
      count =
          _orders
              .where(
                (order) => waitingStatuses.contains(order.ordersWorkflowStatus),
              )
              .length;
    } else if (value == 'working') {
      count =
          _orders
              .where(
                (order) => workingStatuses.contains(order.ordersWorkflowStatus),
              )
              .length;
    } else if (value == 'onprogress') {
      count =
          _orders
              .where(
                (order) =>
                    onProgressStatuses.contains(order.ordersWorkflowStatus),
              )
              .length;
    } else if (value == 'all') {
      count =
          _orders
              .where(
                (order) =>
                    order.ordersWorkflowStatus != OrderWorkflowStatus.done &&
                    order.ordersWorkflowStatus != OrderWorkflowStatus.cancelled,
              )
              .length;
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTab = value;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? color.withOpacity(0.8) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? color : Colors.grey,
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
                    color: selected ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : color,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: selected ? color : Colors.white,
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

    final allFilters = _randomCategoryFilters;
    final selectedFilters =
        [
          ...selectedJewelryTypes,
          ...selectedGoldColors,
          ...selectedGoldTypes,
          ...selectedStoneTypes,
          if (ringSize != null && ringSize!.isNotEmpty) 'Ring Size: $ringSize',
        ].where((e) => e.isNotEmpty).toList();
    final unselectedFilters =
        allFilters.where((f) => !selectedFilters.contains(f)).toList();
    final filterBarList = [...selectedFilters, ...unselectedFilters];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caster Dashboard'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/caster/create');
          if (result == true) {
            await _fetchOrders();
          }
        },
        backgroundColor: Colors.amber[700],
        tooltip: 'Buat Pesanan Baru',
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/toko_sumatra.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
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
                      hintText: 'Cari nama pelanggan atau jenis perhiasan...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintStyle: const TextStyle(color: Colors.white54),
                      floatingLabelStyle: const TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 70.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(filterBarList.length, (
                              index,
                            ) {
                              final cat = filterBarList[index];
                              final isSelected = selectedFilters.contains(cat);
                              return Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: ChoiceChip(
                                  label: Text(
                                    cat,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.black
                                              : categoryInactiveTextColor,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _isRandomCategoryActive = false;
                                        if (jewelryTypes.contains(cat)) {
                                          if (!selectedJewelryTypes.contains(
                                            cat,
                                          )) {
                                            selectedJewelryTypes.add(cat);
                                          }
                                        } else if (goldColors.contains(cat)) {
                                          if (!selectedGoldColors.contains(
                                            cat,
                                          )) {
                                            selectedGoldColors.add(cat);
                                          }
                                        } else if (goldTypes.contains(cat)) {
                                          if (!selectedGoldTypes.contains(
                                            cat,
                                          )) {
                                            selectedGoldTypes.add(cat);
                                          }
                                        } else if (stoneTypes.contains(cat)) {
                                          if (!selectedStoneTypes.contains(
                                            cat,
                                          )) {
                                            selectedStoneTypes.add(cat);
                                          }
                                        } else if (cat.startsWith(
                                          'Ring Size:',
                                        )) {
                                          ringSize = cat.replaceFirst(
                                            'Ring Size: ',
                                            '',
                                          );
                                        }
                                      } else {
                                        selectedJewelryTypes.remove(cat);
                                        selectedGoldColors.remove(cat);
                                        selectedGoldTypes.remove(cat);
                                        selectedStoneTypes.remove(cat);
                                        if (ringSize != null &&
                                            'Ring Size: $ringSize' == cat) {
                                          ringSize = null;
                                        }
                                        if (selectedJewelryTypes.isEmpty &&
                                            selectedGoldColors.isEmpty &&
                                            selectedGoldTypes.isEmpty &&
                                            selectedStoneTypes.isEmpty &&
                                            (ringSize == null ||
                                                ringSize!.isEmpty)) {
                                          _isRandomCategoryActive = true;
                                        }
                                      }
                                    });
                                  },
                                  backgroundColor:
                                      isSelected
                                          ? const Color(0xFFEAE38C)
                                          : categoryInactiveBgColor,
                                  selectedColor: const Color(0xFFEAE38C),
                                  labelStyle: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.black
                                            : categoryInactiveTextColor,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  side: BorderSide(
                                    color:
                                        isSelected
                                            ? const Color(0xFFEAE38C)
                                            : categoryInactiveBgColor,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.filter_list,
                          color: Color(0xFF656359),
                        ),
                        tooltip: "Filter",
                        onPressed: _openFilterSheet,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTabButton('Waiting', 'waiting', Colors.orange),
                      _buildTabButton('Working', 'working', Colors.blue),
                      _buildTabButton(
                        'On Progress',
                        'onprogress',
                        Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchOrders,
                    child:
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : _errorMessage.isNotEmpty
                            ? Center(
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : _filteredOrders.isEmpty
                            ? Center(
                              child: Text(
                                _searchQuery.isNotEmpty
                                    ? 'Tidak ada pesanan cocok dengan pencarian Anda.'
                                    : 'Tidak ada pesanan aktif.',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              itemCount: _filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = _filteredOrders[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  color: const Color(
                                    0xFFFDF6E3,
                                  ), // luxurious light gold background
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        // Row pertama: gambar dan info utama
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Gambar 1:1
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child:
                                                  order
                                                              .ordersImagePaths
                                                              .isNotEmpty &&
                                                          order
                                                              .ordersImagePaths
                                                              .first
                                                              .isNotEmpty
                                                      ? Image.network(
                                                        order
                                                            .ordersImagePaths
                                                            .first,
                                                        width: 90,
                                                        height: 90,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) => Container(
                                                              width: 90,
                                                              height: 90,
                                                              color:
                                                                  Colors
                                                                      .brown[100],
                                                              child: const Icon(
                                                                Icons.image,
                                                                size: 40,
                                                                color:
                                                                    Colors
                                                                        .brown,
                                                              ),
                                                            ),
                                                      )
                                                      : Container(
                                                        width: 90,
                                                        height: 90,
                                                        color:
                                                            Colors.brown[100],
                                                        child: const Icon(
                                                          Icons.image,
                                                          size: 40,
                                                          color: Colors.brown,
                                                        ),
                                                      ),
                                            ),
                                            const SizedBox(width: 18),
                                            // Nama & jenis perhiasan
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    order.ordersCustomerName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Color(
                                                        0xFF7C5E2C,
                                                      ), // deep gold
                                                      letterSpacing: 0.5,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.category,
                                                        color: Color(
                                                          0xFFD4AF37,
                                                        ),
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        order
                                                                .ordersJewelryType
                                                                .isNotEmpty
                                                            ? order
                                                                .ordersJewelryType
                                                            : "-",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Color(
                                                            0xFF7C5E2C,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        // Row kedua: info tanggal, status, tombol
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              color: Color(0xFFBFA14A),
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Order: ${order.ordersCreatedAt.day}/${order.ordersCreatedAt.month}/${order.ordersCreatedAt.year}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF7C5E2C),
                                              ),
                                            ),
                                            const SizedBox(width: 18),
                                            if (order.ordersPickupDate != null)
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.assignment_turned_in,
                                                    color: Color(0xFFBFA14A),
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Ambil: ${order.ordersPickupDate!.day}/${order.ordersPickupDate!.month}/${order.ordersPickupDate!.year}',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF7C5E2C),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            // Chip for status (ordersWorkflowStatus only)
                                            Chip(
                                              label: Text(
                                                order
                                                    .ordersWorkflowStatus
                                                    .label,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              backgroundColor:
                                                  order.ordersWorkflowStatus ==
                                                          OrderWorkflowStatus
                                                              .done
                                                      ? Colors.green
                                                      : order.ordersWorkflowStatus ==
                                                          OrderWorkflowStatus
                                                              .cancelled
                                                      ? Colors.red
                                                      : const Color(0xFFD4AF37),
                                            ),
                                            const SizedBox(width: 12),
                                            ElevatedButton.icon(
                                              icon: const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                              ),
                                              label: const Text(
                                                'Detail',
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              onPressed: () async {
                                                final result =
                                                    await Navigator.of(
                                                      context,
                                                    ).push(
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                CorDetailScreen(
                                                                  order: order,
                                                                ),
                                                      ),
                                                    );
                                                if (result == true) {
                                                  _fetchOrders();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
