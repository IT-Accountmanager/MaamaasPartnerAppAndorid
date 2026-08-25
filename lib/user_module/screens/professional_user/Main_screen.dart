import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../API/food_authservice.dart';
import '../../widgets/food/currentcart_notifier.dart';
import '../../widgets/profiledrawer.dart';
import '../../widgets/utils.dart';
import '../Food&beverages/food_cartscreen.dart';
import '../newscreens/restaurentsnew.dart';
import '../profile_screen.dart';
import '../videoscreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Utils.itemCount.addListener(_updateCount);
    loadCartData();
    _loadUserType();
  }

  void _updateCount() {
    if (mounted) setState(() {});
  }

  Future<void> loadCartData() async {
    try {
      final count = await food_Authservice.fetchCartCount();
      CartNotifier.count.value = count;
    } catch (e) {
      // print("Error loading cart data: $e");
    }
  }

  void openReelsTab() {
    setState(() {
      _currentIndex = 1; // Ads / Reels tab
    });
  }

  late final _screens = [
    Restaurentsnew(scrollController: _scrollController),
    const ReelsScreen(),
    const food_cartScreen(),
    Profile(),
  ];

  Future<String> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType') ?? "PERSONAL";
  }

  Future<void> _loadUserType() async {
    final type = await getUserType();
    if (!mounted) return;

    setState(() {});
  }

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
          label: 'Ads',
        ),
        // BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        _cartNavItem(),

        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  BottomNavigationBarItem _cartNavItem() {
    return BottomNavigationBarItem(
      label: 'Cart',
      icon: ValueListenableBuilder<int>(
        valueListenable: CartNotifier.count,
        builder: (context, count, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart),

              if (count > 0)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
