import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';

class EditTeamMemberPage extends StatefulWidget {
  final int teamId;
  final Map<String, dynamic> existingMember;

  const EditTeamMemberPage({
    Key? key,
    required this.teamId,
    required this.existingMember,
  }) : super(key: key);

  @override
  State<EditTeamMemberPage> createState() => _EditTeamMemberPageState();
}

class _EditTeamMemberPageState extends State<EditTeamMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.existingMember['name'] ?? '';
    _designationController.text = widget.existingMember['designation'] ?? '';
    _descriptionController.text = widget.existingMember['description'] ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _updateTeamMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Token not found")));
      return;
    }

    final baseUrl = "http://staging.maamaas.com:8080/food";
    final uri = Uri.parse("$baseUrl/api/adminteam/editbyid/${widget.teamId}");

    try {
      final request = http.MultipartRequest('PUT', uri);
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // ✅ JSON data
      final teamData = {
        "name": _nameController.text.trim(),
        "designation": _designationController.text.trim(),
        "description": _descriptionController.text.trim(),
      };

      // ✅ Attach JSON as proper multipart part
      request.files.add(
        http.MultipartFile.fromString(
          'teamData', // 👈 backend expects this key
          jsonEncode(teamData),
          contentType: MediaType('application', 'json'),
        ),
      );

      // ✅ Add image (only if new image selected)
      if (_selectedImage != null) {
        String? mimeType = lookupMimeType(_selectedImage!.path);
        mimeType ??= 'image/jpeg';
        final mimeParts = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _selectedImage!.path,
            contentType: MediaType(mimeParts[0], mimeParts[1]),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("📡 STATUS: ${response.statusCode}");
      debugPrint("📦 BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Team member updated successfully")),
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
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Team Member")),
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
                  _selectedImage == null ? "Change Image" : "Image Selected",
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _updateTeamMember,
                icon: const Icon(Icons.save),
                label: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
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
