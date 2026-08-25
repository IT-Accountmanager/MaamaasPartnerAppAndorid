import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api/APIclient.dart';
import '../CateringModels/package_model.dart';

class UpdatePackagePage extends StatefulWidget {
  final dynamic packageData;

  const UpdatePackagePage({super.key, required this.packageData});

  @override
  State<UpdatePackagePage> createState() => _UpdatePackagePageState();
}

class _UpdatePackagePageState extends State<UpdatePackagePage> {
  // Controllers
  final TextEditingController packageNameController = TextEditingController();
  final List<Map<String, dynamic>> items = [];

  // Package types
  final List<String> packageTypes = ["Veg", "Non-veg", "Drinks"];
  final Map<String, String> packageTypeMap = {
    "Veg": "Veg",
    "Non-veg": "Non_veg",
    "Drinks": "Drinks",
  };

  // State variables
  String? selectedPackageType;
  File? packageImageFile;
  double totalPrice = 0.0;
  bool _isLoading = false;

  // Service methods
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<int?> _getVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('vendorId');
  }

  Future<Map<String, dynamic>> _updatePackageWithMultipart({
    required int vendorId,
    required int packageId,
    required Map<String, dynamic> packageData,
    File? imageFile,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse(
        'http://staging.maamaas.com:8080/catering/api/vendor/$vendorId/$packageId',
      );
      // final uri = Uri.parse(
      //   'http://staging.maamaas.com:8080/catering/api/vendor/$vendorId/$packageId',
      // );

      print('📤 Sending PUT request to: $uri');
      print('🔑 Token exists: ${token.isNotEmpty}');
      print('📦 Package data to send: ${jsonEncode(packageData)}');
      print('🖼️ New image selected: ${imageFile != null}');

      // Create multipart request
      final request = http.MultipartRequest('PUT', uri);

      // Headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = '*/*';

      // Send packageData as proper JSON part
      request.files.add(
        http.MultipartFile.fromString(
          'packageData',
          jsonEncode(packageData),
          contentType: MediaType('application', 'json'),
        ),
      );

      // Add image ONLY if selected
      if (imageFile != null && await imageFile.exists()) {
        print('🖼️ Adding NEW image file: ${imageFile.path}');

        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        final parts = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: MediaType(parts[0], parts[1]),
          ),
        );
      }

      print('📎 Request files count: ${request.files.length}');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Package updated successfully!');
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to update package: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Multipart request error: $e');
      rethrow;
    }
  }

  /// Update individual item with both name and price
  // Future<bool> _updateItem({
  //   required int vendorId,
  //   required int packageId, // Add package ID parameter
  //   required int itemId,
  //   required String itemName,
  //   required double price,
  // }) async {
  //   try {
  //     final token = await _getToken();
  //     if (token == null) {
  //       throw Exception('Authentication token not found');
  //     }
  //
  //     final uri = Uri.parse(
  //       'http://staging.maamaas.com:8080/catering/api/vendor/$vendorId/items/$itemId',
  //     );
  //
  //     print('📝 Updating item: ID=$itemId, Name=$itemName, Price=$price');
  //     print('📝 Using vendor ID: $vendorId (from package)');
  //     print('📝 For package ID: $packageId');
  //
  //     // Include packageId in the request body
  //     final response = await http.put(
  //       uri,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': '*/*',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: jsonEncode({
  //         'id': itemId,
  //         'itemName': itemName,
  //         'price': price,
  //         'packageId': packageId,
  //       }),
  //     );
  //
  //     print('📝 Item update response: ${response.statusCode}');
  //     print('📝 Item update body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       print('❌ Failed to update item. Status: ${response.statusCode}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('❌ Item update error: $e');
  //     return false;
  //   }
  // }
  Future<bool> _updateItem({
    required int vendorId,
    required int packageId,
    required int itemId,
    required String itemName,
    required double price,
  }) async {
    try {
      print('📝 Updating item: ID=$itemId, Name=$itemName, Price=$price');
      print('📝 Using vendor ID: $vendorId');
      print('📝 For package ID: $packageId');

      final response = await ApiClient.put("vendor/$vendorId/items/$itemId", {
        'id': itemId,
        'itemName': itemName,
        'price': price,
        'packageId': packageId,
      }, service: "catering");

      print('📝 Item update response: ${response.statusCode}');
      print('📝 Item update body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Item update error: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Initialize form data from existing package
  void _initializeData() {
    final pkg = widget.packageData;

    print('📋 Initializing package data:');
    print('📋 Package ID: ${pkg['id']}');
    print('📋 Package Name: ${pkg['packageName']}');
    print('📋 Package Type: ${pkg['packageType']}');
    print('📋 Vendor ID: ${pkg['vendorId']}');
    print('📋 Items count: ${pkg['items']?.length ?? 0}');

    // Set package name
    packageNameController.text = pkg['packageName'] ?? '';

    // Set package type (convert Non_veg to Non-veg for display)
    selectedPackageType = pkg['packageType'] == "Non_veg"
        ? "Non-veg"
        : pkg['packageType'];

    // Set total price
    totalPrice = (pkg['totalPrice'] ?? 0).toDouble();

    // Initialize items
    if (pkg['items'] != null && pkg['items'].isNotEmpty) {
      for (var item in pkg['items']) {
        print(
          '📋 Item: ${item['itemName']} - ₹${item['price']} (id: ${item['id']})',
        );
        final nameController = TextEditingController(
          text: item['itemName'] ?? '',
        );
        final priceController = TextEditingController(
          text: (item['price'] ?? 0).toString(),
        );

        // Add listener to recalculate total when price changes
        priceController.addListener(_calculateTotal);
        nameController.addListener(
          _calculateTotal,
        ); // Optional: if name changes don't affect total

        items.add({
          'id': item['id'] ?? 0,
          'name': nameController,
          'price': priceController,
          'originalName': item['itemName'] ?? '',
          'originalPrice': (item['price'] ?? 0).toDouble(),
        });
      }
    }

    // Calculate initial total
    _calculateTotal();
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    if (_isLoading) return;

    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (pickedFile != null) {
        print('🖼️ Image picked: ${pickedFile.path}');
        setState(() {
          packageImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError("Failed to pick image: $e");
    }
  }

  // Calculate total price from all items
  void _calculateTotal() {
    double sum = 0.0;
    for (var item in items) {
      final priceText = item['price']!.text.trim();
      final price = double.tryParse(priceText.isEmpty ? '0' : priceText) ?? 0.0;
      sum += price;
    }
    setState(() => totalPrice = sum);
  }

  // Add new item to the list
  void addNewItem() {
    setState(() {
      final nameController = TextEditingController();
      final priceController = TextEditingController(text: '0');

      priceController.addListener(_calculateTotal);

      items.add({
        'id': 0,
        'name': nameController,
        'price': priceController,
        'originalName': '',
        'originalPrice': 0.0,
      });
    });
  }

  void removeItem(int index) {
    if (_isLoading) return;

    setState(() {
      items[index]['price']?.removeListener(_calculateTotal);
      items[index]['name']?.removeListener(_calculateTotal);
      items.removeAt(index);
      _calculateTotal();
    });
  }

  bool _validateForm() {
    if (packageNameController.text.trim().isEmpty) {
      _showError("Please enter package name");
      return false;
    }

    if (selectedPackageType == null) {
      _showError("Please select package type");
      return false;
    }

    if (items.isEmpty) {
      _showError("Please add at least one item");
      return false;
    }

    for (int i = 0; i < items.length; i++) {
      final itemName = items[i]['name']!.text.trim();
      final priceText = items[i]['price']!.text.trim();

      if (itemName.isEmpty) {
        _showError("Please enter name for item ${i + 1}");
        return false;
      }

      if (priceText.isEmpty) {
        _showError("Please enter price for item ${i + 1}");
        return false;
      }

      final price = double.tryParse(priceText);
      if (price == null || price <= 0) {
        _showError("Please enter valid price for item ${i + 1}");
        return false;
      }
    }

    return true;
  }

  List<Map<String, dynamic>> _getItemsToUpdate() {
    final List<Map<String, dynamic>> itemsToUpdate = [];

    for (var item in items) {
      final itemId = item['id'];
      if (itemId == 0) continue;
      final newName = item['name']!.text.trim();
      final newPrice = double.tryParse(item['price']!.text.trim()) ?? 0.0;
      final originalName = item['originalName'] ?? '';
      final originalPrice = item['originalPrice'] ?? 0.0;

      // Check if name OR price changed
      if (newName != originalName || newPrice != originalPrice) {
        itemsToUpdate.add({
          'id': itemId,
          'itemName': newName,
          'price': newPrice,
        });
        print(
          '📝 Item ${itemId} needs update: Name: $originalName -> $newName, Price: $originalPrice -> $newPrice',
        );
      }
    }

    return itemsToUpdate;
  }

  // Main update function
  Future<void> updatePackage() async {
    // Validate form
    if (!_validateForm()) return;

    // Start loading
    setState(() => _isLoading = true);

    try {
      // Get authentication data
      final token = await _getToken();
      final vendorId = widget.packageData['vendorId'];
      final packageId = widget.packageData['id']; // Get package ID

      print('🔐 Auth check - Token: ${token != null ? "Exists" : "Missing"}');
      print('🔐 Auth check - Using vendor ID from package: $vendorId');
      print('📦 Package ID to update: $packageId');

      if (token == null) {
        throw Exception("Authentication required. Please login again.");
      }

      if (vendorId == null) {
        throw Exception("Vendor ID not found in package data");
      }

      // First, update individual items that have changes
      final itemsToUpdate = _getItemsToUpdate();

      if (itemsToUpdate.isNotEmpty) {
        print('📝 Found ${itemsToUpdate.length} items to update individually');

        bool allItemsUpdated = true;

        for (var itemData in itemsToUpdate) {
          final success = await _updateItem(
            vendorId: vendorId,
            packageId: packageId,
            itemId: itemData['id'],
            itemName: itemData['itemName'],
            price: itemData['price'],
          );

          if (!success) {
            allItemsUpdated = false;
            print('❌ Failed to update item ${itemData['id']}');
          } else {
            print('✅ Successfully updated item ${itemData['id']}');
          }
        }

        if (!allItemsUpdated) {
          throw Exception("Failed to update some items");
        }
      } else {
        print('📝 No individual item updates needed');
      }

      final itemsJson = items.map((item) {
        return {
          "id": item['id'] ?? 0,
          "itemName": item['name']!.text.trim(),
          "price": double.tryParse(item['price']!.text.trim()) ?? 0.0,
        };
      }).toList();

      final Map<String, dynamic> packageData = {
        "id": packageId,
        "vendorId": vendorId,
        "packageName": packageNameController.text.trim(),
        "packageType": packageTypeMap[selectedPackageType]!,
        "companyLogo": widget.packageData['companyLogo'] ?? "",
        "companyName": widget.packageData['companyName'] ?? "",
        "items": itemsJson,
        "totalPrice": totalPrice,
      };

      if (packageImageFile == null) {
        packageData["image"] = widget.packageData['image'] ?? "";
      }

      final updatedPackage = await _updatePackageWithMultipart(
        vendorId: vendorId,
        packageId: packageId,
        packageData: packageData,
        imageFile: packageImageFile,
      );

      final PackageModel packageModel = PackageModel.fromJson(updatedPackage);

      _showSuccess("Package updated successfully!");

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop(packageModel);
      });
    } catch (e) {
      print('❌ Update failed with error: $e');
      _showError("Update failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildImageWidget() {
    final boxDecoration = BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.deepPurple, width: 2),
    );

    if (packageImageFile != null) {
      return Container(
        decoration: boxDecoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(packageImageFile!, fit: BoxFit.cover),
        ),
      );
    }

    final imageUrl = widget.packageData['image'] ?? '';
    if (imageUrl.isNotEmpty) {
      return Container(
        decoration: boxDecoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Image not available"),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
    return Container(
      decoration: boxDecoration,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text("Tap to add image"),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    packageNameController.dispose();

    for (var item in items) {
      item['price']?.removeListener(_calculateTotal);
      item['name']?.removeListener(_calculateTotal);
      item['name']?.dispose();
      item['price']?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Package",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  GestureDetector(
                    onTap: _isLoading ? null : pickImage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 150,
                      width: double.infinity,
                      child: _buildImageWidget(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Package Name
                  TextField(
                    controller: packageNameController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: "Package Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.restaurant_menu),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Package Type
                  DropdownButtonFormField<String>(
                    value: selectedPackageType,
                    items: packageTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() => selectedPackageType = value);
                          },
                    decoration: InputDecoration(
                      labelText: "Package Type",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Items Header
                  Row(
                    children: [
                      const Text(
                        "Items",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Total: ₹${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Items List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isExistingItem = item['id'] != 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        color: isExistingItem
                            ? Colors.white
                            : Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Item Name
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: item['name'],
                                  enabled: !_isLoading,
                                  decoration: InputDecoration(
                                    labelText: "Item Name",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    hintText: "Enter item name",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Price
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: item['price'],
                                  enabled: !_isLoading,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Price",
                                    prefixText: "₹",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    hintText: "0.00",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Delete Button
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: _isLoading ? Colors.grey : Colors.red,
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () => removeItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Add Item Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : addNewItem,
                      icon: const Icon(Icons.add),
                      label: const Text("Add Item"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Update Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : updatePackage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Update Package"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (items.any((item) => item['id'] != 0))
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Note: Changes to existing items will be updated individually",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
