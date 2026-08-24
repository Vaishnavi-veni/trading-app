import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trading_app/features/holdings/screens/holdings_screen.dart';

import 'features/market/screens/market_screen.dart';
import 'features/watchlist/screens/watchlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MarketScreen(),
    WatchlistScreen(),
    HoldingsScreen(),
  ];

  static const backgroundColor = Color(0xFF0B0F14);
  static const navBarColor = Color(0xFF11171F);
  static const selectedColor = Color(0xFF4ADE80);
  static const unselectedColor = Color(0xFF7D8794);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBarColor,
          border: const Border(
            top: BorderSide(color: Color(0xFF202832), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          height: 68.h,
          backgroundColor: navBarColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,

          selectedIndex: _currentIndex,

          indicatorColor: selectedColor.withValues(alpha: 0.12),

          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: selectedColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              );
            }

            return TextStyle(
              color: unselectedColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            );
          }),

          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.show_chart_rounded,
                size: 22.sp,
                color: unselectedColor,
              ),
              selectedIcon: Icon(
                Icons.show_chart_rounded,
                size: 22.sp,
                color: selectedColor,
              ),
              label: 'Market',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.visibility_outlined,
                size: 22.sp,
                color: unselectedColor,
              ),
              selectedIcon: Icon(
                Icons.visibility_rounded,
                size: 22.sp,
                color: selectedColor,
              ),
              label: 'Watchlist',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.account_balance_wallet_outlined,
                size: 22.sp,
                color: unselectedColor,
              ),
              selectedIcon: Icon(
                Icons.account_balance_wallet_rounded,
                size: 22.sp,
                color: selectedColor,
              ),
              label: 'Holdings',
            ),
          ],
        ),
      ),
    );
  }
}
