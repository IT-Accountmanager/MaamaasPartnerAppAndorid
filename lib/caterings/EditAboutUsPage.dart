import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAboutUsPage extends StatefulWidget {
  final int vendorId;
  final Map<String, dynamic>? existingData;

  const EditAboutUsPage({super.key, required this.vendorId, this.existingData});

  @override
  State<EditAboutUsPage> createState() => _EditAboutUsPageState();
}

class _EditAboutUsPageState extends State<EditAboutUsPage> {
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController missionController = TextEditingController();
  final TextEditingController visionController = TextEditingController();

  File? imageFile;
  File? image1File;
  File? image2File;
  File? image3File;
  File? image4File;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      isEditing = true;
      aboutController.text = widget.existingData!['aboutUs'] ?? '';
      missionController.text = widget.existingData!['mission'] ?? '';
      visionController.text = widget.existingData!['vision'] ?? '';
    }
  }

  // 🖼️ Pick Image
  Future<void> _pickImage(Function(File) setter) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => setter(File(picked.path)));
    }
  }

  // 🚀 Save / Update About Us
  Future<void> saveAboutUs() async {
    debugPrint("🟢 saveAboutUs() called");

    if (aboutController.text.trim().isEmpty ||
        missionController.text.trim().isEmpty ||
        visionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentication token not found")),
        );
        return;
      }

      // ✅ Dynamic Vendor ID used here
      // final uri = Uri.parse(
      //   "http://staging.maamaas.com:8080/catering/api/vendor/aboutus/update/${widget.vendorId}",
      // );
      final uri = Uri.parse(
        "http://staging.maamaas.com:8080/catering/api/vendor/aboutus/update/${widget.vendorId}",
      );

      final request = http.MultipartRequest('PUT', uri);

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      final aboutData = {
        "aboutUsId": widget.existingData?['aboutUsId'] ?? 0,
        "vendorId": widget.vendorId,
        "aboutUs": aboutController.text.trim(),
        "mission": missionController.text.trim(),
        "vision": visionController.text.trim(),
        "image": "",
        "image1": "",
        "image2": "",
        "image3": "",
        "image4": "",
      };

      request.files.add(
        http.MultipartFile.fromString(
          'aboutUsData',
          jsonEncode(aboutData),
          contentType: MediaType('application', 'json'),
        ),
      );

      Future<void> addImage(String fieldName, File? file) async {
        if (file != null) {
          final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
          final parts = mimeType.split('/');
          final fileName = file.path.split('/').last;

          request.files.add(
            await http.MultipartFile.fromPath(
              fieldName,
              file.path,
              filename: fileName,
              contentType: MediaType(parts[0], parts[1]),
            ),
          );
        }
      }

      await addImage('image', imageFile);
      await addImage('image1', image1File);
      await addImage('image2', image2File);
      await addImage('image3', image3File);
      await addImage('image4', image4File);

      debugPrint("==== FINAL REQUEST DEBUG ====");
      debugPrint("FILES: ${request.files.map((f) => f.filename).toList()}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("📡 STATUS: ${response.statusCode}");
      debugPrint("📦 BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ About Us updated successfully!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed: ${response.statusCode}\n${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      debugPrint("💥 Exception: $e");
      debugPrint("🪜 Stack: $st");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildImagePicker(
    String label,
    File? imageFile,
    Function(File) setter,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickImage(setter),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple, width: 2),
            ),
            child: imageFile == null
                ? const Center(child: Text("Tap to upload image"))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit About Us" : "Add About Us",
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
              _buildImagePicker(
                "AboutUs Image",
                imageFile,
                (f) => imageFile = f,
              ),
              _buildImagePicker(
                "Gallery Image 1",
                image1File,
                (f) => image1File = f,
              ),
              _buildImagePicker(
                "Gallery Image 2",
                image2File,
                (f) => image2File = f,
              ),
              _buildImagePicker(
                "Gallery Image 3",
                image3File,
                (f) => image3File = f,
              ),
              _buildImagePicker(
                "Gallery Image 4",
                image4File,
                (f) => image4File = f,
              ),

              TextField(
                controller: aboutController,
                decoration: InputDecoration(
                  labelText: "About Us",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: missionController,
                decoration: InputDecoration(
                  labelText: "Mission",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: visionController,
                decoration: InputDecoration(
                  labelText: "Vision",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

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
                      onPressed: saveAboutUs,
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
