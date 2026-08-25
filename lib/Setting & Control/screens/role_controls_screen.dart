import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/modules_config.dart';
import '../services/api_service.dart';
import '../widgets/theme.dart';

class RoleControlsScreen extends StatefulWidget {
  const RoleControlsScreen({super.key});
  @override
  State<RoleControlsScreen> createState() => _RoleControlsScreenState();
}

class _RoleControlsScreenState extends State<RoleControlsScreen> {
  List<EmployeeModule> _all = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await EmployeeApi.fetchAll();
      if (mounted)
        setState(() {
          _all = list;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<EmployeeModule> get _assigned => _all
      .where((e) => e.businessModules.isNotEmpty || e.subModules.isNotEmpty)
      .toList();

  Future<void> _toggleStatus(EmployeeModule e) async {
    final next = !e.isActive;
    setState(() => e.isActive = next);
    try {
      await EmployeeApi.updateStatus(e.vendorId, next);
      if (mounted)
        showSuccess(
          context,
          '${e.name} is now ${next ? "Active" : "Inactive"}',
        );
    } catch (err) {
      setState(() => e.isActive = !next);
      if (mounted) showError(context, 'Failed: $err');
    }
  }

  void _openAssign({EmployeeModule? emp}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true, // ← home indicator safe
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AssignSheet(
        allEmployees: _all,
        employee: emp,
        onSaved: () {
          Navigator.pop(context);
          _load();
        },
      ),
    );
  }

  void _openView(EmployeeModule emp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ViewSheet(emp: emp),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        // Top action bar — sits right below the TabBar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role & Controls',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: kText1,
                      ),
                    ),
                    Text(
                      'Assign module access to employees',
                      style: TextStyle(fontSize: 12, color: kText2),
                    ),
                  ],
                ),
              ),
              KBtn(
                label: 'Assign',
                icon: Icons.person_add_outlined,
                onPressed: _loading ? null : () => _openAssign(),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: kBorder),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : RefreshIndicator(
                  color: kPrimary,
                  onRefresh: _load,
                  child: ListView(
                    // bottom padding = home indicator height so last card isn't hidden
                    padding: EdgeInsets.fromLTRB(16, 10, 16, bottomPad + 24),
                    children: [
                      // Module reference table
                      KCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                color: kPrimary,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Module',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      'Sub Modules',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...kVisibleModules.map((m) => _ModRow(mod: m)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Assigned Employees',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: kText1,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (_assigned.isEmpty)
                        KCard(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.people_outline,
                                    size: 48,
                                    color: kBorder,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'No employees assigned yet',
                                    style: TextStyle(color: kText2),
                                  ),
                                  const SizedBox(height: 12),
                                  KBtn(
                                    label: 'Assign First Employee',
                                    icon: Icons.add,
                                    onPressed: () => _openAssign(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ..._assigned.map(
                          (e) => _EmpCard(
                            emp: e,
                            onToggle: () => _toggleStatus(e),
                            onView: () => _openView(e),
                            onEdit: () => _openAssign(emp: e),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Module table row ───────────────────────────────────────────────────────────
class _ModRow extends StatelessWidget {
  final ModuleDef mod;
  const _ModRow({required this.mod});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: kBorder.withOpacity(0.5))),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              mod.displayName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: mod.subModules.isEmpty
              ? const Text('—', style: TextStyle(color: kText2, fontSize: 12))
              : Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: mod.subModules
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: kBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kBorder),
                          ),
                          child: Text(
                            s.displayName,
                            style: const TextStyle(fontSize: 11, color: kText1),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    ),
  );
}

// ── Employee Card ──────────────────────────────────────────────────────────────
class _EmpCard extends StatelessWidget {
  final EmployeeModule emp;
  final VoidCallback onToggle, onView, onEdit;
  const _EmpCard({
    required this.emp,
    required this.onToggle,
    required this.onView,
    required this.onEdit,
  });

  String _month(int m) => const [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m];

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.tryParse(emp.createdAt);
    final date = dt != null ? '${dt.day} ${_month(dt.month)} ${dt.year}' : '—';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name row
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: kPrimary,
                  child: Text(
                    emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emp.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kText1,
                        ),
                      ),
                      Text(
                        emp.role,
                        style: const TextStyle(fontSize: 12, color: kText2),
                      ),
                    ],
                  ),
                ),
                // _Badge(active: emp.isActive),
              ],
            ),
            const SizedBox(height: 10),

            // Date + module count
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 11,
                  color: kText2,
                ),
                const SizedBox(width: 4),
                Text(
                  'Joined $date',
                  style: const TextStyle(fontSize: 11, color: kText2),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: kInfo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${emp.businessModules.length} modules',
                    style: const TextStyle(
                      fontSize: 11,
                      color: kInfo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Actions row
            Row(
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: kText2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: emp.isActive,
                  onChanged: (_) => onToggle(),
                  activeColor: kSuccess,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Spacer(),
                _IBtn(
                  icon: Icons.visibility_outlined,
                  color: kInfo,
                  onTap: onView,
                ),
                const SizedBox(width: 8),
                _IBtn(
                  icon: Icons.edit_outlined,
                  color: kPrimary,
                  onTap: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final bool active;
  const _Badge({required this.active});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: active ? kSuccess.withOpacity(0.1) : kDanger.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: active ? kSuccess.withOpacity(0.3) : kDanger.withOpacity(0.3),
      ),
    ),
    child: Text(
      active ? 'Active' : 'Inactive',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: active ? kSuccess : kDanger,
      ),
    ),
  );
}

