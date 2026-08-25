import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maamaaspartner/user_module/screens/newscreens/restaurentsnew.dart';
import 'package:maamaaspartner/user_module/screens/newscreens/videoscreennew.dart';
import '../../API/food_authservice.dart';
import '../../widgets/food/cartmode.dart';
import '../../widgets/food/currentcart_notifier.dart';
import '../../widgets/profiledrawer.dart';
import '../../widgets/utils.dart';
import '../Food&beverages/food_cartscreen.dart';
import '../Food&beverages/tablecart.dart';
import '../profile_screen.dart';
import '../videoscreen.dart';

class MainScreenfood extends StatefulWidget {
  const MainScreenfood({super.key});

  @override
  State<MainScreenfood> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenfood> {
  int _currentIndex = 0;
  int seatingId = 0;

  bool _showBottomBar = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Utils.itemCount.addListener(_updateCount);
    loadCartData();
    // _loadUserType();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // scrolling up → hide footer
      if (_showBottomBar) {
        setState(() => _showBottomBar = false);
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      // scrolling down → show footer
      if (!_showBottomBar) {
        setState(() => _showBottomBar = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    // Restaurents(),
    Restaurentsnew(scrollController: _scrollController),
    // const ReelsScreen(),
    const ReelsScreennew(),
    // const food_cartScreen(),
    Profile(),
  ];

  void _handleCartTap() {
    // if (CartNotifier.count.value == 0) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
    //   return;
    // }

    if (CartMode.type.value == CartType.normal) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const food_cartScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => tablecart(seatingId: seatingId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _showBottomBar ? kBottomNavigationBarHeight : 0,
        child: Wrap(children: [_buildBottomBar()]),
      ),
      // bottomNavigationBar: AnimatedSlide(
      //   duration: const Duration(milliseconds: 250),
      //   offset: _showBottomBar ? Offset.zero : const Offset(0, 1),
      //   child: _buildBottomBar(),
      // ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      // selectedItemColor: const Color(0xFFB15DC6),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 2) {
          _handleCartTap();
          return;
        }

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
                      count > 9 ? '9+' : count.toString(),
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
