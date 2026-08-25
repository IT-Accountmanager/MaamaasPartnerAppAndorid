import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api/Apiclient.dart';

class AddBannerPage extends StatefulWidget {
  final int vendorId;
  final Function(dynamic banner) onBannerSaved;
  final Map<String, dynamic>? existingBanner;

  const AddBannerPage({
    super.key,
    required this.vendorId,
    required this.onBannerSaved,
    this.existingBanner,
  });

  @override
  State<AddBannerPage> createState() => _AddBannerPageState();
}

class _AddBannerPageState extends State<AddBannerPage> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController establishedYearController =
      TextEditingController();

  File? logoImageFile;
  File? bannerImageFile;
  bool isEditing = false;

  late String apiUrl;

  @override
  void initState() {
    super.initState();
    if (widget.existingBanner != null) {
      isEditing = true;
      companyNameController.text = widget.existingBanner!['companyName'] ?? '';
      establishedYearController.text =
          widget.existingBanner!['establishedYear']?.toString() ?? '';
    }
  }

  // 🖼️ Pick logo
  Future<void> pickLogoImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => logoImageFile = File(picked.path));
  }

  // 🖼️ Pick banner
  Future<void> pickBannerImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => bannerImageFile = File(picked.path));
  }

  // 🚀 Save or Update banner
  Future<void> saveBanner() async {
    if (companyNameController.text.trim().isEmpty ||
        establishedYearController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    try {
      final bannerData = {
        "id": 0,
        "vendorId": widget.vendorId,
        "companyName": companyNameController.text.trim(),
        "establishedYear": establishedYearController.text.trim(),
        "companyLogo": "",
        "companyBanner": "",
      };

      final response = await ApiClient.sendMultipartRequest(
        endpoint: "api/vendor/banner/update/${widget.vendorId}",
        method: "PUT",
        service: "catering",
        data: {"bannerData": jsonEncode(bannerData)},
        files: {
          if (logoImageFile != null) "companyLogo": logoImageFile!,
          if (bannerImageFile != null) "companyBanner": bannerImageFile!,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Banner added successfully!")),
        );
        widget.onBannerSaved(jsonDecode(response.body));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed: ${response.statusCode}\n${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Banner" : "Add Banner",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🖼️ Company Logo
              GestureDetector(
                onTap: pickLogoImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple, width: 2),
                  ),
                  child: logoImageFile == null
                      ? const Center(child: Text("Tap to upload company logo"))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            logoImageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // 🖼️ Company Banner
              GestureDetector(
                onTap: pickBannerImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple, width: 2),
                  ),
                  child: bannerImageFile == null
                      ? const Center(child: Text("Tap to upload banner image"))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            bannerImageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // 🏢 Company Name
              TextField(
                controller: companyNameController,
                decoration: InputDecoration(
                  labelText: "Company Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 📅 Established Year
              TextField(
                controller: establishedYearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Established Year",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 🔘 Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: saveBanner,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text(isEditing ? "Update" : "Save"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
