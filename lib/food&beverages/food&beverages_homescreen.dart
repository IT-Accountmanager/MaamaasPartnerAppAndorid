import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:maamaaspartner/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api/food_authservice.dart';
import '../Models/food&beverages/bannermodel.dart';
import '../widgets_helper/drawer.dart';
import '../widgets_helper/food/footer.dart';

class food_beverages extends StatefulWidget {
  const food_beverages({super.key});

  @override
  State<food_beverages> createState() => _FoodBeveragesState();
}

class _FoodBeveragesState extends State<food_beverages> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  bool _isLoading = true;
  bool _isEditMode = false;
  bool _isEditingAboutUs = false;
  bool _isEditingMission = false;
  bool _isEditingVision = false;
  bool _isOpen = true;
  File? _bannerImage;
  File? _logoImage;
  bool _isDrawerOpen = false;

  BannerModel? _banner;

  // Static data
  final String _companyName = "Maamaas Restaurant";
  final String _establishedYear = "Est. 2015";
  final String _userName = "Admin";

  // Static text content
  final String _aboutUsText =
      "Welcome to Maamaas Restaurant, where we serve delicious food with love and care. Our commitment to quality and customer satisfaction has made us a favorite dining destination.";
  final String _ourMissionText =
      "To provide exceptional dining experiences through quality food, excellent service, and a warm atmosphere that feels like home.";
  final String _ourVisionText =
      "To become the most loved and trusted restaurant brand, known for our authentic flavors and memorable customer experiences.";

  // UI state
  bool _showDetails = false;

  // Constants
  static const _primaryColor = Color(0xFFB15DC6);

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    final banner = await food_authservice.fetchVendorBanner();
    setState(() {
      _banner = banner;
      _isLoading = false;
    });
  }

  Future<void> _pickBannerImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _bannerImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickLogoImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  // void _toggleDrawer() {
  //   setState(() => _isDrawerOpen = !_isDrawerOpen);
  // }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // clear all saved data (token, userId, etc.)

    // Navigate to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        automaticallyImplyLeading: true,
      ),
      drawer: CustomDrawer(),
      body: SafeArea(
        top: true,
        bottom: true,
        left: false,
        right: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCompanyBanner(),
              _buildUserInfoBar(),

              const SizedBox(height: 10),

              if (_showDetails) _buildDetailsSection(),

              _buildGallerySection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(),
    );
  }

  Widget _buildCompanyBanner() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // If no banner data found
    if (_banner == null) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Stack(
            children: [
              // Centered "No Banner" Text
              const Center(
                child: Text(
                  "No banner image found",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Add Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 13),
                  child: GestureDetector(
                    onTap: _showCompanyDetailsDialog,
                    child: Container(
                      height: 30,
                      width: 70,
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: const Center(
                        child: Text(
                          "Add +",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Empty Logo Placeholder
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Center(
                      child: Text(
                        "No Logo",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- If banner data is found ---
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: _banner!.companyBanner.isNotEmpty
                ? NetworkImage(_banner!.companyBanner)
                : const AssetImage('assets/no_banner.jpg') as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Company Name and Year
            Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _banner!.companyName.isNotEmpty
                          ? _banner!.companyName
                          : "No Company Name",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    _banner!.establishedYear.isNotEmpty
                        ? "Since: ${_banner!.establishedYear}"
                        : "Year not specified",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Add Button (always visible)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 13),
                child: GestureDetector(
                  onTap: _showCompanyDetailsDialog,
                  child: Container(
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: const Center(
                      child: Text(
                        "Add +",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Logo
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: _banner!.companyLogo.isNotEmpty
                        ? Image.network(
                            _banner!.companyLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.error),
                          )
                        : const Center(
                            child: Text(
                              "No Logo",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            // Social Links
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 10,
                ),
                child: Wrap(
                  spacing: 25,
                  children: [
                    if (_banner!.whatsappLink.isNotEmpty)
                      _buildSocialIcon(
                        icon: FontAwesomeIcons.whatsapp,
                        color: Colors.green,
                        label: "WhatsApp",
                        onTap: () => _launchURL(_banner!.whatsappLink),
                      ),
                    if (_banner!.instagramLink.isNotEmpty)
                      _buildSocialIcon(
                        icon: FontAwesomeIcons.instagram,
                        color: Colors.purple,
                        label: "Instagram",
                        onTap: () => _launchURL(_banner!.instagramLink),
                      ),
                    if (_banner!.facebookLink.isNotEmpty)
                      _buildSocialIcon(
                        icon: FontAwesomeIcons.facebook,
                        color: Colors.blue,
                        label: "Facebook",
                        onTap: () => _launchURL(_banner!.facebookLink),
                      ),
                    if (_banner!.twitterLink.isNotEmpty)
                      _buildSocialIcon(
                        icon: FontAwesomeIcons.twitter,
                        color: Colors.lightBlue,
                        label: "Twitter",
                        onTap: () => _launchURL(_banner!.twitterLink),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompanyDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Upload banner details",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Enter Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    labelText: "Enter Established year",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                _buildImagePickerSection(),
                const SizedBox(height: 10),
                _buildSocialLinkFields(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitCompanyDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditMode ? "Save" : "Submit",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Banner Image:",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _pickBannerImage,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo),
                SizedBox(height: 4),
                Text('Add Image'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Logo Image",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _pickLogoImage,
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo),
                SizedBox(height: 4),
                Text('Add Image'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLinkFields() {
    return Column(
      children: [
        TextField(
          readOnly: true, // Make it static/non-editable
          decoration: const InputDecoration(
            labelText: 'Website Link',
            hintText: 'https://www.maamaas.com',
            prefixIcon: Padding(
              padding: EdgeInsets.all(10),
              child: FaIcon(
                FontAwesomeIcons.globe,
                color: Colors.blue,
                size: 20,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'WhatsApp Link',
            hintText: 'https://wa.me/1234567890',
            prefixIcon: Padding(
              padding: EdgeInsets.all(10),
              child: FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.green,
                size: 20,
              ),
            ),
            prefixText: 'https://wa.me/',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Instagram Link',
            hintText: 'https://instagram.com/maamaas',
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0),
              child: FaIcon(
                FontAwesomeIcons.instagram,
                color: Colors.purple,
                size: 18,
              ),
            ),
            prefixText: 'https://instagram.com/',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.purple, width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Facebook Link',
            hintText: 'https://facebook.com/maamaas',
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0),
              child: FaIcon(
                FontAwesomeIcons.facebook,
                color: Colors.blue,
                size: 20,
              ),
            ),
            prefixText: 'https://facebook.com/',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Twitter Link',
            hintText: 'https://twitter.com/maamaas',
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0),
              child: FaIcon(
                FontAwesomeIcons.twitter,
                color: Colors.lightBlue,
                size: 20,
              ),
            ),
            prefixText: 'https://twitter.com/',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitCompanyDetails() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId');
      final token = prefs.getString('token');

      final url = Uri.parse(
        "http://10.10.20.9:6300/Mamaswebsite-0.0.1-SNAPSHOT/banner/add/$vendorId",
      );

      var request = http.MultipartRequest('POST', url);

      // --- Add form fields ---
      request.fields['bannerId'] = '0';
      request.fields['companyName'] = _nameController.text;
      request.fields['establishedYear'] = _yearController.text;
      request.fields['whatsappLink'] = _whatsappController.text;
      request.fields['instagramLink'] = _instagramController.text;
      request.fields['facebookLink'] = _facebookController.text;
      request.fields['twitterLink'] = _twitterController.text;
      request.fields['vendorId'] = vendorId.toString();

      // --- Add image files ---
      if (_bannerImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'companyBanner',
            _bannerImage!.path,
          ),
        );
      }

      if (_logoImage != null) {
        final bytes = await _logoImage!.readAsBytes();
        request.files.add(
          await http.MultipartFile.fromPath('companyLogo', _logoImage!.path),
        );
      }

      // --- Optional Authorization Header ---

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // --- Send request ---
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('✅ Upload successful: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Banner uploaded successfully!")),
        );
        Navigator.pop(context);
      } else {
        print('❌ Upload failed: ${response.statusCode}');
        print(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed (${response.statusCode})")),
        );
      }
    } catch (e) {
      print('⚠️ Error uploading banner: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, color: color, size: 30),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Status Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: _isOpen ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isOpen ? Colors.green.shade200 : Colors.red.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Indicator Dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isOpen ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isOpen ? "OPEN" : "CLOSED",
                  style: TextStyle(
                    color: _isOpen
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: _isOpen,
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.red.shade300,
                  onChanged: (value) {
                    setState(() {
                      _isOpen = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Know More / Show Less Button
          Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primaryColor,
                  Color(0xFF9A4CAD), // Slightly darker shade
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _showDetails = !_showDetails),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showDetails ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _showDetails ? "Show Less" : "Know More",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      children: [
        // About Us Section
        _buildAboutUsSection(),

        // Leadership Section
        _buildLeadershipSection(),

        // Commitments Section
        _buildCommitmentsSection(),
      ],
    );
  }

  Widget _buildAboutUsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    "ABOUT US",
                    style: TextStyle(
                      color: Color(0xFFB15DC6),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              // Toggle between edit and save
              _isEditingAboutUs
                  ? Row(
                      children: [
                        // Save button
                        IconButton(
                          icon: const Icon(Icons.save, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              _isEditingAboutUs = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('About Us saved successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                        // Cancel button
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _isEditingAboutUs = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Changes cancelled'),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  : IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFB15DC6)),
                      onPressed: () {
                        setState(() {
                          _isEditingAboutUs = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit mode activated')),
                        );
                      },
                    ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: const DecorationImage(
                      image: AssetImage("assets/aboutus.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Show camera icon only in edit mode
                  child: _isEditingAboutUs
                      ? Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Image picker would open here',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Show either static text or editable field
              _isEditingAboutUs
                  ? TextField(
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter About Us description...",
                        labelText: "About Us",
                      ),
                      controller: TextEditingController(
                        text:
                            "Welcome to Maamaas Restaurant, where we serve delicious food with love and care. Our commitment to quality and customer satisfaction has made us a favorite dining destination for families and food enthusiasts alike.",
                      ),
                    )
                  : Text(
                      "Welcome to Maamaas Restaurant, where we serve delicious food with love and care. Our commitment to quality and customer satisfaction has made us a favorite dining destination for families and food enthusiasts alike.",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                      softWrap: true,
                    ),

              if (_isEditingAboutUs) ...[
                const SizedBox(height: 16),
                // Save and Cancel buttons in edit mode
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditingAboutUs = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Changes cancelled')),
                        );
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditingAboutUs = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('About Us saved successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB15DC6),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeadershipSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "MEET OUR LEADERSHIP",
          style: TextStyle(
            color: Color(0xFFB15DC6),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Static number of team members
            itemBuilder: (context, index) => _buildLeadershipCard(index),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadershipCard(int index) {
    // Static team member data
    final List<Map<String, String>> teamMembers = [
      {
        'name': 'John Doe',
        'position': 'Head Chef',
        'description': 'Expert in culinary arts with 15+ years of experience.',
      },
      {
        'name': 'Jane Smith',
        'position': 'Restaurant Manager',
        'description': 'Dedicated to providing exceptional customer service.',
      },
      {
        'name': 'Mike Johnson',
        'position': 'Sous Chef',
        'description':
            'Specializes in international cuisine and fusion dishes.',
      },
    ];

    final member = teamMembers[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 15,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 1.0),
        ),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  member['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  member['position']!,
                  style: const TextStyle(
                    color: Color(0xFFB15DC6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member['description']!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitmentsSection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          "OUR COMMITMENTS",
          style: TextStyle(
            color: Color(0xFFB15DC6),
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        const SizedBox(height: 5),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Our Mission Card
              _buildInfoCard(
                imagePath: 'assets/mission.jpg',
                title: 'OUR MISSION',
                text: _ourMissionText,
              ),
              // Our Vision Card
              _buildInfoCard(
                imagePath: 'assets/vision.jpg',
                title: 'OUR VISION',
                text: _ourVisionText,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String imagePath,
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 330,
      width: MediaQuery.of(context).size.width / 2 - 10,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1.0),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "Gallery",
          style: TextStyle(
            color: Color(0xFFB15DC6),
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: List.generate(4, (index) {
              // Static gallery items
              final containerWidth =
                  (MediaQuery.of(context).size.width - 10) / 2;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Container(
                  height: 200,
                  width: containerWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: AssetImage('assets/gallery_placeholder.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.photo, color: Colors.white, size: 40),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _launchURL(String url) {
    // Simple URL launch simulation
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening: $url')));
  }
}
