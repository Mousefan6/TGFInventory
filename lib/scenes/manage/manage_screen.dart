import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../ui/theme/colors.dart';

class ManageStockScreen extends StatefulWidget {
  const ManageStockScreen({super.key});

  @override
  State<ManageStockScreen> createState() => _ManageStockScreenState();
}

class _FormInputWrapper extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormInputWrapper({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.greyText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _ManageStockScreenState extends State<ManageStockScreen> {
  final _itemController = TextEditingController();
  final _qtyController = TextEditingController();
  final _userController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    _qtyController.dispose();
    _userController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child:SingleChildScrollView(
            padding:const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      "Manage Stock",
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),const SizedBox(height: 30),

                    // Item selection field
                    _FormInputWrapper(
                      label: "Item",
                      child: TextField(
                        controller: _itemController,
                        readOnly: true, // Need to be changed to search and have dropdown
                        onTap: () {
                          print("Select product tapped");
                        },
                        decoration: InputDecoration(
                          hintText: "Search product",
                          hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 18),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 28),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quantity field
                    _FormInputWrapper(
                      label: "Quantity",
                      child: TextField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: "0",
                          hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 18),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // User selection field
                    _FormInputWrapper(
                      label: "User",
                      child: TextField(
                        controller: _userController,
                        readOnly: true, // Need to be changed to search and have dropdown
                        onTap: () {
                          print("Select user tapped");
                        },
                        decoration: InputDecoration(
                          hintText: "Your name",
                          hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 18),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 28),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Comment field
                    _FormInputWrapper(
                      label: "Comment",
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: "Optional note",
                          hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 18),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // Add to stock button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          print("Add to stock pressed");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenButton,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Add to Stock",
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Remove from stock button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          print("Remove from stock pressed");
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFCE8EC),
                          side: const BorderSide(color: Color(0xFFF7C3CD), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Remove from Stock",
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.redButton,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
              ),
          ),
      ),
    );
  }
}