class _IBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color),
    ),
  );
}

// ── Assign Sheet ───────────────────────────────────────────────────────────────
class _AssignSheet extends StatefulWidget {
  final List<EmployeeModule> allEmployees;
  final EmployeeModule? employee;
  final VoidCallback onSaved;
  const _AssignSheet({
    required this.allEmployees,
    this.employee,
    required this.onSaved,
  });
  @override
  State<_AssignSheet> createState() => _AssignSheetState();
}

class _AssignSheetState extends State<_AssignSheet> {
  EmployeeModule? _emp;
  final _search = TextEditingController();
  String _q = '';
  Set<String> _mods = {};
  Set<String> _subs = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _emp = widget.employee;
      _mods = Set.from(_emp!.businessModules);
      _subs = Set.from(_emp!.subModules);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<EmployeeModule> get _filtered => _q.trim().isEmpty
      ? []
      : widget.allEmployees
            .where(
              (e) =>
                  e.name.toLowerCase().contains(_q.toLowerCase()) ||
                  e.role.toLowerCase().contains(_q.toLowerCase()),
            )
            .toList();

  void _toggleMod(String b) {
    final mod = kVisibleModules.firstWhere(
      (m) => m.backendName == b,
      orElse: () => const ModuleDef(backendName: '', displayName: '', order: 0),
    );
    setState(() {
      if (_mods.contains(b)) {
        _mods.remove(b);
        for (final s in mod.subModules) _subs.remove(s.backendName);
      } else {
        _mods.add(b);
        for (final s in mod.subModules) _subs.add(s.backendName);
      }
    });
  }

  void _toggleSub(String parent, String sub) {
    final mod = kVisibleModules.firstWhere(
      (m) => m.backendName == parent,
      orElse: () => const ModuleDef(backendName: '', displayName: '', order: 0),
    );
    setState(() {
      if (_subs.contains(sub)) {
        _subs.remove(sub);
        if (!mod.subModules.every((s) => _subs.contains(s.backendName))) {
          _mods.remove(parent);
        }
      } else {
        _subs.add(sub);
        if (mod.subModules.every((s) => _subs.contains(s.backendName))) {
          _mods.add(parent);
        }
      }
    });
  }

  void _selectAll() => setState(() {
    if (_mods.length == kVisibleModules.length) {
      _mods.clear();
      _subs.clear();
    } else {
      _mods = kVisibleModules.map((m) => m.backendName).toSet();
      _subs = kVisibleModules
          .expand((m) => m.subModules.map((s) => s.backendName))
          .toSet();
    }
  });

