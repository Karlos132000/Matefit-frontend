import 'dart:convert';
import 'package:http/http.dart' as http;

class ExerciseService {
  final String apiUrl = 'http://localhost:8080/api/admin/exercises'; // رابط الـ API الخاص بالتمارين

  // جلب التمارين
  Future<List<dynamic>> fetchExercises() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  // إضافة تمرين
  Future<void> addExercise(String name, String type, int sets, int reps) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'type': type,
        'sets': sets,
        'reps': reps,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add exercise');
    }
  }

  // تعديل تمرين
  Future<void> updateExercise(int id, String name, String type, int sets, int reps) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'type': type,
        'sets': sets,
        'reps': reps,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update exercise');
    }
  }

  // حذف تمرين
  Future<void> deleteExercise(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete exercise');
    }
  }
}
