import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditChallengeScreen extends StatefulWidget {
  final Map<String, dynamic> challenge;

  EditChallengeScreen({required this.challenge});

  @override
  _EditChallengeScreenState createState() => _EditChallengeScreenState();
}

class _EditChallengeScreenState extends State<EditChallengeScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _kcalController = TextEditingController();

  DateTime _selectedDate = DateTime.now();  // Initialize with the current date

  final _imagePicker = ImagePicker();
  String? _base64Image;  // Store the selected image as Base64

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.challenge['title'];
    _descriptionController.text = widget.challenge['description'];
    _locationController.text = widget.challenge['location'] ?? '';
    _kcalController.text = widget.challenge['kcal']?.toString() ?? '';  // Set kcal value if available
    _selectedDate = DateTime.parse(widget.challenge['date'] ?? DateTime.now().toString());  // Set the selected date from the challenge
  }

  // Pick a new image
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes); // Convert the image to Base64
      });
    }
  }

  // Update the challenge in the backend
  Future<void> _updateChallenge() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _kcalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    final response = await http.put(
      Uri.parse('http://192.168.0.43:8080/api/challenges/${widget.challenge['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'date': _selectedDate.toIso8601String(),  // Convert selected date to ISO string
        'kcal': int.tryParse(_kcalController.text) ?? 0, // Convert kcal to int
        'imageUrl': _base64Image != null
            ? _base64Image  // Removed "data:image/png;base64," here
            : widget.challenge['image_url'],  // Send the Base64 image string or the existing URL
        'creatorEmail': widget.challenge['creatorEmail'],  // or replace with the correct email
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Challenge updated successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update challenge: ${response.body}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextFormField(
                controller: _kcalController,
                decoration: InputDecoration(labelText: 'Calories (kcal)'),
                keyboardType: TextInputType.number,  // Ensure it's numeric input
              ),
              SizedBox(height: 16),
              // Display selected date with a date picker button
              Row(
                children: [
                  Text(
                    "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",  // Format the date
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: _base64Image == null
                    ? widget.challenge['image_url'] != null
                    ? Image.network('http://localhost:8080${widget.challenge['image_url']}', height: 200, width: double.infinity, fit: BoxFit.cover)
                    : Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                )
                    : Image.memory(base64Decode(_base64Image!), height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateChallenge,
                child: Text('Update Challenge'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
