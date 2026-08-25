import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({required this.token});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> resetPassword() async {
    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse(
        'http://staging.maamaas.com:8080/subscription/forgot/reset/{token}',
      ),
      body: {
        'token': widget.token,
        'newPassword': passwordController.text,
        'confirmPassword': confirmPasswordController.text,
      },
    );
    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Password reset successful')));
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Invalid or expired link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Reset Password")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "New Password"),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: "confirm Password"),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: isLoading ? null : resetPassword,
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text("Change Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
