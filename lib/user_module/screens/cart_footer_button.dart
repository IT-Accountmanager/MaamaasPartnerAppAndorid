import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaaspartner/user_module/API/food_authservice.dart';
import 'package:maamaaspartner/user_module/widgets/food/currentcart_notifier.dart';
import '../../API/food_authservice.dart';
import 'Food&beverages/food_cartscreen.dart';

class food_Cart_count extends StatefulWidget {
  final double? savedAmount;

  const food_Cart_count({super.key, this.savedAmount});

  @override
  State<food_Cart_count> createState() => _OrderCartFooterState();
}

class _OrderCartFooterState extends State<food_Cart_count> {
  @override
  void initState() {
    super.initState();
    loadCartData();
  }

  Future<void> loadCartData() async {
    try {
      final count = await food_Authservice.fetchCartCount();
      CartNotifier.count.value = count;
    } catch (e) {
      // print("Error loading cart data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: isSmallScreen ? 2 : 1,
              child: ValueListenableBuilder<int>(
                valueListenable: CartNotifier.count,
                builder: (context, count, _) {
                  return _buildCartSummary(count, isSmallScreen: isSmallScreen);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(int count, {required bool isSmallScreen}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => food_cartScreen(
              savedAmount: widget.savedAmount ?? 0.0,
              showSavedPopup: true,
            ),
          ),
        );
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6D5BFF), Color(0xFF8C6BFF)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
              if (count > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minHeight: 18,
                      minWidth: 18,
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModernCartFAB extends StatefulWidget {
  const ModernCartFAB({super.key});

  @override
  State<ModernCartFAB> createState() => _ModernCartFABState();
}

class _ModernCartFABState extends State<ModernCartFAB> {
  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    try {
      final count = await food_Authservice.fetchCartCount();
      CartNotifier.count.value = count;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: CartNotifier.count,
      builder: (context, count, _) {
        if (count == 0) return const SizedBox.shrink(); // 👈 hide if empty

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const food_cartScreen(showSavedPopup: true),
              ),
            );
          },
          child: Container(
            height: 56.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              gradient: const LinearGradient(
                colors: [Color(0xFF6D5BFF), Color(0xFF8C6BFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            count > 9 ? '9+' : '$count',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                Text(
                  "View Cart",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DraggableCartFAB extends StatefulWidget {
  const DraggableCartFAB({super.key});

  @override
  State<DraggableCartFAB> createState() => _DraggableCartFABState();
}

class _DraggableCartFABState extends State<DraggableCartFAB> {
  double x = 20;
  double y = 500;

  final double fabWidth = 100;
  final double fabHeight = 56;

  @override
  void initState() {
    super.initState();
    _loadCartCount();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;

      setState(() {
        x = size.width - fabWidth - 12; // right edge
        y = size.height - fabHeight - 90; // bottom with safe margin
      });
    });
  }

  Future<void> _loadCartCount() async {
    final count = await food_Authservice.fetchCartCount();
    CartNotifier.count.value = count;
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;

    return ValueListenableBuilder<int>(
      valueListenable: CartNotifier.count,
      builder: (context, count, _) {
        if (count == 0) return const SizedBox.shrink();

        return Positioned(
          left: x.clamp(0, screen.width - fabWidth),
          top: y.clamp(
            MediaQuery.of(context).padding.top + 10,
            screen.height - fabHeight - 20,
          ),
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                x += details.delta.dx;
                y += details.delta.dy;
              });
            },
            onPanEnd: (_) => _snapToEdge(screen),
            child: _buildFab(count),
          ),
        );
      },
    );
  }

  void _snapToEdge(Size screen) {
    final double middle = screen.width / 2;
    final double targetX = x < middle ? 12 : screen.width - fabWidth - 12;

    setState(() => x = targetX);
  }

  Widget _buildFab(int count) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: fabHeight, // 👈 same width & height
        height: fabHeight,
        decoration: BoxDecoration(
          shape: BoxShape.circle, // 👈 circular
          gradient: const LinearGradient(
            colors: [Color(0xFF6D5BFF), Color(0xFF8C6BFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const food_cartScreen(showSavedPopup: true),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  Positioned(right: -8, top: -8, child: _badge(count)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(int count) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Center(
        child: Text(
          count > 9 ? '9+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
