import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:maamaaspartner/user_module/API/Auth_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../Models/companyrestaurentledger.dart';
import '../widgets/string_extensions.dart';

class walletloading_screen extends StatefulWidget {
  const walletloading_screen({super.key});

  @override
  State<walletloading_screen> createState() => _walletloading_screenState();
}

class _walletloading_screenState extends State<walletloading_screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController searchController1 = TextEditingController();
  List<dynamic> employees = [];
  Set<int> selectedEmployees = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEmployees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => isLoading = true);

    try {
      final data = await AuthService.fetchEmployees();
      setState(() {
        employees = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching employees: $e")));
    }
  }

  Future<void> _addEmployee(Map<String, dynamic> emp) async {
    setState(() => isLoading = true);

    final success = await AuthService.addEmployee(emp);

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      await _loadEmployees(); // refresh list
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Employee added successfully")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to add employee")));
    }
  }

  Future<void> _updateEmployee(int id, Map<String, dynamic> emp) async {
    setState(() => isLoading = true);

    final success = await AuthService.updateEmployee(id, emp);

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      await _loadEmployees();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Employee updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to update employee")),
      );
    }
  }

  Future<void> _deleteEmployee(int userId) async {
    setState(() => isLoading = true);

    final success = await AuthService.deleteEmployee(userId);

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      await _loadEmployees(); // refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Employee deleted successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to delete employee")),
      );
    }
  }

  void _showAddEmployeeSheet({Map<String, dynamic>? emp}) {
    final idController = TextEditingController(text: emp?["empid"] ?? "");
    final nameController = TextEditingController(text: emp?["name"] ?? "");
    final phoneController = TextEditingController(
      text: emp?["phoneNumber"] ?? "",
    );
    final emailController = TextEditingController(text: emp?["email"] ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          top: false, // no extra gap at top
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emp == null ? "Add Employee" : "Edit Employee",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Registered Mobile Number",
                    ),
                  ),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),

                  TextField(
                    controller: idController,
                    decoration: const InputDecoration(labelText: "Employee ID"),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB15DC6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        final newEmp = {
                          "empid": idController.text,
                          "name": nameController.text,
                          "phoneNumber": phoneController.text,
                          "email": emailController.text,
                        };

                        if (emp == null) {
                          _addEmployee(newEmp); // POST
                        } else {
                          _updateEmployee(emp["id"], newEmp); // PUT
                        }
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddMoneyBottomSheet(BuildContext parentContext) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController limitController = TextEditingController();

    String? selectedType;
    String? selectedMonth;
    String? selectedYear;

    bool loadingRestaurants = false;
    List<String> restaurantNames = [];
    List<String> selectedRestaurants = [];

    Future<void> _fetchRestaurants(StateSetter setModalState) async {
      try {
        setModalState(() => loadingRestaurants = true);

        debugPrint("📡 Fetching restaurants...");
        final data = await AuthService.loadRestaurantNames();

        debugPrint("✅ Restaurants fetched: ${data.length}");
        debugPrint(data.toString());

        setModalState(() {
          restaurantNames = data;
          loadingRestaurants = false;
        });
      } catch (e) {
        debugPrint("❌ Restaurant fetch failed: $e");
        setModalState(() => loadingRestaurants = false);
      }
    }

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Add",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Dropdown to choose Prepaid / Postpaid
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: "Select Type",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "prepaid",
                            child: Text("Prepaid"),
                          ),
                          DropdownMenuItem(
                            value: "postpaid",
                            child: Text("Postpaid"),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            selectedType = value;
                          });

                          if (value == "postpaid" && restaurantNames.isEmpty) {
                            _fetchRestaurants(setModalState);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // 🔹 Prepaid UI
                      if (selectedType == "prepaid") ...[
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Enter Amount",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedMonth,
                          items:
                              [
                                "JANUARY",
                                "FEBRUARY",
                                "MARCH",
                                "APRIL",
                                "MAY",
                                "JUNE",
                                "JULY",
                                "AUGUST",
                                "SEPTEMBER",
                                "OCTOBER",
                                "NOVEMBER",
                                "DECEMBER ",
                              ].map((month) {
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(month),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setModalState(() => selectedMonth = value);
                          },
                          decoration: const InputDecoration(
                            labelText: "Select Month",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],

                      // 🔹 Postpaid UI
                      if (selectedType == "postpaid") ...[
                        DropdownButtonFormField<String>(
                          initialValue: selectedYear,
                          items: List.generate(5, (i) {
                            final year = DateTime.now().year - i;
                            return DropdownMenuItem(
                              value: year.toString(),
                              child: Text(year.toString()),
                            );
                          }),
                          onChanged: (value) {
                            setModalState(() => selectedYear = value);
                          },
                          decoration: const InputDecoration(
                            labelText: "Select Year",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: selectedMonth,
                          items:
                              [
                                "JANUARY",
                                "FEBRUARY",
                                "MARCH",
                                "APRIL",
                                "MAY",
                                "JUNE",
                                "JULY",
                                "AUGUST",
                                "SEPTEMBER",
                                "OCTOBER",
                                "NOVEMBER",
                                "DECEMBER",
                              ].map((month) {
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(month),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setModalState(() => selectedMonth = value);
                          },
                          decoration: const InputDecoration(
                            labelText: "Select Month",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: limitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Enter Limit",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ✅ Restaurant autocomplete
                        InkWell(
                          onTap: () async {
                            final result =
                                await showModalBottomSheet<List<String>>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) {
                                    return _RestaurantMultiSelectSheet(
                                      allRestaurants: restaurantNames,
                                      selected: selectedRestaurants,
                                    );
                                  },
                                );

                            if (result != null) {
                              setModalState(() {
                                selectedRestaurants = result;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Select Restaurants",
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              selectedRestaurants.isEmpty
                                  ? "Tap to select restaurants"
                                  : selectedRestaurants.join(", "),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          // Validate based on type
                          if (selectedType == null) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text("Please select type"),
                              ),
                            );
                            return;
                          }

                          if (selectedType == "prepaid") {
                            if (amountController.text.isEmpty ||
                                selectedMonth == null) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text("Enter amount & select month"),
                                ),
                              );
                              return;
                            }
                          } else if (selectedType == "postpaid") {
                            if (limitController.text.isEmpty ||
                                selectedMonth == null ||
                                selectedYear == null ||
                                selectedRestaurants.isEmpty) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text("Fill all postpaid details"),
                                ),
                              );
                              return;
                            }
                          }

                          Navigator.pop(sheetContext);

                          // Loading
                          showDialog(
                            context: parentContext,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          final selectedphoneNumber = employees
                              .where(
                                (emp) => selectedEmployees.contains(emp["id"]),
                              )
                              .map<String>(
                                (emp) => emp["phoneNumber"].toString(),
                              )
                              .toList();

                          bool success = false;
                          if (selectedType == "prepaid") {
                            success = await AuthService.addMoney(
                              phoneNumber: selectedphoneNumber,
                              amount: amountController.text,
                              month: selectedMonth!,
                            );
                          } else if (selectedType == "postpaid") {
                            success = await AuthService.addApproval(
                              phoneNumber: selectedphoneNumber,
                              amount: limitController
                                  .text, // use limit for postpaid
                              month:
                                  selectedMonth!, // or pass dummy month if API requires it
                              year: selectedYear,
                              limit: limitController.text,
                              restaurantName: selectedRestaurants.join(","),
                              isPostpaid: true, // ✅ must be true
                            );
                          }

                          Navigator.pop(parentContext);

                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? "✅ ${selectedType!.capitalize()} added successfully"
                                    : "❌ Failed to add ${selectedType!}",
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Submit"),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50), // or your needed height
        child: AppBar(
          title: Text("Wallet"),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Add Employee"),
                Tab(text: "Add Money"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildAddEmployeeList(), _buildMoneyList()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEmployeeList() {
    final displayList = searchController.text.isEmpty
        ? employees
        : employees.where((emp) {
            final query = searchController.text.toLowerCase();
            bool matches(String? value) =>
                value?.toLowerCase().contains(query) ?? false;
            return matches(emp["empid"]?.toString()) ||
                matches(emp["name"]?.toString()) ||
                matches(emp["phoneNumber"]?.toString()) ||
                matches(emp["email"]?.toString());
          }).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Search employees...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: displayList.isEmpty
              ? Center(
                  child: Text(
                    searchController.text.isEmpty
                        ? "No Employees added yet"
                        : "No Employees found",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final emp = displayList[index];
                    return Card(
                      color: Colors.grey.shade200,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(
                          emp["name"]?.toString() ?? "",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Phone: ${emp["phoneNumber"] ?? ""}"),
                            Text("Emp id: ${emp["empid"] ?? ""}"),
                            Text("Email: ${emp["email"] ?? ""}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showAddEmployeeSheet(emp: emp);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Confirm Delete"),
                                    content: const Text(
                                      "Are you sure you want to delete this employee?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(
                                          context,
                                        ).pop(), // ❌ cancel
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).pop(); // close dialog
                                          _deleteEmployee(
                                            emp["userId"],
                                          ); // ✅ call delete after confirm
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddEmployeeSheet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB15DC6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                elevation: 2,
                // ignore: deprecated_member_use
                shadowColor: Colors.black.withOpacity(0.2),
              ),
              icon: Icon(Icons.add, size: 20.sp, color: Colors.white),
              label: Text(
                "Add Employees",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoneyList() {
    final displayList = searchController1.text.isEmpty
        ? employees
        : employees.where((emp) {
            final query = searchController1.text.toLowerCase();
            bool matches(String? value) =>
                value?.toLowerCase().contains(query) ?? false;
            return matches(emp["empid"]?.toString()) ||
                matches(emp["name"]?.toString()) ||
                matches(emp["phoneNumber"]?.toString()) ||
                matches(emp["email"]?.toString());
          }).toList();

    // 🟣 Sort so inactive (false) employees appear first
    displayList.sort((a, b) {
      final aActive = a["active"] == true;
      final bActive = b["active"] == true;
      if (!aActive && bActive) return -1; // inactive first
      if (aActive && !bActive) return 1;
      return 0;
    });

    bool allSelected = selectedEmployees.length == displayList.length;

    return Column(
      children: [
        // 🔍 Search box
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: TextField(
            controller: searchController1,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Search employees...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),

        // 🟩 Buttons Row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // 🟢 If all selected → unselect all
                      if (allSelected) {
                        for (var emp in employees) {
                          emp["active"] = false;
                        }
                        selectedEmployees.clear();
                      } else {
                        // 🟢 Select up to 20 inactive employees each time
                        final inactiveEmployees = displayList
                            .where((emp) => emp["active"] == false)
                            .take(20)
                            .toList();

                        for (var emp in inactiveEmployees) {
                          emp["active"] = true;
                          selectedEmployees.add(emp["id"] as int);
                        }
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(allSelected ? "Unselect All" : "Select 20"),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedEmployees.isNotEmpty) {
                      _showAddMoneyBottomSheet(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "⚠️ Please select at least one employee",
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text("Add"),
                ),
              ),
            ],
          ),
        ),

        // 🧾 Employee List
        Expanded(
          child: displayList.isEmpty
              ? Center(
                  child: Text(
                    searchController1.text.isEmpty
                        ? "No Employees added yet"
                        : "No Employees found",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final emp = displayList[index];
                    final empId = emp["id"] as int;
                    final isSelected = selectedEmployees.contains(empId);

                    return Card(
                      color: emp["active"] == true
                          ? Colors.green.shade50
                          : Colors.grey.shade200,
                      margin: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedEmployees.add(empId);
                                emp["active"] = true;
                              } else {
                                selectedEmployees.remove(empId);
                                emp["active"] = false;
                              }
                            });
                          },
                        ),
                        title: Text(emp["name"] ?? ""),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("EmpID: ${emp["empid"] ?? ""}"),
                            Text("Phone: ${emp["phoneNumber"] ?? ""}"),
                            Text("Email: ${emp["email"] ?? ""}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // 🕓 History Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompanyRestaurantLedgerScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB15DC6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                elevation: 2,
                // ignore: deprecated_member_use
                shadowColor: Colors.black.withOpacity(0.2),
              ),
              icon: Icon(Icons.history, size: 20.sp, color: Colors.white),
              label: Text(
                "History",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({Key? key}) : super(key: key);
//
//   @override
//   _HistoryScreenState createState() => _HistoryScreenState();
// }
//
// class _HistoryScreenState extends State<HistoryScreen> {
//   late Future<List<ProfessionalTransaction>> futureTransactions;
//
//   List<ProfessionalTransaction> allTransactions = [];
//   List<ProfessionalTransaction> filteredTransactions = [];
//
//   String? selectedMonth;
//   String? selectedYear;
//
//   List<String> availableMonths = [];
//   List<String> availableYears = [];
//   String selectedPaymentType = "All"; // All / Prepaid / Postpaid
//
//   @override
//   void initState() {
//     super.initState();
//     futureTransactions = fetchTransactions();
//     futureTransactions.then((transactions) {
//       setState(() {
//         allTransactions = transactions;
//         filteredTransactions = List.from(allTransactions);
//
//         // Extract unique months and years dynamically from API data
//         availableMonths = transactions.map((e) => e.month).toSet().toList()
//           ..sort();
//         availableYears =
//             transactions.map((e) => e.year.toString()).toSet().toList()..sort();
//       });
//     });
//   }
//
//   Future<List<ProfessionalTransaction>> fetchTransactions() async {
//     return AuthService().fetchTransaction();
//   }
//
//   Future<void> generateAllPDF() async {
//     final pdf = pw.Document();
//
//     final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
//     final ttf = pw.Font.ttf(fontData);
//
//     // Table headers
//     final tableHeaders = [
//       "Txn ID",
//       "Name",
//       "phone Number",
//       "Emp ID",
//       "Month/Year",
//       "Status",
//       "Time",
//       "Used Amt",
//       "Credit Limit",
//       "Restaurant",
//     ];
//
//     // Table row data
//     final tableData = filteredTransactions.map((txn) {
//       return [
//         txn.id,
//         txn.name,
//         txn.phoneNumber,
//         txn.empid,
//         "${txn.month} ${txn.year}",
//         txn.status,
//         txn.time,
//         txn.postPaid ? "₹${txn.usedAmount?.toStringAsFixed(2) ?? "-"}" : "-",
//         txn.postPaid ? "₹${txn.creditLimit?.toStringAsFixed(2) ?? "-"}" : "-",
//         txn.postPaid ? txn.restaurentName ?? "-" : "-",
//       ];
//     }).toList();
//
//     pdf.addPage(
//       pw.MultiPage(
//         theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(20),
//         build: (context) => [
//           pw.Text(
//             "Transactions Report",
//             style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
//           ),
//           pw.SizedBox(height: 15),
//
//           // Table
//           // ignore: deprecated_member_use
//           pw.Table.fromTextArray(
//             headers: tableHeaders,
//             data: tableData,
//             border: pw.TableBorder.all(),
//             headerStyle: pw.TextStyle(
//               fontWeight: pw.FontWeight.bold,
//               fontSize: 10,
//             ),
//             cellStyle: const pw.TextStyle(fontSize: 7),
//             headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
//             cellAlignment: pw.Alignment.centerLeft,
//             columnWidths: {
//               0: const pw.FlexColumnWidth(2), // Txn ID
//               1: const pw.FlexColumnWidth(3), // Name
//               2: const pw.FlexColumnWidth(2), // Emp ID
//               3: const pw.FlexColumnWidth(2), // Month/Year
//               4: const pw.FlexColumnWidth(2), // Status
//               5: const pw.FlexColumnWidth(3), // Time
//               6: const pw.FlexColumnWidth(2), // Used Amt
//               7: const pw.FlexColumnWidth(2), // Credit Limit
//               8: const pw.FlexColumnWidth(3), // Restaurant
//             },
//           ),
//         ],
//       ),
//     );
//
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   }
//
//   void openFilterBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min, // Fit content
//                 children: [
//                   // Month Dropdown
//                   DropdownButton<String>(
//                     hint: const Text('Select Month'),
//                     value: selectedMonth,
//                     isExpanded: true,
//                     items: availableMonths.map((month) {
//                       return DropdownMenuItem(value: month, child: Text(month));
//                     }).toList(),
//                     onChanged: (value) {
//                       setModalState(() {
//                         selectedMonth = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   // Year Dropdown
//                   DropdownButton<String>(
//                     hint: const Text('Select Year'),
//                     value: selectedYear,
//                     isExpanded: true,
//                     items: availableYears.map((year) {
//                       return DropdownMenuItem(value: year, child: Text(year));
//                     }).toList(),
//                     onChanged: (value) {
//                       setModalState(() {
//                         selectedYear = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   // Buttons Row
//                   Row(
//                     children: [
//                       // Reset Button
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () {
//                             setModalState(() {
//                               selectedMonth = null;
//                               selectedYear = null;
//                             });
//                             setState(() {
//                               // Reset the main transactions list to show all
//                               filteredTransactions = List.from(allTransactions);
//                             });
//                             Navigator.pop(context);
//                           },
//                           style: OutlinedButton.styleFrom(
//                             side: const BorderSide(color: Color(0xFFB15DC6)),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: const Text(
//                             "Reset",
//                             style: TextStyle(
//                               color: Color(0xFFB15DC6),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       // Apply Button
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             applyFilter(closeSheet: true);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFB15DC6),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: const Text(
//                             "Apply",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void applyFilter({bool closeSheet = false}) {
//     setState(() {
//       filteredTransactions = allTransactions.where((txn) {
//         // month
//         final monthMatch = selectedMonth == null || txn.month == selectedMonth;
//
//         // year
//         final yearMatch =
//             selectedYear == null || txn.year.toString() == selectedYear;
//
//         // prepaid / postpaid
//         bool paymentMatch = true;
//         if (selectedPaymentType == "Prepaid") {
//           paymentMatch = txn.postPaid == false;
//         } else if (selectedPaymentType == "Postpaid") {
//           paymentMatch = txn.postPaid == true;
//         }
//
//         return monthMatch && yearMatch && paymentMatch;
//       }).toList();
//     });
//
//     if (closeSheet && Navigator.canPop(context)) {
//       Navigator.pop(context);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Transaction History'),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(70),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 // Payment Type Dropdown
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     initialValue: selectedPaymentType,
//                     decoration: const InputDecoration(
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(),
//                       labelText: "Payment Type",
//                     ),
//                     items: ["All", "Prepaid", "Postpaid"]
//                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                         .toList(),
//                     onChanged: (value) {
//                       selectedPaymentType = value!;
//                       applyFilter();
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(width: 10),
//
//                 // Download All Button
//                 ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFB15DC6),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 14,
//                     ),
//                   ),
//                   icon: const Icon(Icons.download),
//                   label: const Text("Download"),
//                   onPressed: () async {
//                     await generateAllPDF();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             onPressed: openFilterBottomSheet,
//             tooltip: 'Filter',
//           ),
//         ],
//       ),
//
//       body: filteredTransactions.isEmpty
//           ? const Center(child: Text('No transaction data found'))
//           : ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: filteredTransactions.length,
//               itemBuilder: (context, index) {
//                 final txn = filteredTransactions[index];
//                 return Card(
//                   color: Colors.grey.shade200,
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '${txn.name} (${txn.empid})',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text('${txn.month} ${txn.year}'),
//                               Text('${txn.status}'),
//                               Text(txn.phoneNumber),
//                               Text(txn.email),
//                               if (txn.postPaid) ...[
//                                 Text(
//                                   'Used Amount: ₹${txn.usedAmount?.toStringAsFixed(2)}',
//                                 ),
//                                 Text(
//                                   'Credit Limit: ₹${txn.creditLimit?.toStringAsFixed(2)}',
//                                 ),
//                                 Text(
//                                   'Restaurant: ${txn.restaurentName ?? "-"}',
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

class CompanyRestaurantLedgerScreen extends StatefulWidget {
  const CompanyRestaurantLedgerScreen({super.key});

  @override
  State<CompanyRestaurantLedgerScreen> createState() =>
      _CompanyRestaurantLedgerScreenState();
}

class _CompanyRestaurantLedgerScreenState
    extends State<CompanyRestaurantLedgerScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  bool loading = false;

  String? companyName;
  bool profileLoading = true;

  List<CompanyRestaurantLedger> ledger = [];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final profile =
        await AuthService.fetchUserProfileData(); // 🔑 logged-in userId

    setState(() {
      companyName = profile?.companyName;
      profileLoading = false;
    });
  }

  Future<void> loadData() async {
    if (fromDate == null || toDate == null) return;

    setState(() => loading = true);

    ledger = await AuthService.fetchCompanyRestaurantLedger(
      companyName: companyName!,
      fromDate: fromDate!.toIso8601String().substring(0, 10),
      toDate: toDate!.toIso8601String().substring(0, 10),
    );

    setState(() => loading = false);
  }

  Future<void> pickDate(bool isFrom) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        if (isFrom) {
          fromDate = date;
        } else {
          toDate = date;
        }
      });
    }
  }

  Future<void> exportPdf() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (context) => [
            // Header with logo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "Restaurant Ledger Report",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(color: PdfColors.grey400, thickness: 1),
            pw.SizedBox(height: 20),

            // Summary information
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Total Companies: ${ledger.length}",
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "Total Amount: ₹${ledger.fold<double>(0, (sum, item) => sum + item.totalAmount).toStringAsFixed(2)}",
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "Report Period:",
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      "${DateFormat('dd MMM yyyy').format(DateTime.now())}",
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Ledger Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5), // S.No
                1: const pw.FlexColumnWidth(4), // Company
                2: const pw.FlexColumnWidth(5), // Restaurant
                3: const pw.FlexColumnWidth(2.5), // Amount
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    _buildTableCell(
                      'S.No',
                      isHeader: true,
                      alignment: pw.Alignment.center,
                    ),
                    _buildTableCell('Company Name', isHeader: true),
                    _buildTableCell('Restaurant Name', isHeader: true),
                    _buildTableCell(
                      'Amount (₹)',
                      isHeader: true,
                      alignment: pw.Alignment.centerRight,
                    ),
                  ],
                ),
                // Table Data
                ...ledger.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final bgColor = index % 2 == 0
                      ? PdfColors.white
                      : PdfColors.grey50;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: bgColor),
                    verticalAlignment: pw.TableCellVerticalAlignment.middle,
                    children: [
                      _buildTableCell(
                        '${index + 1}',
                        alignment: pw.Alignment.center,
                      ),
                      _buildTableCell(item.companyName),
                      _buildTableCell(item.restaurantName),
                      _buildTableCell(
                        item.totalAmount.toStringAsFixed(2),
                        alignment: pw.Alignment.centerRight,
                        isAmount: true,
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 25),

            // Total Summary
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 200,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue800, width: 1.5),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TOTAL SUMMARY',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total Amount:',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '₹${ledger.fold<double>(0, (sum, item) => sum + item.totalAmount).toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 30),

            // Footer
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Generated By: MAAMAAS App',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    // pw.Text(
                    //   'User: ${user?.name ?? "Admin"}',
                    //   style: const pw.TextStyle(fontSize: 10),
                    // ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Generated on: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Page 1 of 1',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                'This is a computer-generated report. No signature required.',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      );

      // Generate PDF bytes
      await pdf.save();

      // Save and open the PDF
      final fileName =
          "restaurant_ledger_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf";
      // await downloadPdf(pdfBytes, fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("📄 PDF generated and opened: $fileName"),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // print("Error generating PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error generating PDF: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Helper function for table cells
  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isAmount = false,
    pw.Alignment alignment = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: alignment,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader
              ? PdfColors.blue800
              : (isAmount ? PdfColors.green700 : PdfColors.grey800),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          ElevatedButton.icon(
            onPressed: exportPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Export"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: () => pickDate(true),
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: const Color(0xFFB15DC6),
                      // foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      elevation: 2,
                      // ignore: deprecated_member_use
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: Text(
                      fromDate == null
                          ? "From Date"
                          : fromDate!.toString().substring(0, 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: () => pickDate(false),
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: const Color(0xFFB15DC6),
                      // foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      elevation: 2,
                      // ignore: deprecated_member_use
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: Text(
                      toDate == null
                          ? "To Date"
                          : toDate!.toString().substring(0, 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB15DC6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      elevation: 2,
                      // ignore: deprecated_member_use
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: const Text("Apply"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (loading)
              const CircularProgressIndicator()
            else if (ledger.isEmpty)
              const Text("No data found")
            else
              Expanded(
                child: ListView.separated(
                  itemCount: ledger.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = ledger[i];
                    return ListTile(
                      title: Text(item.restaurantName),
                      subtitle: Text(item.companyName),
                      trailing: Text(
                        "₹ ${item.totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantMultiSelectSheet extends StatefulWidget {
  final List<String> allRestaurants;
  final List<String> selected;

  const _RestaurantMultiSelectSheet({
    required this.allRestaurants,
    required this.selected,
  });

  @override
  State<_RestaurantMultiSelectSheet> createState() =>
      _RestaurantMultiSelectSheetState();
}

class _RestaurantMultiSelectSheetState
    extends State<_RestaurantMultiSelectSheet> {
  late List<String> tempSelected;

  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Select Restaurants",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: widget.allRestaurants.map((restaurant) {
                return CheckboxListTile(
                  title: Text(restaurant),
                  value: tempSelected.contains(restaurant),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        tempSelected.add(restaurant);
                      } else {
                        tempSelected.remove(restaurant);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, tempSelected),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: const Text(
                "Done",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
