import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/inventory_service.dart';
import '../ui/theme/colors.dart';

class DatabaseItemSearchBar extends StatefulWidget {
  final ValueChanged<String>? onItemSelected;
  final ValueChanged<String>? onRegisterNewItem;

  const DatabaseItemSearchBar({
    super.key,
    this.onItemSelected,
    this.onRegisterNewItem,
  });

  @override
  State<DatabaseItemSearchBar> createState() => _DatabaseItemSearchBarState();
}

class _DatabaseItemSearchBarState extends State<DatabaseItemSearchBar> {
  final InventoryService _apiService = InventoryService();
  final SearchController _searchController = SearchController();

  List<String>? _cachedItems;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fast in-memory fetch with fallback to AppSheetService
  Future<List<String>> _getItems(String query) async {
    if (_cachedItems != null && _cachedItems!.isNotEmpty) {
      return _cachedItems!;
    }

    try {
      final fetched = await _apiService.fetchItemNames(query);
      _cachedItems = fetched;
      return fetched;
    } catch (_) {
      return [];
    }
  }

  void _onItemSelected(String item) {
    _searchController.text = item;
    _searchController.closeView(item);
    if (widget.onItemSelected != null) {
      widget.onItemSelected!(item);
    }
  }

  void _onRegisterNewItem(String newItemName) {
    _searchController.closeView('');
    if (widget.onRegisterNewItem != null) {
      widget.onRegisterNewItem!(newItemName);
    } else {
      _showRegisterItemDialog(newItemName);
    }
  }

  void _showRegisterItemDialog(String newItemQuery) {
    final TextEditingController nameController =
    TextEditingController(text: newItemQuery);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1.5),
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
                  style: GoogleFonts.outfit(
                      fontSize: 16, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: "Product Name",
                    hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                          _searchController.text = registeredName;
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenButton,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Create",
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
    return SearchAnchor(
      searchController: _searchController,
      viewBackgroundColor: AppColors.background,
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          hintText: 'Search or add item...',
          leading: const Icon(Icons.search),
          onTap: () => controller.openView(),
          onChanged: (_) => controller.openView(),
        );
      },
      suggestionsBuilder:
          (BuildContext context, SearchController controller) async {
        final String rawQuery = controller.text.trim();
        final List<String> allItems = await _getItems(rawQuery);

        final List<String> matches = rawQuery.isEmpty
            ? allItems
            : allItems
            .where((item) =>
            item.toLowerCase().contains(rawQuery.toLowerCase()))
            .toList();

        List<Widget> options = [];

        for (String match in matches) {
          options.add(
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined,
                  color: Color(0xFF0F172A)),
              title: Text(
                match,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => _onItemSelected(match),
            ),
          );
        }

        if (rawQuery.isNotEmpty) {
          if (options.isNotEmpty) {
            options.add(const Divider());
          }

          options.add(
            ListTile(
              leading: const Icon(Icons.add_circle_outline,
                  color: AppColors.greenButton),
              title: Text(
                'Register "$rawQuery" as new item',
                style: GoogleFonts.outfit(
                  color: AppColors.greenButton,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () => _onRegisterNewItem(rawQuery),
            ),
          );
        }
        return options;
      },
    );
  }
}