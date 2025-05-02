import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDetailsScreen extends StatefulWidget {
  @override
  _ProfileDetailsScreenState createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  List<String> selectedDays = [];
  TimeOfDay selectedTime = TimeOfDay(hour: 8, minute: 0);
  String email = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? "";

    print("📧 Email from SharedPreferences: $email");

    if (email.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8080/api/users/$email');
    final response = await http.get(url);

    print("📥 Response: ${response.statusCode}");
    print("📦 Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        nameController.text = data['username'] ?? '';
        weightController.text = data['weight'].toString();
        birthDateController.text = data['birthDate'] ?? '';
        selectedDays = List<String>.from(data['reminderDays']);
        if (data['reminderTime'] != null && data['reminderTime'].contains(":")) {
          final parts = data['reminderTime'].split(":");
          selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (email.isEmpty) return;

    final url = Uri.parse('http://10.0.2.2:8080/api/users/$email');
    final body = {
      "username": nameController.text,
      "birthDate": birthDateController.text,
      "weight": int.tryParse(weightController.text) ?? 0,
      "reminderDays": selectedDays,
      "reminderTime": "${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}"
    };

    await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  void _onFieldChange() {
    _saveProfile(); // الحفظ التلقائي عند التعديل
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Account"),
        content: Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final url = Uri.parse('http://10.0.2.2:8080/api/users/$email');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("First Name"),
            _inputField(nameController, onChanged: (_) => _onFieldChange()),

            _label("Birth Date"),
            _datePicker(),

            _label("Weight"),
            _inputField(weightController, hint: "Enter your weight", onChanged: (_) => _onFieldChange()),

            _label("Reminders"),
            _reminderDays(),

            SizedBox(height: 12),
            _label("Reminder Time"),
            _timePicker(),

            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _signOut,
                  child: Text("Sign out", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline)),
                ),
                TextButton(
                  onPressed: _deleteAccount,
                  child: Text("Delete Account", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _inputField(TextEditingController controller, {String? hint, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _datePicker() {
    return TextField(
      controller: birthDateController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "YYYY-MM-DD",
        prefixIcon: Icon(Icons.calendar_today),
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      onTap: () async {
        final initialDate = DateTime.tryParse(birthDateController.text) ?? DateTime(2000);
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            birthDateController.text = picked.toIso8601String().split('T').first;
            _saveProfile();
          });
        }
      },
    );
  }

  Widget _timePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: selectedTime);
        if (picked != null) {
          setState(() {
            selectedTime = picked;
            _saveProfile();
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time),
            SizedBox(width: 12),
            Text(
              "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reminderDays() {
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Wrap(
      spacing: 6,
      children: days.map((day) {
        final isSelected = selectedDays.contains(day);
        return ChoiceChip(
          label: Text(day),
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              isSelected ? selectedDays.remove(day) : selectedDays.add(day);
              _saveProfile();
            });
          },
          selectedColor: Color(0xFF655CD1),
          backgroundColor: Colors.grey[200],
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        );
      }).toList(),
    );
  }
}
