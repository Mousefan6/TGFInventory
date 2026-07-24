import 'package:flutter/material.dart';

class DatabaseItemSearchBar extends StatefulWidget {
  const DatabaseItemSearchBar({super.key});

  @override
  State<DatabaseItemSearchBar> createState() => _DatabaseItemSearchBarState();
}

class _DatabaseItemSearchBarState extends State<DatabaseItemSearchBar> {
  final SearchController _searchController = SearchController();

  // Replace this function with your actual database query (e.g. SQLite / Supabase / Firestore)
  Future<List<String>> _fetchDatabaseMatches(String query) async {
    if (query.trim().isEmpty) return [];

    // --- EXAMPLE DATABASE QUERY PLACEHOLDER ---
    // final results = await myDatabase.rawQuery(
    //   'SELECT name FROM items WHERE name LIKE ? LIMIT 5',
    //   ['%${query.toLowerCase()}%'],
    // );
    // return results.map((e) => e['name'] as String).toList();

    // Mock response for testing:
    List<String> mockDbItems = [
      'tissue paper',
      'timothy',
      'titanium rod',
      'timer clock',
    ];

    return mockDbItems
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void _onItemSelected(String item) {
    _searchController.text = item;
    _searchController.closeView(item);
    // TODO: Handle item selection (e.g., view item details)
  }

  void _onRegisterNewItem(String newItemName) {
    _searchController.closeView('');
    // TODO: Trigger your registration flow (e.g., open modal bottom sheet or navigate to page)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register New Item'),
        content: Text('Do you want to register "$newItemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add to database logic here
              Navigator.pop(context);
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: _searchController,
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          hintText: 'Search or add item...',
          leading: const Icon(Icons.search),
          onTap: () => controller.openView(),
          onChanged: (_) => controller.openView(),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) async {
        final String query = controller.text.trim();

        // Query matching items from database
        final List<String> matches = await _fetchDatabaseMatches(query);

        List<Widget> options = [];

        // 1. Add matching items found in Database
        for (String match in matches) {
          options.add(
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(match),
              onTap: () => _onItemSelected(match),
            ),
          );
        }

        if (query.isNotEmpty) {
          if (options.isNotEmpty) {
            options.add(const Divider());
          }

          options.add(
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Colors.blue),
              title: Text(
                'Register "$query" as new item',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _onRegisterNewItem(query),
            ),
          );
        }

        return options;
      },
    );
  }
}