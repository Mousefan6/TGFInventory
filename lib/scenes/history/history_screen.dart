import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
}

// TODO: Scrolling down stretches the cards vs when it tries to go up it just bounces back

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _showHistoryDetails(BuildContext context, History history) { // POPUP for long names
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(history.name,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          "${history.add ? 'Added' : 'Removed'} ${history.amount} Units\n"
              "User: ${history.name}\n"
              "Note: ${history.note}",
          style: GoogleFonts.outfit(),
        ),        actions: [
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
    final List<History> history = [
      const History(name: "Tissue Paper Roll", amount: 18, add: true, user: "Bob", note: ""),
      const History(name: "Hand Sanitizer", amount: 5, add: false, user:"John", note: "Used for x"),
      const History(name: "Coffee Mate Creamer whole plastic tin", amount: 100000, add: true, user:"Mary", note:"Really Long note so I can fix later because this will be too long"),
      const History(name: "Tissue Paper Roll", amount: 18, add: true, user: "Bob", note: ""),
      const History(name: "Hand Sanitizer", amount: 5, add: false, user:"John", note: "Used for x"),
      const History(name: "Coffee Mate Creamer whole plastic tin", amount: 100000, add: true, user:"Mary", note:"Really Long note so I can fix later because this will be too long"),
      const History(name: "Tissue Paper Roll", amount: 18, add: true, user: "Bob", note: ""),
      const History(name: "Hand Sanitizer", amount: 5, add: false, user:"John", note: "Used for x"),
      const History(name: "Coffee Mate Creamer whole plastic tin", amount: 100000, add: true, user:"Mary", note:"Really Long note so I can fix later because this will be too long"),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search history",
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
                child: ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final hist = history[index];
                    return _buildHistoryCard(context, hist);
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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