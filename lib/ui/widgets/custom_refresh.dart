import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CustomPullToRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const CustomPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const double containerHeight = 70.0; // Gap between cards and icon

    return CustomRefreshIndicator(
      onRefresh: onRefresh,

      offsetToArmed: containerHeight,
      builder: ( // Pull down distance required to trigger the refresh
          BuildContext context,
          Widget child,
          IndicatorController controller,
          ) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            // controller.value goes from 0.0 -> 1.0 (can go above 1.0 if overpulled)
            final double pullValue = controller.value.clamp(0.0, 1.5);
            // Pixel displacement of the drag, reset to 0 if refreshing
            final double dy = controller.isLoading ? 0.0 : (pullValue * containerHeight);

            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: dy,
                  child: Center(
                    child: controller.isLoading
                        ? const SizedBox.shrink()
                        : Opacity(
                      opacity: pullValue.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: pullValue.clamp(0.2, 1.0),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.greenButton,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, dy),
                  child: child,
                ),
              ],
            );
          },
        );
      },
      child: child,
    );
  }
}