  Future<void> _save() async {
    if (_emp == null) {
      showWarning(context, 'Select an employee first');
      return;
    }
    if (_mods.isEmpty) {
      showWarning(context, 'Select at least one module');
      return;
    }
    setState(() => _saving = true);
    try {
      await EmployeeApi.updateModules(
        _emp!.vendorId,
        _mods.toList(),
        _subs.toList(),
      );
      widget.onSaved();
    } catch (e) {
      if (mounted) showError(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSel = _mods.length == kVisibleModules.length;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SheetHandle(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.employee == null
                              ? 'Assign Employee'
                              : 'Edit — ${widget.employee!.name}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (_emp != null)
                        GestureDetector(
                          onTap: _selectAll,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: allSel ? kPrimary : kBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: allSel ? kPrimary : kBorder,
                              ),
                            ),
                            child: Text(
                              allSel ? '✓ All' : '☐ All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: allSel ? Colors.white : kText2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Employee search (new assignment only)
                  if (widget.employee == null) ...[
                    TextField(
                      controller: _search,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: '🔍 Search by name or role...',
                        hintStyle: const TextStyle(fontSize: 13, color: kText2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        suffixIcon: _q.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  _search.clear();
                                  setState(() => _q = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (v) => setState(() => _q = v),
                    ),

                    if (_q.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 160),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: kBorder),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: _filtered.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No employees found',
                                  style: TextStyle(color: kText2),
                                ),
                              )
                            : ListView(
                                shrinkWrap: true,
                                children: _filtered.map((e) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: kPrimary,
                                      radius: 18,
                                      child: Text(
                                        e.name.isNotEmpty
                                            ? e.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      e.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    subtitle: Text(
                                      e.role,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: kText2,
                                      ),
                                    ),
                                    trailing: _emp?.vendorId == e.vendorId
                                        ? const Icon(
                                            Icons.check,
                                            color: kPrimary,
                                          )
                                        : null,
                                    onTap: () => setState(() {
                                      _emp = e;
                                      _mods = Set.from(e.businessModules);
                                      _subs = Set.from(e.subModules);
                                      _q = '';
                                      _search.clear();
                                    }),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],

                    if (_emp != null) ...[
                      const SizedBox(height: 8),
                      _EmpChip(
                        emp: _emp!,
                        onClear: () => setState(() {
                          _emp = null;
                          _mods.clear();
                          _subs.clear();
                        }),
                      ),
                    ],
                    const SizedBox(height: 6),
                  ],

                  // Edit mode
                  if (widget.employee != null) ...[
                    _EmpChip(emp: widget.employee!, onClear: null),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),

            // ── Module list ──────────────────────────────────────────────────
            if (_emp != null)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                  itemCount: kVisibleModules.length,
                  itemBuilder: (_, i) {
                    final m = kVisibleModules[i];
                    final sel = _mods.contains(m.backendName);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: sel ? kPrimaryLight : kBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? kPrimary.withOpacity(0.3) : kBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => _toggleMod(m.backendName),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  _Chk(checked: sel),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      m.displayName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: sel ? kPrimary : kText1,
                                      ),
                                    ),
                                  ),
                                  if (m.subModules.isNotEmpty)
                                    Text(
                                      '${m.subModules.length} sub',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: sel ? kPrimary : kText2,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          if (m.subModules.isNotEmpty) ...[
                            const Divider(height: 1, color: kBorder),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                              child: Wrap(
                                spacing: 7,
                                runSpacing: 6,
                                children: m.subModules.map((s) {
                                  final ss = _subs.contains(s.backendName);

                                  return GestureDetector(
                                    onTap: () => _toggleSub(
                                      m.backendName,
                                      s.backendName,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ss ? kPrimary : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: ss ? kPrimary : kBorder,
                                        ),
                                      ),
                                      child: Text(
                                        s.displayName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: ss ? Colors.white : kText2,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_search, size: 48, color: kBorder),
                      SizedBox(height: 8),
                      Text(
                        'Search and select an employee',
                        style: TextStyle(color: kText2, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Footer ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: kBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: KOutlineBtn(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KBtn(
                      label: widget.employee == null
                          ? 'Save & Assign'
                          : 'Update',
                      icon: Icons.save_outlined,
                      loading: _saving,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmpChip extends StatelessWidget {
  final EmployeeModule emp;
  final VoidCallback? onClear;
  const _EmpChip({required this.emp, this.onClear});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: kPrimaryLight,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kPrimary.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: kPrimary,
          child: Text(
            emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emp.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                emp.role,
                style: const TextStyle(fontSize: 11, color: kText2),
              ),
            ],
          ),
        ),
        if (onClear != null)
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 16, color: kText2),
          ),
      ],
    ),
  );
}

class _Chk extends StatelessWidget {
  final bool checked;
  const _Chk({required this.checked});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: checked ? kPrimary : Colors.white,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: checked ? kPrimary : kBorder, width: 1.5),
    ),
    child: checked
        ? const Icon(Icons.check, color: Colors.white, size: 13)
        : null,
  );
}

// ── View Sheet ─────────────────────────────────────────────────────────────────
class _ViewSheet extends StatelessWidget {
  final EmployeeModule emp;
  const _ViewSheet({required this.emp});

  @override
  Widget build(BuildContext context) {
    final assigned = kVisibleModules.where((m) {
      final hasMod = emp.businessModules.contains(m.backendName);
      final hasSub = m.subModules.any(
        (s) => emp.subModules.contains(s.backendName),
      );
      return hasMod || hasSub;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                const SheetHandle(),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: kPrimary,
                      child: Text(
                        emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${emp.name}'s Modules",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            emp.role,
                            style: const TextStyle(fontSize: 12, color: kText2),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: kText2),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${assigned.length} modules assigned',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: assigned.isEmpty
                ? const Center(
                    child: Text(
                      'No modules assigned',
                      style: TextStyle(color: kText2),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: assigned.length,
                    itemBuilder: (_, i) {
                      final m = assigned[i];
                      final hasMod = emp.businessModules.contains(
                        m.backendName,
                      );
                      final hasSubs = m.subModules
                          .where((s) => emp.subModules.contains(s.backendName))
                          .toList();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  hasMod
                                      ? Icons.check_circle
                                      : Icons.radio_button_checked,
                                  color: hasMod ? kSuccess : kWarning,
                                  size: 15,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  m.displayName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: kText1,
                                  ),
                                ),
                              ],
                            ),
                            if (hasSubs.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 5,
                                runSpacing: 4,
                                children: hasSubs
                                    .map(
                                      (s) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(color: kBorder),
                                        ),
                                        child: Text(
                                          s.displayName,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: kText1,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
