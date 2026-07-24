import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../UI/widgets/custom_refresh.dart';
import '../../services/inventory_service.dart';
import '../../ui/widgets/search_product.dart';
import '../../ui/theme/colors.dart';

// TODO: Update the UI for product details for product and history page

class Product {
  final String name;
  final int quantity;
  final bool isLowStock;

  const Product({
    required this.name,
    required this.quantity,
    required this.isLowStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawQty = json['Quantity'];
    final int parsedQty = rawQty is int ? rawQty : int.tryParse(rawQty.toString()) ?? 0;

    return Product(
      name: json['Item'] ?? json['name'] ?? 'Unknown Product',
      quantity: parsedQty,
      isLowStock: parsedQty <= 5, // Hardcoded might need to change
    );
  }
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AppSheetService _apiService = AppSheetService();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final rawData = await _apiService.getAggregatedInventory();
      final products = rawData.map((json) => Product.fromJson(json)).toList();
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });

      _filterProductList(_searchController.text);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading products: $e");
    }
  }

  int _calculateRelevanceScore(String item, List<String> queryTokens, String rawQuery) {
    final lowerItem = item.toLowerCase();
    int score = 0;

    if (lowerItem == rawQuery) score += 1000;
    if (lowerItem.startsWith(rawQuery)) score += 500;

    final itemWords = lowerItem.split(RegExp(r'\s+'));

    for (String token in queryTokens) {
      if (token.isEmpty) continue;
      for (String word in itemWords) {
        if (word == token) {
          score += 100;
        } else if (word.startsWith(token)) {
          score += 50;
        } else if (word.contains(token)) {
          score += 10;
        }
      }
    }
    return score;
  }

  void _filterProductList(String selectedProduct) {
    final rawQuery = selectedProduct.trim();
    final lowerQuery = rawQuery.toLowerCase();
    final queryTokens = lowerQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    setState(() {
      if (queryTokens.isEmpty) {
        setState(() {
          _filteredProducts = List.from(_allProducts);
        });
        return;
      } else {
        // Filter items containing all typed tokens
        var matches = _allProducts.where((product) {
          final lowerName = product.name.toLowerCase();
          return queryTokens.every((token) => lowerName.contains(token));
        }).toList();

        // Rank remaining items by tokenized score with most relevant first
        matches.sort((a, b) {
          final scoreA = _calculateRelevanceScore(a.name, queryTokens, lowerQuery);
          final scoreB = _calculateRelevanceScore(b.name, queryTokens, lowerQuery);
          return scoreB.compareTo(scoreA);
        });

        _filteredProducts = matches;
      }
    });
  }

  Future<void> _handleRefresh() async {
    await _loadProducts();
  }

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          product.name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text("Current Stock: ${product.quantity} Units", style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Center(
                child: Text(
                  "Products",
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              SearchProduct(
                controller: _searchController,
                hintText: "Search product",
                showRegisterOption: false,
                hasBorder: true,
                onItemSelected: (selectedProduct) {
                  _filterProductList(selectedProduct);
                },
              ),
              const SizedBox(height: 24),

              // List Headers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Product",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyText,
                      ),
                    ),
                    Text(
                      "QTY",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // List View
              Expanded(
                child: CustomPullToRefresh(
                  onRefresh: _handleRefresh,
                  child: _buildProductListView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductListView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredProducts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Text(
              _allProducts.isEmpty ? 'No products currently registered.' : 'No matching products found.',
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _filteredProducts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildProductCard(context, _filteredProducts[index]);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final Color qtyColor = product.isLowStock
        ? (product.quantity <= 1 ? AppColors.redButton : Colors.orange.shade700)
        : Colors.green.shade600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _showProductDetails(context, product),
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (product.isLowStock) ...[
                  const SizedBox(height: 4),
                  Text(
                    "LOW STOCK",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ]
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${product.quantity}",
                style: GoogleFonts.outfit(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: qtyColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Units",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}