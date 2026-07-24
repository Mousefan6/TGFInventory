import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../UI/widgets/custom_refresh.dart';
import '../../services/appsheet_service.dart';
import '../../ui/widgets/search_product.dart';
import '../../ui/theme/colors.dart';

// TODO: Implement Search Bar from Fast Search method, Connect the tags for the item
// name from each product so its linked to the list of available items in manage page
// make a "Register as new" button in the search bars once you press it for names
// bulletin for home page, make the announcements cards, create new + button,
// and link the low stock counter

// Product cards for each item
class Product {
  final String name;
  final int quantity;
  final bool isLowStock;

  const Product({
    required this.name,
    required this.quantity,
    required this.isLowStock,
  });

  // Build product card parsing JSON from AppSheet
  factory Product.fromJson(Map<String, dynamic> json) {
    final rawQty = json['Quantity'];
    final int parsedQty = rawQty is int ? rawQty : int.tryParse(rawQty.toString()) ?? 0;

    return Product(
      name: json['Item'] ?? json['name'] ?? 'Unknown Product',
      quantity: parsedQty,
      isLowStock: parsedQty <= 5, // Might need to change hard set parameter
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
  late Future<List<Product>> _productsFuture;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProductList(String selectedProduct) {
    setState(() {
      // TODO: Filter local list or re-fetch products matching `selectedProduct`
      debugPrint("Filtering products for: $selectedProduct");
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = _fetchProductsFromAppSheet();
    });
  }

  // Fetch data from appsheet
  Future<List<Product>> _fetchProductsFromAppSheet() async {
    final aggregatedData = await _apiService.getAggregatedInventory();
    return aggregatedData.map((jsonRow) => Product.fromJson(jsonRow)).toList();
  }

  // Refresh helper
  Future<void> _handleRefresh() async {
    _loadProducts();
    await _productsFuture;
  }

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            product.name,
            style: GoogleFonts.outfit(
                fontWeight:
                FontWeight.bold
            )
        ),
        content: Text("Current Stock: ${product.quantity} Units",
            style: GoogleFonts.outfit()
        ),
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
                        style: GoogleFonts.outfit(fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.greyText)
                    ),
                    Text(
                        "QTY",
                        style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.greyText
                        )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Refresh logic
              Expanded(
                child: CustomPullToRefresh(
                  onRefresh: _handleRefresh,
                  child: FutureBuilder<List<Product>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            Center(
                                child: Text('Error loading inventory data.\nSwipe down to retry.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(color: Colors.grey)
                                )
                            ),
                          ],
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            Center(
                                child: Text('No products currently registered.',
                                    style: GoogleFonts.outfit(color: Colors.grey)
                                )
                            ),
                          ],
                        );
                      }

                      final products = snapshot.data!;
                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: products.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildProductCard(context, products[index]);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final Color qtyColor;
    if (product.isLowStock) {
      qtyColor = product.quantity <= 1 ? AppColors.redButton : Colors.orange.shade700;
    } else {
      qtyColor = Colors.green.shade600;
    }

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
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                ),
                if (product.isLowStock) ...[
                  const SizedBox(height: 4),
                  Text(
                    "LOW STOCK",
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
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
                style: GoogleFonts.outfit(fontSize: 38, fontWeight: FontWeight.bold, color: qtyColor, height: 1.0),
              ),
              const SizedBox(height: 2),
              Text(
                "Units",
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}