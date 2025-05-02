import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class NutritionTip {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;

  NutritionTip({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory NutritionTip.fromJson(Map<String, dynamic> json) {
    return NutritionTip(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}

class NutritionTipsTab extends StatefulWidget {
  const NutritionTipsTab({super.key});

  @override
  _NutritionTipsTabState createState() => _NutritionTipsTabState();
}

class _NutritionTipsTabState extends State<NutritionTipsTab> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imageBase64;
  Uint8List? _imageBytes;
  List<NutritionTip> _tips = [];
  NutritionTip? _editingTip;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    final response = await http.get(Uri.parse('http://192.168.0.43:8080/api/nutrition/tips'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _tips = data.map((json) => NutritionTip.fromJson(json)).toList();
      });
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submitTip() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final isEditing = _editingTip != null;
    final url = isEditing
        ? Uri.parse('http://192.168.0.43:8080/api/nutrition/tips/${_editingTip!.id}')
        : Uri.parse('http://192.168.0.43:8080/api/nutrition/tips');

    final method = isEditing ? http.put : http.post;

    try {
      final response = await method(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'imageUrl': _imageBase64 ?? _editingTip?.imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? "Tip updated" : "Tip added")),
        );
        _clearForm();
        await _loadTips();
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _editTip(NutritionTip tip) {
    setState(() {
      _editingTip = tip;
      _titleController.text = tip.title;
      _descriptionController.text = tip.description;
      _imageBase64 = null;
      _imageBytes = null;
    });
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _imageBase64 = null;
    _imageBytes = null;
    _editingTip = null;
  }

  Future<void> _deleteTip(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Tip"),
        content: const Text("Are you sure you want to delete this tip?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );
    if (confirm == true) {
      final response = await http.delete(
        Uri.parse('http://192.168.0.43:8080/api/nutrition/tips/$id'),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tip deleted")));
        await _loadTips();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tip Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _uploadImage,
              child: Container(
                height: 200,
                color: Colors.grey[200],
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                    : (_editingTip?.imageUrl != null
                    ? Image.network('http://192.168.0.43:8080${_editingTip!.imageUrl!}', fit: BoxFit.cover)
                    : const Center(child: Text("Tap to upload an image"))),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTip,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF655CD1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(_editingTip == null ? 'Add Tip' : 'Update Tip', style: const TextStyle(color: Colors.white)),
            ),
            if (_editingTip != null)
              TextButton(
                onPressed: _clearForm,
                child: const Text("Cancel Edit"),
              ),
            const Divider(),
            const SizedBox(height: 10),
            ..._tips.map((tip) => Card(
              child: ListTile(
                leading: tip.imageUrl != null
                    ? Image.network('http://192.168.0.43:8080${tip.imageUrl!}', width: 60, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported),
                title: Text(tip.title),
                subtitle: Text(tip.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _editTip(tip)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteTip(tip.id)),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
