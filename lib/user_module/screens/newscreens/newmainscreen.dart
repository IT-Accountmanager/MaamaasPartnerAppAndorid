import 'package:flutter/material.dart';
import 'package:maamaaspartner/user_module/screens/newscreens/videoscreennew.dart';
import '../../widgets/profiledrawer.dart';
import '../../widgets/utils.dart';
import '../home_page.dart';
import '../notifications.dart';
import '../profile_screen.dart';

class MainScreennew extends StatefulWidget {
  const MainScreennew({super.key});

  @override
  State<MainScreennew> createState() => _MainScreennewState();
}

class _MainScreennewState extends State<MainScreennew> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Utils.itemCount.addListener(_updateCount);
    // loadCartData();
    // _loadUserType();
  }

  void _updateCount() {
    if (mounted) setState(() {});
  }

  final _screens = [
    HomePage(),
    const ReelsScreennew(),
    // OrdersScreen(),
    NotificationScreen(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0; // 🔥 Back goes to Home tab
          });
        } else {
          Navigator.of(context).pop(); // Exit app
        }
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: IndexedStack(
            key: ValueKey<int>(_currentIndex),
            index: _currentIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFB15DC6),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 3) {
          openProfileDrawer(context);
          return;
        }
        setState(() => _currentIndex = index);
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_rounded),
          label: 'Deals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),

        // _cartNavItem(),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

}
