import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class AddTeamMemberPage extends StatefulWidget {
  final int vendorId;
  const AddTeamMemberPage({Key? key, required this.vendorId}) : super(key: key);

  @override
  State<AddTeamMemberPage> createState() => _AddTeamMemberPageState();
}

class _AddTeamMemberPageState extends State<AddTeamMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _addTeamMember() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image")));
      return;
    }

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No token found")));
      return;
    }

    final baseUrl = "http://staging.maamaas.com:8080/food";
    final uri = Uri.parse("$baseUrl/api/adminteam/addteam/${widget.vendorId}");

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // ✅ Prepare JSON data
      final teamData = {
        "name": _nameController.text.trim(),
        "designation": _designationController.text.trim(),
        "description": _descriptionController.text.trim(),
      };

      // ✅ Add JSON as a file part (not a field)
      final jsonString = jsonEncode(teamData);
      request.files.add(
        http.MultipartFile.fromString(
          'teamData', // 👈 backend expects this exact key
          jsonString,
          contentType: MediaType('application', 'json'),
        ),
      );

      // ✅ Add image part
      String? mimeType = lookupMimeType(_selectedImage!.path);
      mimeType ??= 'image/jpeg';
      final mimeParts = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // 👈 backend field name for the image
          _selectedImage!.path,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        ),
      );
      //
      // debugPrint("==== FINAL REQUEST DEBUG ====");
      // debugPrint("FILES: ${request.files.map((f) => f.field).toList()}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // debugPrint("📡 STATUS: ${response.statusCode}");
      // debugPrint("📦 BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Team member added successfully")),
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
      // debugPrint("💥 Exception: $e");
      // debugPrint("🪜 Stack: $st");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Team Member")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(labelText: "Designation"),
                validator: (v) => v!.isEmpty ? "Enter designation" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: Text(
                  _selectedImage == null ? "Select Image" : "Change Image",
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _addTeamMember,
                icon: const Icon(Icons.save),
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
