import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Please fill all fields.");
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8080/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', user['username']);
        prefs.setString('email', user['email']);

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final message = response.body.toString().toLowerCase();

        if (message.contains('disabled')) {
          _showDisabledDialog();
        } else {
          _showErrorDialog("Invalid email or password.");
        }
      }
    } catch (e) {
      _showErrorDialog("An error occurred. Please try again.");
    }
  }

  void _showDisabledDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Login Error",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Your account is disabled."),
            SizedBox(height: 8),
            Text("Please contact support at:"),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text("+79204329468"),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Flexible(child: Text("karlosashraf80@gmail.com")),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("OK", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Login Error",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/images/onboarding_illustration.png', height: 100),
            const SizedBox(height: 20),
            Text(
              'Log In',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _login(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF655CD1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                'Log In',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.poppins(color: const Color(0xFF655CD1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
