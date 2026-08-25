import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/theme.dart';
import 'platform_tickets_screen.dart';
import 'faqs_screen.dart';
import 'internal_tickets_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with TickerProviderStateMixin {
  TabController? _tabCtrl;
  bool _isEmployee = false;
  List<String> _subModules = [];
  bool _loaded = false;

  // Tab definitions matching React Company component
  static const _tabs = [
    {'id': 'platform', 'label': 'Platform Tickets', 'subKey': 'RAISE_TICKET'},
    {'id': 'faqs', 'label': 'FAQs', 'subKey': 'FAQ'},
    {'id': 'internal', 'label': 'Internal Ticket', 'subKey': 'RAISE_TICKET'},
  ];

  List<Map<String, String>> get _visibleTabs {
    if (!_isEmployee) return _tabs;
    return _tabs.where((t) => _subModules.contains(t['subKey'])).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final p = await SharedPreferences.getInstance();
    final role = p.getString('role') ?? 'ROLE_VENDOR';
    List<String> mods = [];
    try {
      mods = p.getStringList('subModules') ?? [];
    } catch (_) {}

    if (!mounted) return;

    final isEmployee = role == 'ROLE_EMPLOYEE';
    final subModules = mods;

    // Compute visible tabs before setState so length is ready
    final visibleTabs = !isEmployee
        ? _tabs
        : _tabs.where((t) => subModules.contains(t['subKey'])).toList();

    // Dispose old controller BEFORE setState
    _tabCtrl?.dispose();
    final newCtrl = TabController(length: visibleTabs.length, vsync: this);

    setState(() {
      _isEmployee = isEmployee;
      _subModules = subModules;
      _loaded = true;
      _tabCtrl = newCtrl;
    });
  }

  @override
  void dispose() {
    _tabCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: spBg,
        body: Center(child: CircularProgressIndicator(color: spAccent)),
      );
    }

    final tabs = _visibleTabs;
    if (tabs.isEmpty) return _noModules();

    return Scaffold(
      backgroundColor: spBg,
      appBar: AppBar(
        backgroundColor: spCard,
        elevation: 0,
        titleSpacing: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
          padding: EdgeInsets.zero,
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: spBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: spBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 15,
                    color: spText1,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: SizedBox(
          height: 40,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(tabs.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _tabChip(
                    label: tabs[i]['label']!,
                    index: i,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: tabs.map((t) {
          switch (t['id']) {
            case 'faqs':
              return const FaqsScreen();
            case 'internal':
              return const InternalTicketsScreen();
            default:
              return const PlatformTicketsScreen();
          }
        }).toList(),
      ),
    );
  }
  Widget _tabChip({required String label, required int index}) {
    final isActive = _tabCtrl!.index == index;

    return GestureDetector(
      onTap: () {
        _tabCtrl!.animateTo(index);
        setState(() {}); // refresh UI
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green // 🟢 selected
              : const Color(0xFFE66D33), // 🟧 default
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  Widget _noModules() => Scaffold(
    backgroundColor: spBg,
    appBar: AppBar(
      backgroundColor: spCard,
      elevation: 0,
      title: const Text(
        'Help & Support',
        style: TextStyle(fontWeight: FontWeight.w800, color: spText1),
      ),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: spRedL,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.lock_rounded, color: spRed, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'No modules available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: spText1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'You don\'t have access to any modules.',
            style: TextStyle(color: spText2, fontSize: 13),
          ),
        ],
      ),
    ),
  );
}
