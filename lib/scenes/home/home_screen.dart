import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../ui/theme/colors.dart';
import '../../ui/widgets/dashboard_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
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
                    print("Low Stock tapped");
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