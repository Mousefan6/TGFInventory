import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.valueColor,
    this.width = double.infinity,
    this.height = 120,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}