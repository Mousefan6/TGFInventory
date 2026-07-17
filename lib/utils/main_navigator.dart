import 'package:flutter/material.dart';
import 'navigation_bar.dart';

import '../scenes/home/home_screen.dart';
import '../scenes/products/products_screen.dart';
import '../scenes/manage/manage_screen.dart';
import '../scenes/history/history_screen.dart';

class ScreenTransition extends StatefulWidget {
  const ScreenTransition({super.key});

  @override
  State<ScreenTransition> createState() => _ScreenTransitionState();
}

class _ScreenTransitionState extends State<ScreenTransition> {
  int _currentIndex = 0;

  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductsScreen(),
    const ManageStockScreen(),
    const Scaffold(body: Center(child: Text("History Screen"))), // Index 3
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300), // Speed of the slide
      curve: Curves.easeInOut,
    );

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),

      // Pass to navigation bar for handling index
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}