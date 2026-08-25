import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maamaaspartner/widgets_helper/food/footer.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api/food_authservice.dart';

class premium_InventoryManagement extends StatefulWidget {
  const premium_InventoryManagement({super.key});

  @override
  State<premium_InventoryManagement> createState() =>
      _premium_InventoryManagementState();
}

class _premium_InventoryManagementState
    extends State<premium_InventoryManagement> {
  int currentIndex = 0;
  bool isDrawerOpen = false;

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  void handleItemSelected(int index) {
    setState(() {
      currentIndex = index;
      isDrawerOpen = false;
    });
  }

  int selectedTab = 0;
  final List<String> tabTitles = [
    "Raw", "chef", "Procurement",
    // "procurement cart"
  ];

  void handleTabChange(int index) {
    setState(() {
      selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Inventory Management",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 5),
              Row(
                children: List.generate(tabTitles.length, (index) {
                  final isSelected = selectedTab == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedTab = index);
                      },
                      child: AnimatedContainer(
                        height: 30, // fixed height
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(vertical: 2),
                        margin: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            tabTitles[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              // const Divider(height: 1),
              Expanded(
                child: IndexedStack(
                  index: selectedTab,
                  children: [Raw(), chef(), Procurement()],
                ),
              ),
            ],
          ),
          // AdminCustomDrawer(
          //   isDrawerOpen: isDrawerOpen,
          //   toggleDrawer: toggleDrawer,
          //   currentIndex: currentIndex,
          //   onItemSelected: handleItemSelected,
          // ),
        ],
      ),
      // bottomNavigationBar: Footer()
    );
  }

  Widget _buildAnimatedTabButton(String title, int index) {
    final bool isSelected = selectedTab == index;

    return InkWell(
      onTap: () => handleTabChange(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white, // Background color
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.green[900]! : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.white : Colors.black, // Text color
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            child: Text(title, style: TextStyle(fontSize: 15)),
          ),
        ),
      ),
    );
  }
}

class Raw extends StatefulWidget {
  @override
  _RawState createState() => _RawState();
}

class _RawState extends State<Raw> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final fetched = await food_authservice.fetchItems();

      setState(() {
        items = fetched;
      });
    } catch (e) {
      debugPrint('Error loading items: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load inventory')),
        );
      }
    }
  }

  int nextId = 2;

  void _addItem(String name, int quantity) {
    setState(() {
      items.add({
        'name': name,
        'quantity': quantity,
        'consumed': 0,
        'balance': quantity,
        'id': nextId++,
      });
    });
  }

  void _editItem(int id, String newName, int newQuantity, int newConsumed) {
    setState(() {
      final index = items.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        items[index]['name'] = newName;
        items[index]['quantity'] = newQuantity;
        items[index]['consumed'] = newConsumed;
        items[index]['balance'] = newQuantity - newConsumed;
      }
    });
  }

  void _confirmDelete(int itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await food_authservice.deleteItem(itemId);
              if (success) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Item deleted')));
                _loadItems(); // refresh list
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Delete failed')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddItem() {
    final itemNameController = TextEditingController();
    final quantityController = TextEditingController();
    final procurementValueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // 🎨 Change to any color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text('Add New Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemNameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 5),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              // keyboardType: TextInputType.number,
            ),
            SizedBox(height: 5),
            TextField(
              controller: procurementValueController,
              decoration: InputDecoration(
                labelText: 'Procurement Value',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final itemName = itemNameController.text.trim();
              final quantityText = quantityController.text.trim();
              final procurementValueText = procurementValueController.text
                  .trim();

              if (itemName.isNotEmpty &&
                  quantityText.isNotEmpty &&
                  procurementValueText.isNotEmpty) {
                final quantity = int.tryParse(quantityText);
                final procurementValue = int.tryParse(procurementValueText);

                if (quantity == null || procurementValue == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter valid numbers.")),
                  );
                  return;
                }

                final success = await food_authservice.addItemToInventory(
                  itemName: itemName,
                  quantity: quantity,
                  consumed: 0,
                  procurementValue: procurementValue,
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Item added successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add item.')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            child: Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['itemName']);
    final quantityController = TextEditingController(
      text: item['quantity']?.toString() ?? '0',
    );
    final consumedController = TextEditingController(
      text: item['consumed']?.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: consumedController,
              decoration: const InputDecoration(labelText: 'Consumed'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate inputs
              final name = nameController.text.trim();
              final quantity =
                  int.tryParse(quantityController.text.trim()) ?? 0;
              final consumed =
                  int.tryParse(consumedController.text.trim()) ?? 0;

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item name cannot be empty')),
                );
                return;
              }

              final updated = await food_authservice.updateItem(
                itemId: item['id'],
                name: name,
                quantity: quantity,
                consumed: consumed,
              );
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(updated ? 'Item updated' : 'Update failed'),
                ),
              );

              if (updated) _loadItems(); // Refresh list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddItem,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFB15DC6),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                    shadowColor: Colors.green.withOpacity(0.5),
                  ),
                  icon: Icon(Icons.add),
                  label: Text("ADD"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle import
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFB15DC6),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                    shadowColor: Colors.green.withOpacity(0.5),
                  ),
                  icon: Icon(Icons.file_upload),
                  label: Text("IMPORT"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card list
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text("No items entries"))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // 🔹 Rounded corners
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ), // 🔹 Border
                          ),

                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              item['itemName'].toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Quantity: ${item['quantity']}"),
                                SizedBox(height: 5),
                                Text("Consumed: ${item['consumed']}"),
                                SizedBox(height: 5),
                                Text("Balance: ${item['balance']}"),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _showEditDialog(item);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _confirmDelete(item['id']);
                                  },
                                ),
                              ],
                            ),
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

