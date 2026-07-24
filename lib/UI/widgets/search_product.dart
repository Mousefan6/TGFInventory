import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/appsheet_service.dart';
import '../theme/colors.dart';

class SearchProduct extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool showRegisterOption;
  final ValueChanged<String>? onItemSelected;
  final ValueChanged<String>? onRegisterNewItem;
  final FormFieldValidator<String>? validator;

  const SearchProduct({
    super.key,
    required this.controller,
    this.hintText = "Search product",
    this.showRegisterOption = false,
    this.onItemSelected,
    this.onRegisterNewItem,
    this.validator,
  });

  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  final AppSheetService _apiService = AppSheetService();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: SearchAnchor(
        builder: (BuildContext context, SearchController searchController) {
          if (searchController.text != widget.controller.text) {
            searchController.text = widget.controller.text;
          }

          return TextFormField(
            controller: searchController,
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.outfit(
                color: Colors.grey.shade400,
                fontSize: 18,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey.shade700,
                size: 28,
              ),
            ),
            onTap: () => searchController.openView(),
            onChanged: (val) {
              widget.controller.text = val;
              searchController.openView();
            },
          );
        },
        suggestionsBuilder: (BuildContext context, SearchController searchController) async {
          final String query = searchController.text.trim();

          // Fetch items from AppSheet database API
          final List<String> matches = await _apiService.fetchItemNames(query);

          List<Widget> suggestions = [];

          // Search database
          for (String item in matches) {
            suggestions.add(
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(item, style: GoogleFonts.outfit(fontSize: 16)),
                onTap: () {
                  widget.controller.text = item;
                  searchController.text = item;
                  searchController.closeView(item);
                  if (widget.onItemSelected != null) {
                    widget.onItemSelected!(item);
                  }
                },
              ),
            );
          }

          // Append "Register as new item" if enabled for this screen
          if (widget.showRegisterOption && query.isNotEmpty) {
            if (suggestions.isNotEmpty) {
              suggestions.add(const Divider());
            }

            suggestions.add(
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: AppColors.greenButton),
                title: Text(
                  'Register "$query" as new item',
                  style: GoogleFonts.outfit(
                    color: AppColors.greenButton,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  searchController.closeView('');
                  if (widget.onRegisterNewItem != null) {
                    widget.onRegisterNewItem!(query);
                  }
                },
              ),
            );
          }

          return suggestions;
        },
      ),
    );
  }
}