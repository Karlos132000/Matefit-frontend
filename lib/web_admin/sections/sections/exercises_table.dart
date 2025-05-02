import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AdminExercisesTab extends StatefulWidget {
  @override
  _AdminExercisesTabState createState() => _AdminExercisesTabState();
}

class _AdminExercisesTabState extends State<AdminExercisesTab> {
  List<dynamic> exercises = [];
  List<dynamic> filteredExercises = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  bool isEditing = false;
  int? editingId;
  String? newImageUrl; // صورة جديدة من الجهاز
  String? editingImageUrl; // الصورة القديمة اللي جاية مع التمرين من السيرفر

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/admin/exercises'));

    if (response.statusCode == 200) {
      setState(() {
        exercises = json.decode(response.body);
        filteredExercises = exercises;
      });
    } else {
      print('Failed to load exercises');
    }
  }

  Future<void> addExercise() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/admin/exercises'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': nameController.text,
        'type': typeController.text,
        'sets': int.parse(setsController.text),
        'reps': int.parse(repsController.text),
        'imageUrl': newImageUrl ?? editingImageUrl ?? 'assets/exercises/default_image.png',
      }),
    );

    if (response.statusCode == 201) {
      fetchExercises();
      clearForm();
    } else {
      print('Failed to add exercise');
    }
  }

  Future<void> updateExercise(int id) async {
    final response = await http.put(
      Uri.parse('http://localhost:8080/api/admin/exercises/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': nameController.text,
        'type': typeController.text,
        'sets': int.parse(setsController.text),
        'reps': int.parse(repsController.text),
        'imageUrl': newImageUrl ?? editingImageUrl ?? 'assets/exercises/default_image.png',
      }),
    );

    if (response.statusCode == 200) {
      fetchExercises();
      clearForm();
    } else {
      print('Failed to update exercise');
    }
  }

  Future<void> deleteExercise(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:8080/api/admin/exercises/$id'));

    if (response.statusCode == 200) {
      fetchExercises();
    } else {
      print('Failed to delete exercise');
    }
  }

  void clearForm() {
    setState(() {
      nameController.clear();
      typeController.clear();
      setsController.clear();
      repsController.clear();
      newImageUrl = null;
      editingImageUrl = null;
      isEditing = false;
      editingId = null;
    });
  }

  void filterExercises(String query) {
    setState(() {
      filteredExercises = exercises
          .where((exercise) => exercise['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        newImageUrl = pickedFile.path;
      });
    }
  }

  Widget buildExerciseCard(dynamic exercise) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: exercise['imageUrl'] == null || exercise['imageUrl'] == ''
            ? Image.asset('assets/exercises/default_image.png', width: 50, height: 50)
            : Image.asset(exercise['imageUrl'], width: 50, height: 50),
        title: Text(exercise['name']),
        subtitle: Text('Type: ${exercise['type']} | Sets: ${exercise['sets']} | Reps: ${exercise['reps']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                  editingId = exercise['id'];
                  nameController.text = exercise['name'];
                  typeController.text = exercise['type'];
                  setsController.text = exercise['sets'].toString();
                  repsController.text = exercise['reps'].toString();
                  editingImageUrl = exercise['imageUrl'];
                  newImageUrl = null;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => deleteExercise(exercise['id']),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search box
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Exercise...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Color(0xFFF9F2F9),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xFFD6C6DA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xFFD6C6DA)),
                  ),
                ),
                onChanged: filterExercises,
              ),
            ),

            // Form inputs
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEditing ? 'Edit Exercise' : 'Add Exercise'),
                  SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Exercise Name'),
                  ),
                  TextField(
                    controller: typeController,
                    decoration: InputDecoration(labelText: 'Exercise Type'),
                  ),
                  TextField(
                    controller: setsController,
                    decoration: InputDecoration(labelText: 'Sets'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: repsController,
                    decoration: InputDecoration(labelText: 'Reps'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),

                  // Upload Image area
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: newImageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(newImageUrl!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                          : (isEditing && editingImageUrl != null && editingImageUrl!.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          editingImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                          : Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                      )),
                    ),
                  ),

                  // Add/Update Button
                  ElevatedButton(
                    onPressed: isEditing ? () => updateExercise(editingId!) : addExercise,
                    child: Text(isEditing ? 'Update Exercise' : 'Add Exercise'),
                  ),
                ],
              ),
            ),

            // Exercises List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                return buildExerciseCard(filteredExercises[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}