class chef extends StatefulWidget {
  const chef({super.key});

  @override
  State<chef> createState() => _chefState();
}

class _chefState extends State<chef> {
  List<Map<String, dynamic>> chefs = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChefInventory();
  }

  Future<void> _loadChefInventory() async {
    final data = await food_authservice.fetchChefInventory();
    setState(() {
      chefs = data;
    });
  }

  void _showAddDialog() {
    _nameController.clear();
    _itemController.clear();
    _quantityController.clear();

    showDialog(
      context: context,
      builder: (context) {
        DateTime? localSelectedDate;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Chef"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Chef Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _itemController,
                      decoration: InputDecoration(
                        labelText: "Item",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Quantity",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setStateDialog(() {
                            localSelectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                localSelectedDate == null
                                    ? 'Select Date'
                                    : 'Date: ${localSelectedDate!.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  color: localSelectedDate == null
                                      ? Colors.grey
                                      : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Icon(Icons.calendar_today, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (_nameController.text.isNotEmpty &&
                        _itemController.text.isNotEmpty &&
                        _quantityController.text.isNotEmpty &&
                        localSelectedDate != null) {
                      // Call the InventoryService API
                      final success = await food_authservice.saveChefInventory(
                        chefName: _nameController.text,
                        itemName: _itemController.text,
                        consume: int.tryParse(_quantityController.text) ?? 0,
                        date: localSelectedDate!.toIso8601String().split(
                          'T',
                        )[0],
                      );

                      if (success) {
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to save chef data')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all fields.')),
                      );
                    }
                  },
                  child: Text("Save"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteChef(int id) async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete'),
        content: Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final message = await food_authservice.deleteChefInventory(id: id);

        await _loadChefInventory();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete entry')));
      }
    }
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date); // expects "yyyy-MM-dd"
      return "${parsedDate.day.toString().padLeft(2, '0')}-"
          "${parsedDate.month.toString().padLeft(2, '0')}-"
          "${parsedDate.year}";
    } catch (e) {
      return date; // fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 16),
            // Padding(
            //   padding: EdgeInsets.only(top: 10, left: 10),
            //   child: Align(
            //     alignment: Alignment.topLeft,
            //     child: ElevatedButton.icon(
            //       onPressed: _showAddDialog,
            //       icon: Icon(Icons.add),
            //       style: ElevatedButton.styleFrom(
            //         foregroundColor: Colors.white,
            //         backgroundColor: Color(0xFFB15DC6),
            //         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //         elevation: 2,
            //         shadowColor: Colors.green.withOpacity(0.5),
            //       ),
            //       label: Text("Add"),
            //     ),
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFB15DC6),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                    shadowColor: Colors.green.withOpacity(0.5),
                  ),
                  icon: Icon(Icons.add),
                  label: Text("ADD"),
                ),
                // ElevatedButton.icon(
                //   onPressed: () {
                //     // Handle import
                //   },
                //   style: ElevatedButton.styleFrom(
                //     foregroundColor: Colors.white,
                //     backgroundColor: Color(0xFFB15DC6),
                //     padding:
                //         EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     elevation: 3,
                //     shadowColor: Colors.green.withOpacity(0.5),
                //   ),
                //   icon: Icon(Icons.file_upload),
                //   label: Text("IMPORT"),
                // ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: chefs.isEmpty
                  ? Center(child: Text("No chef entries"))
                  : ListView.builder(
                      itemCount: chefs.length,
                      itemBuilder: (context, index) {
                        final chef = chefs[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              "Chef: ${chef['chefName']}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Item: ${chef['itemName']}\nQuantity: ${chef['consume']}\nDate: ${_formatDate(chef['date'])}",
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteChef(chef['id']),
                            ),
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

class Procurement extends StatefulWidget {
  const Procurement({super.key});

  @override
  State<Procurement> createState() => _ProcurementState();
}

class _ProcurementState extends State<Procurement> {
  List<Map<String, dynamic>> procurementData = [];

  @override
  void initState() {
    super.initState();
    _loadProcurementData();
  }

  Future<void> _loadProcurementData() async {
    final data = await food_authservice.fetchProcurementCart();
    setState(() {
      procurementData = data;
    });
  }

  List<Map<String, dynamic>> savedRequirements = [];
  Set<int> selectedIndices = {};

  Future<void> _incrementQty(int index) async {
    setState(() {
      procurementData[index]['procurementQuantity']++;
      procurementData[index]['edited'] = true;
    });

    final item = procurementData[index];

    await food_authservice.updateProcurementItem(
      id: item['id'],
      itemName: item['itemName'],
      balance: item['balance'],
      date: item['date'],
      procurementQuantity: item['procurementQuantity'],
      vendorId: item['vendorId'],
    );
  }

  Future<void> _decrementQty(int index) async {
    setState(() {
      if (procurementData[index]['procurementQuantity'] > 0) {
        procurementData[index]['procurementQuantity']--;
        procurementData[index]['edited'] = true;
      }
    });

    final item = procurementData[index];

    await food_authservice.updateProcurementItem(
      id: item['id'],
      itemName: item['itemName'],
      balance: item['balance'],
      date: item['date'],
      procurementQuantity: item['procurementQuantity'],
      vendorId: item['vendorId'],
    );
  }

  void _saveRow(int index) {
    final row = procurementData[index];
    if (row['procurementQuantity'] > 0) {
      setState(() {
        row['saved'] = true;
        row['edited'] = false;

        // Update existing or add new
        final existingIndex = savedRequirements.indexWhere(
          (e) => e['itemName'] == row['itemName'],
        );
        if (existingIndex != -1) {
          savedRequirements[existingIndex] = Map<String, dynamic>.from(row);
        } else {
          savedRequirements.add(Map<String, dynamic>.from(row));
        }
      });
    }
  }

  void _exportSelected() async {
    final List<Map<String, dynamic>> selectedItems = selectedIndices
        .map((i) => savedRequirements[i])
        .toList();

    // Convert to CSV rows
    List<List<dynamic>> csvData = [
      ['S.No', 'Item Name', 'Procurement Qty'], // Header
      ...selectedItems.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final item = entry.value;
        return [index, item['item'], item['procurementQuantity']];
      }),
    ];

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(csvData);

    // Save to file
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/procurement_export.csv';
    final file = File(path);
    await file.writeAsString(csv);

    // Share or download
    await Share.shareXFiles([XFile(path)], text: 'Exported Procurement Data');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Procurement Table",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: Colors.grey),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(4),
              3: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[300]),
                children: [
                  _headerCell('Item Name'),
                  _headerCell('C.Qty'),
                  _headerCell('Proc.Qty'),
                  _headerCell('Action'),
                ],
              ),
              ...List.generate(procurementData.length, (index) {
                final row = procurementData[index];
                final shouldShowSave =
                    !(row['saved'] as bool? ?? false) ||
                    (row['edited'] as bool? ?? false);

                return TableRow(
                  children: [
                    _cell(row['itemName'] ?? ''),
                    _cell((row['balance'] ?? 0).toString()),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => _decrementQty(index),
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                          ),
                          Text('${row['procurementQuantity'] ?? 0}'),
                          IconButton(
                            onPressed: () => _incrementQty(index),
                            icon: Icon(Icons.add_circle, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: shouldShowSave
                          ? IconButton(
                              onPressed: () => _saveRow(index),
                              icon: Icon(Icons.save, color: Colors.blue),
                              tooltip: 'Save',
                            )
                          : Icon(Icons.check_circle, color: Colors.green),
                    ),
                  ],
                );
              }),
            ],
          ),
          SizedBox(height: 32),
          if (savedRequirements.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  "Saved Procurement List",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (selectedIndices.isNotEmpty) ...[
                  SizedBox(width: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _exportSelected,
                      icon: Icon(Icons.download),
                      label: Text("Export"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 12),
            ...savedRequirements.asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: selectedIndices.contains(index),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedIndices.add(index);
                              } else {
                                selectedIndices.remove(index);
                              }
                            });
                          },
                        ),
                        Expanded(flex: 1, child: Text('${index + 1}')),
                        Expanded(flex: 3, child: Text(e['itemName'])),
                        Expanded(
                          flex: 2,
                          child: Text('Qty: ${e['procurementQuantity']}'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _headerCell(String text) => Padding(
    padding: EdgeInsets.all(8),
    child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _cell(String text) =>
      Padding(padding: EdgeInsets.all(8), child: Text(text));
}

// class Procurementcart extends StatelessWidget {
//   const Procurementcart({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text("Procurementcart Content"),
//     );
//   }
// }
