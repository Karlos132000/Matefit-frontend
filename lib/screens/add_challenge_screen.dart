import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddChallengeScreen extends StatefulWidget {
  @override
  _AddChallengeScreenState createState() => _AddChallengeScreenState();
}

class _AddChallengeScreenState extends State<AddChallengeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _kcalController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _imagePath;
  bool _isLoading = false;
  bool _isPickingImage = false;

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _imagePath = picked.path;
        });
      }
    } catch (e) {
      print("❌ Error picking image: $e");
    } finally {
      _isPickingImage = false;
    }
  }

  void _removeImage() {
    setState(() => _imagePath = null);
  }

  Future<void> _saveChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final creatorEmail = prefs.getString('email') ?? '';

      final url = Uri.parse('http://10.0.2.2:8080/api/challenges');
      var request = http.MultipartRequest('POST', url);

      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descController.text;
      request.fields['date'] = _selectedDate.toIso8601String().split('T').first;
      request.fields['kcal'] = _kcalController.text;
      request.fields['location'] = _locationController.text;
      request.fields['creatorEmail'] = creatorEmail;

      if (_imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _imagePath!));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        _showSnackBar("✅ Challenge saved successfully", success: true);
        Navigator.pop(context);
      } else {
        _showSnackBar("❌ Failed to save challenge");
      }
    } catch (e) {
      print("❌ Error: $e");
      _showSnackBar("❌ Something went wrong");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Challenge")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: _imagePath != null
                            ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _imagePath == null
                          ? const Center(
                        child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                      )
                          : null,
                    ),
                    if (_imagePath != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: _removeImage,
                          ),
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title *', hintText: 'e.g., Morning Run'),
                validator: (val) => val!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description *', hintText: 'Describe the challenge'),
                maxLines: 2,
                validator: (val) => val!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _kcalController,
                decoration: const InputDecoration(labelText: 'Calories (kcal) *', hintText: 'e.g., 300'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Calories are required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location', hintText: 'e.g., City Park'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(), // ✅ يمنع اختيار تاريخ ماضي
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  )
                ],
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    DateTime today = DateTime.now();
                    DateTime selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                    DateTime todayOnly = DateTime(today.year, today.month, today.day);

                    if (selectedDateOnly.isBefore(todayOnly)) {
                      _showSnackBar('❌ Challenge date cannot be in the past');
                      return;
                    }

                    await _saveChallenge();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF655CD1),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Save Challenge"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
