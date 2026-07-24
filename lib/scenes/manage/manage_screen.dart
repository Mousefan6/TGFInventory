import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/inventory_service.dart';
import '../../ui/widgets/search_product.dart';
import '../../ui/theme/colors.dart';
import '../../ui/widgets/search_user.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _apiService = AppSheetService();

  final _itemController = TextEditingController();
  final _qtyController = TextEditingController();
  final _userController = TextEditingController();
  final _commentController = TextEditingController();

  bool _isLoading = false;

  void _addStockLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _apiService.createStockLog(
        item: _itemController.text,
        quantity: int.parse(_qtyController.text),
        user: _userController.text,
        comment: _commentController.text.isEmpty ? "Stock Added" : _commentController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item(s) logged successfully!'),
            backgroundColor: AppColors.greenButton,
          ),
        );
        _clearForm();
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeStockLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      int enteredQty = int.parse(_qtyController.text);
      String targetItem = _itemController.text;

      int currentTotalStock = await _apiService.getItemStockCount(targetItem);

      if (enteredQty > currentTotalStock) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid Action: Only $currentTotalStock units available.'),
              backgroundColor: Colors.amber.shade900,
            ),
          );
        }
        return;
      }

      final success = await _apiService.createStockLog(
        item: _itemController.text,
        quantity: -enteredQty,
        user: _userController.text,
        comment: _commentController.text.isEmpty ? "Stock Removed" : _commentController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item(s) removed successfully!'),
            backgroundColor: AppColors.greenButton,
          ),
        );
        _clearForm();
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    _qtyController.dispose();
    _userController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _itemController.clear();
    _qtyController.clear();
    _userController.clear();
    _commentController.clear();
    _formKey.currentState?.reset();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $message'), backgroundColor: Colors.red),
      );
    }
  }

  void _showRegisterItemDialog(String newItemQuery) {
    final TextEditingController nameController = TextEditingController(text: newItemQuery);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border, width: 1.5),
          ),
          title: Text(
            "Register New Product",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter the name of the new product to register:",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: TextField(
                  controller: nameController,
                  style: GoogleFonts.outfit(fontSize: 16, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: "Product Name",
                    hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.outfit(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final registeredName = nameController.text.trim();
                      if (registeredName.isNotEmpty) {
                        setState(() {
                          _itemController.text = registeredName;
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenButton,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Less rounded like "Add to stock"
                      ),
                    ),
                    child: Text(
                      "Create", // Changed from "Register" / "Use Item" to "Create"
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: _isLoading ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            padding:const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key:_formKey,
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
                      child: SearchProduct(
                        controller: _itemController,
                        hasBorder: false,
                        showRegisterOption: true,
                        validator: (v) => _itemController.text.isEmpty ? 'Please select a product' : null,
                        onRegisterNewItem: (newItemQuery) {
                          _showRegisterItemDialog(newItemQuery);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quantity field
                    _FormInputWrapper(
                      label: "Quantity",
                      child: TextFormField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter a quantity';
                          if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Enter a valid amount';
                          return null;
                        },
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
                      child: SearchUser(
                        controller: _userController,
                        hintText: "Your name",
                        validator: (val) => _userController.text.trim().isEmpty ? 'Please enter your name' : null,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Comment field
                    _FormInputWrapper(
                      label: "Comment",
                      child: TextFormField(
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
                          _addStockLog();
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
                          _removeStockLog();
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
      )
    );
  }
}