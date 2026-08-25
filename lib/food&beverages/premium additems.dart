import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maamaaspartner/Api/food_authservice.dart';
import '../Models/food&beverages/dish.dart';
import '../widgets_helper/Dotted_divider.dart';

class PremiumAddItems extends StatefulWidget {
  final Function(Dish) onItemSaved;
  final int dishId;
  final int? parentId;
  final String dishName;
  final double? price;
  final String? description;
  final double? effectivePrice;
  final String? dishImageBase64;
  final bool isEdit;
  final int? stockQuantity;
  final double? discount;
  final bool isSubCategory;

  const PremiumAddItems({
    Key? key,
    required this.onItemSaved,
    required this.dishId,
    this.parentId,
    required this.dishName,
    this.price,
    this.description,
    this.stockQuantity,
    this.effectivePrice,
    this.dishImageBase64,
    this.discount,
    this.isEdit = false,
    this.isSubCategory = false,
  }) : super(key: key);

  @override
  State<PremiumAddItems> createState() => _PremiumAddItemsState();
}

class _PremiumAddItemsState extends State<PremiumAddItems> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _packingchargesController =
      TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  String? selectedChefType;
  String? selectedstock;
  String planType = "BASIC";
  bool isLoadingPlan = true;
  String _selectedItemType = 'Veg';
  Uint8List? _imageBytes;
  String? _base64Image;
  bool _isBase64Image = false;
  int? selectedCategoryId;
  File? _image;
  bool _isPriceInclusiveChecked = true; // Checkbox state

  static const _itemTypes = ['Veg', 'Non-veg', 'Egg'];
  static const _itemTypeColors = {
    'Veg': Colors.green,
    'Non-veg': Colors.red,
    'Egg': Colors.deepOrangeAccent,
  };

  final List<String> chefTypes = [
    "Chef_North",
    "Chef_South",
    "Chef_Continental",
    "Chef_Chinese",
  ];

  final List<String> stock = ["In_Stock", "Out_of_Stock"];

  @override
  void initState() {
    super.initState();
    _loadPlanType();
    _initializeEditData();
    // Listen to price and discount changes
    _priceController.addListener(() {
      if (mounted) setState(() {});
    });
    _discountController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _packingchargesController.dispose();
    _gstController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _loadPlanType() async {
    final prefs = await SharedPreferences.getInstance();
    final plan = prefs.getStringList('planTypes') ?? ['BASIC'];

    setState(() {
      planType = plan.contains('PREMIUM') ? 'PREMIUM' : 'BASIC';
      isLoadingPlan = false;
    });
  }

  void _initializeEditData() {
    if (!widget.isEdit) return;

    _nameController.text = widget.dishName;
    _priceController.text = widget.price?.toString() ?? '';
    _descriptionController.text = widget.description ?? '';

    // Set discount if exists and > 0
    if (widget.discount != null && widget.discount! > 0) {
      _discountController.text = widget.discount!.toStringAsFixed(2);
    }

    // Load existing image if available
    if (widget.dishImageBase64 != null && widget.dishImageBase64!.isNotEmpty) {
      try {
        _imageBytes = base64Decode(widget.dishImageBase64!);
        _isBase64Image = true;
      } catch (e) {
        debugPrint('Error loading base64 image: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveItem() async {
    final nameController = _nameController.text.trim();
    final priceController = _priceController.text.trim();
    final selectedTag = _selectedItemType;
    final discountController = _discountController.text.trim();
    final descriptionController = _descriptionController.text.trim();
    final gstController = _gstController.text.trim();
    final packingController = _packingchargesController.text.trim();

    // Validate required fields
    if (nameController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter item name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (priceController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter item price"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId') ?? 0;

    final price = double.tryParse(priceController) ?? 0;
    final discountPercentage = double.tryParse(discountController) ?? 0;

    // Calculate effective price - if no discount, effective price = original price
    double effectivePrice;
    if (discountPercentage > 0) {
      final discountAmount = price * (discountPercentage / 100);
      effectivePrice = price - discountAmount;
    } else {
      effectivePrice = price; // No discount, effective price = original price
    }

    final dishData = {
      "price": price,
      "dishName": nameController,
      "tag": selectedTag,
      "stock": selectedstock ?? "In_Stock",
      "parentId": widget.parentId ?? 0,
      "menuStatus": "Enable",
      "chefType": selectedChefType ?? "Chef_North",
      "dishImage": "",
      "discount": discountPercentage,
      "description": descriptionController,
      "stockQuantity": 0, // Quantity field removed
      "consumedQuantity": 0,
      "balanceQuantity": 0,
      "effectivePrice": effectivePrice,
      "gst": double.tryParse(gstController) ?? 0,
      "packingCharges": double.tryParse(packingController) ?? 0,
      "companyName": "",
      "vendorId": vendorId,
    };

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool success;

      if (widget.isEdit) {
        // ============ PUT API FOR EDITING ============
        debugPrint('🔄 Calling PUT API for dishId: ${widget.dishId}');

        success = await food_authservice.updateDish(
          dishId: widget.dishId,
          dishData: dishData,
          imageFile: _image,
        );

        if (success) {
          debugPrint('✅ PUT API Success for dishId: ${widget.dishId}');
        } else {
          debugPrint('❌ PUT API Failed for dishId: ${widget.dishId}');
        }
      } else {
        // ============ POST API FOR NEW ITEM ============
        dishData["dishId"] = 0; // Only for new items

        success = await food_authservice.postFoodItem(
          dishData: dishData,
          imageFile: _image,
        );
      }

      Navigator.pop(context); // remove loading dialog

      if (success) {
        // Create Dish object to pass back
        Dish updatedDish = Dish(
          dishId: widget.isEdit ? widget.dishId : 0,
          price: price,
          dishName: nameController,
          tag: selectedTag,
          stock: selectedstock ?? "In_Stock",
          parentId: widget.parentId ?? 0,
          menuStatus: "Enable",
          chefType: selectedChefType ?? "Chef_North",
          dishImage: "",
          discount: discountPercentage,
          description: descriptionController,
          stockQuantity: 0, // Quantity field removed
          consumedQuantity: 0,
          balanceQuantity: 0,
          effectivePrice: effectivePrice,
          gst: double.tryParse(gstController) ?? 0,
          packingCharges: double.tryParse(packingController) ?? 0,
          vendorId: vendorId,
        );

        // Call the callback with the updated dish
        widget.onItemSaved(updatedDish);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? "✅ Dish updated successfully!"
                  : "✅ Dish added successfully!",
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Optionally, you can clear all fields after successful save
        if (!widget.isEdit) {
          _nameController.clear();
          _priceController.clear();
          _descriptionController.clear();
          _discountController.clear();
          _gstController.clear();
          _packingchargesController.clear();
          setState(() {
            _image = null;
            selectedChefType = null;
            selectedstock = null;
            _selectedItemType = 'Veg';
            _isPriceInclusiveChecked = true;
          });
        }

        // Wait a bit then close the screen
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pop(context); // Close the Add/Edit screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? "❌ Failed to update dish"
                  : "❌ Failed to add dish",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // remove loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error in _saveItem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingPlan) {
      return Scaffold(
        backgroundColor: Colors.grey[300],
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          '${widget.isEdit ? 'Edit' : 'Add'} an item - ${widget.dishName} (${planType} Plan)',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                children: [
                  _buildBasicDetailsSection(),
                  const SizedBox(height: 10),
                  _buildDescriptionSection(),
                  const SizedBox(height: 10),
                  if (planType == "PREMIUM") _buildcheftypeSection(),
                  const SizedBox(height: 10),
                  _buildstockSection(),
                  const SizedBox(height: 10),
                  _buildPricingSection(),
                  const SizedBox(height: 16),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicDetailsSection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Basic Details'),
          const DottedDivider(),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type Item name*',
                    ),
                  ),
                ),
              ),
              _buildImagePicker(),
            ],
          ),
          const SizedBox(height: 10),
          _buildItemTypeSelector(),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Description:'),
          Container(
            height: 100,
            width: 300,
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter item description...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildcheftypeSection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Select Chef Type:'),
          Container(height: 50, child: _buildChefTypeDropdown()),
        ],
      ),
    );
  }

  Widget _buildstockSection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Stock Status:'),
          Container(height: 50, child: _buildstockDropdown()),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    // Calculate current values
    final double priceValue = double.tryParse(_priceController.text) ?? 0;
    final double discountValue = double.tryParse(_discountController.text) ?? 0;

    // Only show effective price when discount > 0 AND price > 0
    final bool shouldShowEffectivePrice = discountValue > 0 && priceValue > 0;

    // Calculate effective price if needed
    double calculatedEffectivePrice = priceValue;
    if (shouldShowEffectivePrice) {
      final discountAmount = priceValue * (discountValue / 100);
      calculatedEffectivePrice = priceValue - discountAmount;
    }

    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Item Pricing'),
          const DottedDivider(),
          const SizedBox(height: 10),
          _buildPriceField(_priceController, 'Item Price*'),
          const SizedBox(height: 10),
          _buildPriceField(_discountController, 'Discount %'),

          // Show effective price ONLY when discount > 0 AND price > 0
          if (shouldShowEffectivePrice) ...[
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.price_check, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Effective Price (After Discount)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '₹${calculatedEffectivePrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '₹${priceValue.toStringAsFixed(2)} - ${discountValue.toStringAsFixed(2)}% = ₹${calculatedEffectivePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          _buildPriceField(_gstController, 'GST %'),
          const SizedBox(height: 10),
          _buildPriceField(_packingchargesController, 'Packing charges'),
          const SizedBox(height: 10),
          _buildPricingFooter(),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isBase64Image && _imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                ),
              )
            : _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _image!,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.grey),
                  SizedBox(height: 4),
                  Text(
                    'Add Image',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildItemTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Item type*", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: _itemTypes
              .map(
                (type) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildItemTypeButton(type),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildItemTypeButton(String type) {
    final bool isSelected = _selectedItemType == type;
    final Color dotColor = _itemTypeColors[type] ?? Colors.grey;

    return GestureDetector(
      onTap: () => setState(() => _selectedItemType = type),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? dotColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? dotColor : Colors.grey),
        ),
        child: Row(
          children: [
            Text(type, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: dotColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField(TextEditingController controller, String label) {
    return SizedBox(
      height: 60,
      width: 300,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixText: label.contains('Price') || label.contains('charges')
              ? "₹"
              : "",
          prefixStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          suffixText: label.contains('Discount') || label.contains('GST')
              ? "%"
              : "",
        ),
      ),
    );
  }

  Widget _buildPricingFooter() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Row(
        children: [
          // Interactive Checkbox
          GestureDetector(
            onTap: () {
              setState(() {
                _isPriceInclusiveChecked = !_isPriceInclusiveChecked;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _isPriceInclusiveChecked
                    ? (planType == "PREMIUM" ? Color(0xFF2A0947) : Colors.green)
                    : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: planType == "PREMIUM"
                      ? Color(0xFF2A0947)
                      : Colors.green,
                  width: 2,
                ),
              ),
              child: _isPriceInclusiveChecked
                  ? Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This price is inclusive of GST",
                  style: TextStyle(
                    fontSize: 14,
                    color: _isPriceInclusiveChecked
                        ? (planType == "PREMIUM"
                              ? Color(0xFF2A0947)
                              : Colors.green)
                        : Colors.grey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  planType == "PREMIUM"
                      ? "Premium plan features enabled"
                      : "Basic plan features",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChefTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedChefType,
      decoration: InputDecoration(
        labelText: "Select Chef Type",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        prefixIcon: Icon(Icons.emoji_food_beverage, color: Color(0xFF2A0947)),
      ),
      items: chefTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(
            type.replaceAll("Chef_", "Chef "),
            style: TextStyle(color: Color(0xFF2A0947)),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedChefType = value;
        });
      },
    );
  }

  Widget _buildstockDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedstock,
      decoration: InputDecoration(
        labelText: "Select Stock Status",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        prefixIcon: Icon(Icons.inventory, color: Color(0xFF2A0947)),
      ),
      items: stock.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(
            type.replaceAll("_", " "),
            style: TextStyle(color: Color(0xFF2A0947)),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedstock = value;
        });
      },
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saveItem,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: planType == "PREMIUM" ? Color(0xFF2A0947) : Colors.green,
        ),
        child: Center(
          child: Text(
            "Save and Submit",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
