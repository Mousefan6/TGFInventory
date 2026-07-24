import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/inventory_service.dart';
import '../theme/colors.dart';

class SearchProduct extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool showRegisterOption;
  final bool hasBorder;
  final ValueChanged<String>? onItemSelected;
  final ValueChanged<String>? onRegisterNewItem;
  final FormFieldValidator<String>? validator;

  const SearchProduct({
    super.key,
    required this.controller,
    this.hintText = "Search product",
    this.showRegisterOption = false,
    this.hasBorder = true,
    this.onItemSelected,
    this.onRegisterNewItem,
    this.validator,
  });

  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  final InventoryService _apiService = InventoryService();
  final SearchController _searchController = SearchController();

  List<String>? _cachedItems;

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
    final text = _searchController.text;
    if (widget.controller.text != text) {
      widget.controller.text = text;
      if (widget.onItemSelected != null) {
        widget.onItemSelected!(text);
      }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.hasBorder
          ? BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border, width: 1.5),
      )
          : const BoxDecoration(color: Colors.transparent),
      child: SearchAnchor(
        searchController: _searchController,
        viewBackgroundColor: AppColors.background,
        builder: (BuildContext context, SearchController controller) {
          return TextFormField(
            controller: widget.controller,
            readOnly: true, // Necessary to prevent prevailing search
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
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    widget.controller.clear();
                    _searchController.clear();
                  });
                  if (widget.onItemSelected != null) {
                    widget.onItemSelected!('');
                  }
                },
              )
                  : null,
            ),
            onTap: () => controller.openView(),
          );
        },
        suggestionsBuilder: (BuildContext context, SearchController controller) async {
          final String rawQuery = controller.text.trim();
          final String lowerQuery = rawQuery.toLowerCase();
          final List<String> queryTokens =
          lowerQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

          final List<String> items = await _getItems(rawQuery);

          List<String> sortedMatches = List.from(items);
          if (queryTokens.isNotEmpty) {
            sortedMatches = sortedMatches.where((item) {
              final lowerItem = item.toLowerCase();
              return queryTokens.every((token) => lowerItem.contains(token));
            }).toList();

            sortedMatches.sort((a, b) {
              final scoreA = _calculateRelevanceScore(a, queryTokens, lowerQuery);
              final scoreB = _calculateRelevanceScore(b, queryTokens, lowerQuery);
              return scoreB.compareTo(scoreA);
            });
          }

          List<Widget> suggestions = [];

          for (String item in sortedMatches) {
            suggestions.add(
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined, color: Color(0xFF0F172A)),
                title: Text(
                  item,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  controller.closeView(item);
                  widget.controller.text = item;
                  if (widget.onItemSelected != null) {
                    widget.onItemSelected!(item);
                  }
                },
              ),
            );
          }

          // For adding new item into Database
          if (widget.showRegisterOption && rawQuery.isNotEmpty) {
            if (suggestions.isNotEmpty) {
              suggestions.add(const Divider());
            }

            suggestions.add(
              ListTile(
                leading: const Icon(Icons.add_outlined, color: AppColors.greenButton),
                title: Text(
                  'Register "$rawQuery" as new item',
                  style: GoogleFonts.outfit(
                    color: AppColors.greenButton,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  controller.closeView('');
                  if (widget.onRegisterNewItem != null) {
                    widget.onRegisterNewItem!(rawQuery);
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