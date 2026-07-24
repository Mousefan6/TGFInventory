import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tgfinventory/UI/widgets/custom_refresh.dart';
import 'package:tgfinventory/UI/widgets/search_product.dart';

import '../../services/appsheet_service.dart';
import '../../ui/theme/colors.dart';

class History { // History cards for each item
  final String name;
  final int amount;
  final bool add;
  final String user;
  final String note;

  const History({
    required this.name,
    required this.amount,
    required this.add,
    required this.user,
    required this.note,
  });

  // Builds log from parsing individual lines from AppSheet transaction logs
  factory History.fromJson(Map<String, dynamic> json) {
    final rawQty = json['Quantity'];
    final int parsedQty = rawQty is int ? rawQty : int.tryParse(rawQty.toString()) ?? 0;

    return History(
      name: json['Item'] ?? json['name'] ?? 'Unknown Product',
      amount: parsedQty.abs(),
      add: parsedQty >= 0,
      user: json['User'] ?? 'Unknown User',
      note: json['Comment'] ?? json['note'] ?? '',
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _historySearchController = TextEditingController();
  final AppSheetService _apiService = AppSheetService();
  late Future<List<History>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _historySearchController.dispose();
    super.dispose();
  }


  void _loadHistory() {
    setState(() {
      _historyFuture = _fetchHistoryFromAppSheet();
    });
  }

  void _filterHistoryLogs(String selectedProduct) {
    setState(() {
      // TODO: Filter history logs matching `selectedProduct`
      debugPrint("Filtering history for: $selectedProduct");
    });
  }

  // Newest to oldest order
  Future<List<History>> _fetchHistoryFromAppSheet() async {
    final rawLogs = await _apiService.readAllLogs();
    return rawLogs.map((jsonRow) => History.fromJson(jsonRow)).toList().reversed.toList();
  }

  Future<void> _handleHistoryRefresh() async {
    _loadHistory();
    await _historyFuture;
  }

  void _showHistoryDetails(BuildContext context, History history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(history.name,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          "${history.add ? 'Added' : 'Removed'} ${history.amount} Units\n\n"
              "Operator: ${history.name}\n\n"
              "Note: ${history.note.isEmpty ? 'No description' : history.note}",
          style: GoogleFonts.outfit(),
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

              // Title screen
              Center(
                child: Text(
                  "History",
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Search bar
              SearchProduct(
                controller: _historySearchController,
                hintText: "Filter logs by product...",
                showRegisterOption: false,
                onItemSelected: (selectedProduct) {
                  _filterHistoryLogs(selectedProduct);
                },
              ),
              const SizedBox(height: 24),

              // Table Headings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "History",
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

              // List of history
              Expanded(
                child: CustomPullToRefresh(
                  onRefresh: _handleHistoryRefresh,
                  child: FutureBuilder<List<History>>(
                    future: _historyFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                            Center(child: Text('Error loading history logs.\nSwipe down to retry.', textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.grey))),
                          ],
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                            Center(child: Text('No historical logs registered yet.', style: GoogleFonts.outfit(color: Colors.grey))),
                          ],
                        );
                      }

                      final logs = snapshot.data!;
                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: logs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(context, logs[index]);
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

  // Create log cards, Colors are static
  Widget _buildHistoryCard(BuildContext context, History history) {

    final Color addColor;
    if (history.add) {
      addColor = Colors.green.shade600;
    } else {
      addColor = Colors.red.shade600;
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
      padding: const EdgeInsets.only(left: 12, right: 16, top: 16, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                history.add
                    ? Icon(Icons.add_circle_outline_sharp, color: addColor, size: 40,)
                    : Icon(Icons.remove_circle_outline_sharp, color: addColor, size: 32,)
            ],
          ),

          // Left column, History name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    _showHistoryDetails(context, history);
                  },
                  child: Text(
                    history.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),

                  Text(
                    history.user,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  ),
                Text(
                  history.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // Right column, Quantity and units
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${history.amount}",
                style: GoogleFonts.outfit(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  color: addColor,

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