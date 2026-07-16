import 'package:flutter/material.dart';
import '../../ui/theme/colors.dart';

import '../scenes/home/home_screen.dart';
import '../scenes/products/product_screen.dart';
// import '../scenes/manage/manage_screen.dart';
// import '../scenes/history/history_screen.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;

  const NavBar({
    super.key,
    required this.currentIndex,
  });

  void _onTabTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    // Switch pages based on index
    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeScreen();
        break;
      case 1:
        nextScreen = const ProductsScreen();
        break;
      case 2:
      // Replace with your real ManageScreen widget
        nextScreen = const Scaffold(body: Center(child: Text("Manage")));
        break;
      case 3:
      // Replace with your real HistoryScreen widget
        nextScreen = const Scaffold(body: Center(child: Text("History")));
        break;
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => nextScreen,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
  // TODO: Create slideshow swiping transition animation
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.black54,
      onTap: (index) => _onTabTapped(
          context,
          index
      ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: "Products",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: "Manage",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
        ],
    );
  }
}