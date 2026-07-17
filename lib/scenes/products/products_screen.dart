import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../ui/theme/colors.dart';

class Product { // Product cards for each item
  final String name;
  final int quantity;
  final bool isLowStock;

  const Product({
    required this.name,
    required this.quantity,
    required this.isLowStock,
  });
}

// TODO: Scrolling down stretches the cards vs when it tries to go up it just bounces back

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  void _showProductDetails(BuildContext context, Product product) { // POPUP for long names
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
    // REPLACE ARRAY (MOCK DATABASE)
    final List<Product> products = [
      const Product(name: "Tissue Paper Roll", quantity: 18, isLowStock: false),
      const Product(name: "Hand Sanitizer", quantity: 5, isLowStock: true),
      const Product(name: "Coffee Mate Creamer whole plastic tin", quantity: 1, isLowStock: true),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title screen
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

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search product",
                    hintStyle: GoogleFonts.outfit(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                    icon: Icon(Icons.search_rounded, color: Colors.grey.shade700, size: 28),
                    suffixIcon: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Header
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

              // List of products
              Expanded(
                child: ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(context, product);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card factory, colors are static
  Widget _buildProductCard(BuildContext context, Product product) {
    final Color qtyColor;
    if (product.isLowStock) {
      qtyColor = product.quantity <= 1 ? AppColors.red : Colors.orange.shade700;
    } else {
      qtyColor = Colors.green.shade600;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left column, product name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    _showProductDetails(context, product);
                  },
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

          // Right column, Quantity and units
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