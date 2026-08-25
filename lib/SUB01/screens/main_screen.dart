
import 'package:flutter/material.dart';
import '../widgets/theme.dart';
import 'subscription_screen.dart';
import 'active_modules_screen.dart';

class MainScreen1 extends StatefulWidget {
  const MainScreen1({super.key});

  @override
  State<MainScreen1> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen1>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  int _activeTab = 0;

  final List<String> _tabLabels = ["Subscription", "Summary"];

  @override
  void initState() {
    super.initState();

    _tabs = TabController(length: 2, vsync: this);

    _tabs.addListener(() {
      if (mounted) {
        setState(() => _activeTab = _tabs.index);
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _goToSummary() {
    _tabs.animateTo(1);
  }

  void _goToSubscription() {
    _tabs.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sdBg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Custom Top Bar ─────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              decoration: const BoxDecoration(
                color: sdCard,
                border: Border(bottom: BorderSide(color: sdBorder)),
              ),
              child: Row(
                children: [
                  // Back Button
                  if (Navigator.canPop(context))
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: sdGrayL,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: sdBorder),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: sdText1,
                          size: 16,
                        ),
                      ),
                    ),

                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(_tabLabels.length, (i) {
                          final isActive = _activeTab == i;

                          return GestureDetector(
                            onTap: () => _tabs.animateTo(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green : sdAccent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    i == 0
                                        ? Icons.layers_outlined
                                        : Icons.check_circle_outline_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _tabLabels[i],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isActive
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Page Content ───────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  SubscriptionScreen(onProceed: _goToSummary),
                  ActiveModulesScreen(onConfigureTap: _goToSubscription),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
