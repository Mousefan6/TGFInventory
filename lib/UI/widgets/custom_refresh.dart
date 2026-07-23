import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CustomPullToRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const CustomPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  State<CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<CustomPullToRefresh> {
  double _dragOffset = 0.0;
  bool _isRefreshing = false;
  static const double _triggerThreshold = 70.0; // Execution drag boundary limit

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    if (notification is ScrollUpdateNotification || notification is OverscrollNotification) {
      if (notification.metrics.pixels < 0) {
        setState(() {
          _dragOffset = notification.metrics.pixels.abs();
        });
      }
      // else if (_dragOffset != 0) {
      //   setState(() {
      //     _dragOffset = 0.0;
      //   });
      // }
    } else if (notification is ScrollEndNotification) {
      if (_dragOffset >= _triggerThreshold) { // Triggers refresh if pulled too much
        _executeRefresh();
      } else {
        setState(() {
          _dragOffset = 0.0;
        });
      }
    }
    return false;
  }

  void _executeRefresh() async {
    setState(() {
      _isRefreshing = true;
      _dragOffset = 0.0;
    });

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_dragOffset / _triggerThreshold).clamp(0.0, 1.0);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          if (_dragOffset > 0 && !_isRefreshing)
            Positioned(
              top: _dragOffset * 0.3,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: progress,
                  child: Transform.scale(
                    scale: progress,
                    child: Icon(
                      Icons.refresh_rounded,
                      color: AppColors.greenButton,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),

          // Padding(
          //   padding: EdgeInsets.only(top: _isRefreshing ? 40.0 : 0.0),
          //   child: widget.child,
          // ),

          AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(top: _isRefreshing ? 50.0 : 0.0),
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
              ),
              child: widget.child,
            ),
          ),

          // Inline loading spinner overlay replacing the bubble popup completely
          if (_isRefreshing)
            const Positioned(
              top: 15,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenButton),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}