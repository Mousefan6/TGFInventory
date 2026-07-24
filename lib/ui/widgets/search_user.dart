import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/inventory_service.dart';
import '../theme/colors.dart';

class SearchUser extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;

  const SearchUser({
    super.key,
    required this.controller,
    this.hintText = "Your name",
    this.validator,
  });

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  final InventoryService _apiService = InventoryService();
  final SearchController _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.controller.text;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (widget.controller.text != _searchController.text) {
      widget.controller.text = _searchController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: _searchController,
      viewBackgroundColor: AppColors.background,
      builder: (BuildContext context, SearchController controller) {
        return TextFormField(
          controller: widget.controller,
          readOnly: true,
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
              Icons.person_outline_rounded,
              color: Colors.grey.shade700,
              size: 26,
            ),
            suffixIcon: Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 28,
            ),
          ),
          onTap: () => controller.openView(),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) async {
        final String rawQuery = controller.text.trim();
        final List<String> userMatches = await _apiService.fetchUserNames(rawQuery);

        List<Widget> suggestions = [];

        // Show matching existing users
        for (String userName in userMatches) {
          suggestions.add(
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF0F172A)),
              title: Text(
                userName,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                controller.closeView(userName);
                widget.controller.text = userName;
              },
            ),
          );
        }

        // Register as new name
        if (rawQuery.isNotEmpty && !userMatches.contains(rawQuery)) {
          if (suggestions.isNotEmpty) {
            suggestions.add(const Divider());
          }

          suggestions.add(
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: AppColors.greenButton),
              title: Text(
                'Use "$rawQuery"',
                style: GoogleFonts.outfit(
                  color: AppColors.greenButton,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                controller.closeView(rawQuery);
                widget.controller.text = rawQuery;
              },
            ),
          );
        }
        return suggestions;
      },
    );
  }
}