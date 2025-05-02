import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  Future<String> generateAndStoreVerificationCode() async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random();
    final code = List.generate(6, (_) => random.nextInt(10)).join();
    await prefs.setString('verification_code', code);
    return code;
  }

  Future<void> sendVerificationEmail({
    required String name,
    required String email,
    required String code,
  }) async {
    const serviceId = 'service_buejr7c';
    const templateId = 'template_927qho8';
    const userId = 'm4xYili-WZBLor8k5';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'user_name': name,
          'user_email': email,
          'verification_code': code,
        }
      }),
    );

    if (response.statusCode == 200) {
      print("✅ Email sent to $email");
    } else {
      print("❌ Failed to send email: ${response.body}");
    }
  }

  Future<void> _registerUser(BuildContext context) async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String birthDate = dobController.text.trim();
    String phone = phoneController.text.trim();
    String weight = weightController.text.trim();

    if ([name, email, password, birthDate, weight].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields.', style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8080/api/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': name,
        'email': email,
        'password': password,
        'birthDate': birthDate,
        'phoneNumber': phone,
        'weight': int.tryParse(weight) ?? 0,
        'reminderDays': [],
        'reminderTime': ''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final code = await generateAndStoreVerificationCode();
      await sendVerificationEmail(name: name, email: email, code: code);

      // حفظ الإيميل في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);

      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed. ${response.body}', style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Image.asset('assets/images/onboarding_illustration.png', height: 100),
            const SizedBox(height: 16),
            Text('Create your account', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            _textField(nameController, 'Name'),
            const SizedBox(height: 16),
            _textField(emailController, 'Email address'),
            const SizedBox(height: 16),
            _textField(passwordController, 'Password', obscure: true),
            const SizedBox(height: 16),
            _birthDateField(),
            const SizedBox(height: 16),
            _textField(phoneController, 'Phone number'),
            const SizedBox(height: 16),
            _textField(weightController, 'Weight '),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _registerUser(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF655CD1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text('Sign Up', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _birthDateField() {
    return TextField(
      controller: dobController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Date of birth (YYYY-MM-DD)',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000, 1, 1),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          dobController.text = picked.toIso8601String().split('T')[0];
        }
      },
    );
  }
}
