import 'package:flutter/material.dart';
import '../services/client_api_service.dart';
import '../services/cart_service.dart';
import '../models/catalog_item.dart';
import 'booking_screen.dart';
import 'cart_screen.dart';
import 'club_map_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ClientApiService _apiService = ClientApiService();
  final CartService _cartService = CartService();
  
  List<CatalogItem> _allItems = [];
  List<CatalogItem> _filteredItems = [];
  List<String> _categories = ['Все'];
  String _selectedCategory = 'Все';
  
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadCatalog() async {
    try {
      final items = await _apiService.getCatalogItems();
      setState(() {
        _allItems = items;
        _filteredItems = items;
        
        // Извлекаем уникальные категории
        final cats = items.map((e) => e.category).toSet().toList();
        _categories = ['Все', ...cats];
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = _allItems.where((item) {
        final matchesQuery = item.name.toLowerCase().contains(query.toLowerCase()) ||
                            item.category.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategory == 'Все' || item.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Поиск...',
                border: InputBorder.none,
              ),
              onChanged: _filterItems,
            )
          : const Text('Услуги и товары'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filterItems('');
                }
              });
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (_cartService.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${_cartService.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCatalog,
              child: CustomScrollView(
                slivers: [
                  // Секция с быстрыми действиями
                  if (!_isSearching) 
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildActionCard(
                              title: 'БРОНЬ ПК',
                              subtitle: 'Быстрый выбор',
                              icon: Icons.computer,
                              colors: [Colors.blue, Colors.indigo],
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingScreen())),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: _buildActionCard(
                              title: 'КАРТА',
                              subtitle: 'Выбор места',
                              icon: Icons.map_outlined,
                              colors: [Colors.purple, Colors.deepPurple],
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ClubMapScreen())),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Фильтры категорий
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = cat;
                                  _filterItems(_searchController.text);
                                });
                              },
                              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                              checkmarkColor: theme.colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text('Товары и аксессуары', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  // Сетка товаров
                  _filteredItems.isEmpty 
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('Ничего не найдено', style: TextStyle(color: Colors.grey))),
                      ),
                    )
                  : SliverPadding(
                    padding: const EdgeInsets.all(10),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _buildCatalogItemCard(_filteredItems[i]),
                        childCount: _filteredItems.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required List<Color> colors, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogItemCard(CatalogItem item) {
    String cat = item.category.toLowerCase();
    bool isService = cat.contains('computer') || cat.contains('комп') || cat.contains('pc') || cat.contains('пк') || cat.contains('аренда');

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                item.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported, color: Colors.grey)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(item.category, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 4),
                Text('${item.price.toStringAsFixed(0)} ₽${isService ? '/ч' : ''}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isService ? Colors.blue : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      if (isService) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BookingScreen(initialPcName: item.name)));
                      } else {
                        _cartService.addItem(item);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} в корзине')));
                      }
                    },
                    child: Text(isService ? 'Бронь' : 'В корзину', style: const TextStyle(fontSize: 12)),
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
