import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/appsheet_service.dart';
import '../../ui/theme/colors.dart';
import '../../ui/widgets/dashboard_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = AppSheetService();

  Future<void> _showBulletinDialog() async {
    final nameController = TextEditingController();
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "USER",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyText,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Your name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "NOTE",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyText,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Note",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Post",
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      final success =
                      await _apiService.createBulletinPost(
                        user: nameController.text.trim(),
                        comment: noteController.text.trim(),
                      );

                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? "Bulletin posted!"
                                : "Failed to post bulletin.",
                          ),
                        ),
                      );

                      setState(() {});
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
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
            children: [
              const SizedBox(height: 12),
              Image.asset(
                "assets/images/TGFLogo.png",
                height: 70,
              ),
              FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _showBulletinDialog,
                child: const Icon(Icons.add, color: Colors.black),
              ),

              const SizedBox(height: 10),

              Text(
                "Bulletin",
                style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Bulletin posts will appear here.",
                      style: GoogleFonts.outfit(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: DashboardCard(
                  width: 150,
                  height: 130,
                  title: "Low Stock!",
                  value: "4",
                  valueColor: AppColors.red,
                  onTap: () {
                  },
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}